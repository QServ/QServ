//*******************************************************************************
// The connection manager is defined in this file. It keeps track of all open
// connections and will try to reconnect if the connection is broken for some 
// reason. The connection manager can be used as a stand alone part of the 
// framework.
// 
// To get the parts that make use of the discovery service the file conDS.q must 
// be loaded after this file have been loaded as it might override some of the 
// functions defined here. 
//*******************************************************************************
\d .con

//*******************************************************************************
// getCon[]
//
// This function is used to get the handle to another Q service. The Connection 
// must have been setu using the function setupHostCon[] before this function is 
// called. If the connection have been lost it will try to reconnect and return 
// the new handle. To avoid stale or wrong handles the handle itself should never
// be saved by a service, it should make use of the reference and this function 
// go get the handle. This will ensure that the handle is always correct. 
//
// Parameters:
//    ref   (symbol) The reference that identifies this connection.
//
//*******************************************************************************
getCon:{[ref]
   $[ref in key .con.hostConnections;
       .con.hostConnections[ref;`Handle];
     ref in key .con.pendingHostConnections;
       reconnectHost[ref];
     '`$"No such reference: ", string ref]}

//*******************************************************************************
// setupHostCon[]
//
// Sets up a reference to a connection to a host/port.  It doesn't actually open
// the connection it only initiates the structures needed by the framework. 
// To open the actual connection the function getCon[] have to be called.
// If the reference passed to this function is already in use it will be 
// rejected and a signal will be raised. If we already have a handle open to the
// same host and port that handle will be reused.
//
// Parameters:
//    host           (symbol)  The hostname or ip of the host to connect to. 
//    port           (int)     The port to use when opening the connection.
//    reference      (symbol)  A unique reference to a host connection.
//    reconnect      (boolean) Flag that tells the connection handler if is 
//                             should try to reopen the handle on close.
//    disconHandler  (symbol)  The full name of the function that should be 
//                             called when the handle is closed. 
//
//*******************************************************************************
setupHostCon:{[host;port;reference;reconnect;disconHandler]
   if[reference in .con.references;
      //(reference in key .con.hostConnections) or 
      //(reference in key .con.serviceConnections) or
      //(reference in key .con.pendingHostConnections) or
      //(reference in key .con.pendingServiceConnections);
      '`$"Reference `", (string reference) ," is already in use"];
   h:first exec Handle from .con.handles where Host=host, Port=port;
   if[(not null h) and not h = 0i; 
      `.con.hostConnections upsert (reference;h;host;port;disconHandler;reconnect); 
      :h];
   h:openCon `$":",(string host),":",(string port);
   $[h = 0i;
      `.con.pendingHostConnections upsert (reference;host;port;disconHandler;reconnect);
      [`.con.hostConnections upsert (reference;h;host;port;disconHandler;reconnect);   
       `.con.handles upsert (host;port;h)]];
   references,:reference;
   reference}

//*******************************************************************************
// closeHostCon[]
//
// Close the connection that are defined by ref.
//
// Parameters:
//    ref    (symbol)  The reference to the handle that should be closed.
//    dcCall (boolean) Tells if the disconnection handles should be called when 
//                     the connection is closed.
//*******************************************************************************
closeHostCon:{[ref; dcCall]
   `nyi
   .con.references:.con.references except ref;
   }

//************************ Internal functions and tables ************************

//*******************************************************************************
// All open handles.
//*******************************************************************************
handles:([]
   Host:`$();
   Port:`int$();
   Handle:`int$());

//*******************************************************************************
// Connections to speciffic hosts and ports.
//*******************************************************************************
hostConnections:([Reference:`$()]
   Handle:`int$();
   HostName:`$();
   Port:`int$();
   DisconnectionHandler:();
   Reconnect:`boolean$());

//*******************************************************************************
//*******************************************************************************
pendingHostConnections:([Reference:`$()]
   HostName:`$();
   Port:`int$();
   DisconnectionHandler:();
   Reconnect:`boolean$());

//*******************************************************************************
// Close handlers is a list of function names that should be called when a 
// handle is closed.
//*******************************************************************************
closeHooks:`$();

//*******************************************************************************
// A list of all used connection references.
//*******************************************************************************
references:`$();

//*******************************************************************************
// registerCloseHook[]
// 
// Register a hook that should be called when a handle is closed. This should 
// used with care...
// 
// Parameters:
//    fName    The full function name as a string.
//
//*******************************************************************************
registerCloseHook:{[fName]
   .con.closeHooks:.con.closeHooks union fName;}

//*******************************************************************************
// handleHostConnectionClose[]
//
// Handles all closes of handles that are of HostConnectinType. This function 
// should nevet be called manually. It should only be called by the .z.pc 
// function.
//
// Parameters:
//    handle      The handle that was closed.
//
//*******************************************************************************
handleHostConnectionClose:{[con]
   hostReconnect:any exec Reconnect 
                     from .con.hostConnections 
                     where Handle = con[`Handle];
   // Call all disconnection handlers.
   {if[not x ~ ();
      //Check that the diconnection handler is a valid function.
      if[validateDisconnectionHandler[x[`DisconnectionHandler]];
         .[value x[`DisconnectionHandler];
            (x[`HostName];x[`Port]);
            {show "couldn't execute", string x}[x]]]];} //FIXME: Use error function here to log error
      each select from .con.hostConnections 
                  where not DisconnectionHandler like "";

   // Remove the reference is we shouldn't reconnect.
   {if[not x[`Reconnect]; .con.references:.con.references except x[`Reference]];}
      each select from .con.hostConnections where not Reconnect;

   //Check if we should reconnect.
   if[hostReconnect;
      h:openCon `$":",(string first con[`Host]),":",string first con[`Port];
      show h;
      delete from `.con.hostConnections where Handle = con[`Handle], Reconnect=0b;
      $[h=0i;
         [`.con.pendingHostConnections upsert 
            select Reference, HostName, Port, DisconnectionHandler, Reconnect  
            from .con.hostConnections where Handle = con[`Handle];
          delete from `.con.hostConnections where Handle = con[`Handle]];
         update Handle:h from `.con.hostConnections where Handle = con[`Handle]]];
   }

//*******************************************************************************
// validateDisconnectionHandler[]
//
// Validates the that the symbol handler represents a valid function.
//
// Parameters:
//    handler  (symbol) The name of a function that should be validated.
//
//*******************************************************************************
validateDisconnectionHandler:{[handler]
   fun:@[value;handler;{x;}]; //TODO: Logg warning here.
   (not null fun) and ((type fun) within (100;112))}

//*******************************************************************************
// reconnectHost[]
//
// Reconnect to the host given by ref. The connection must be pending for the 
// reconnect to work.
//
// Parameters:
//    ref   (symbol) Reference to the connection that should be reconnected.
//
//*******************************************************************************
reconnectHost:{[ref]
   con:.con.pendingHostConnections[ref];
   con[`Reference]:ref;
   con[`Handle]:openCon `$":",(string con[`Host]),":",string con[`Port];
   if[not con[`Handle]=0i;
      `.con.hostConnections upsert con;
      `.con.handles upsert (con[`HostName`Port`Handle]);
      delete from `.con.pendingHostConnections where Reference = ref];
   con[`Handle]} 

//*******************************************************************************
// reconnectAllHosts[]
//
// This function tries to connect all pending connections.
// This function should probably get called by the timer...
//
//*******************************************************************************
reconnectAllHosts:{[]
   reconnectHost each (key .con.pendingHostConnections)`Reference} 

//*******************************************************************************
// openCon[]
//
// Utility function to open a connection to the given host.
// If the connection fails it will return 0 as the handle.
//
// Parameters:
//    host  (symbol) The hostame or ip to the host to wich the connection should
//                   be opened to.
//
//*******************************************************************************
openCon:{[host]
   @[hopen;host;0i]}

//*******************************************************************************
// Do cool stuff if we get a disconnection on any handle...
//*******************************************************************************
.z.pc:{[handle]
   con:select from .con.handles where Handle = handle;
   delete from `.con.handles where Handle = handle;

   // Call all registred hooks with the handle that was closed as argument.
   {@[value y;x;{show "Error executing function ", (string y)}];
   }[con] each closeHooks;
   }

// Register the Host Connection close handler.
registerCloseHook[`.con.handleHostConnectionClose];

// Thats all folks... Lets leave this namespace.
\d .
