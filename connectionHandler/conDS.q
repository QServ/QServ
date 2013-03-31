//*******************************************************************************
// This file contains functions that are dependent on the discovery service and
// client to function.
//
// Note: The discovery client must be loaded before this file is loaded.
//
//*******************************************************************************
\d .con
//*******************************************************************************
// getCon[]
//
// This function is used to get the handle to another Q service. The Connection 
// must have been setu using the function setupHostCon[] or setupServiceCon[] 
// before this function is called. If the connection have been lost it will try 
// to reconnect and return the new handle. To avoid stale or wrong handles the 
// handle itself should never be saved by a service, it should make use of the 
// reference and this function go get the handle. This will ensure that the 
// handle is always correct. 
//
// NOTE: This function overrides the one defined in con.q to include the 
//			discovery specific functionality.
//
// Parameters:
//		ref	(symbol) The reference that identifies this connection.
//
//*******************************************************************************
getCon:{[ref]
	$[ref in key .con.hostConnections;
		 .con.hostConnections[ref;`Handle];
	  ref in key .con.serviceConnections;
		 .con.serviceConnections[ref;`Handle];
	  ref in key .con.pendingHostConnections;
		 reconnectHost[ref];
	  ref in key .con.pendingServiceConnections;
		 0i; //try to reconnect...
	  '`$"No such reference: ", string ref]}

//*******************************************************************************
// setupServiceCon[]
// This function should use the discovery service to get a connection to the 
// desired service.
//
// Parameters:
//		service			(symbol)	 The name of the servcie that we should connect 
//										 to.
//		reference		(symbol)	 A unique reference to a host connection.
//		reconnect		(boolean) Flag that tells the connection handler if is 
//										 should try to reopen the handle on close.
//		disconHandler	(symbol)	 The full name of the function that should be 
//										 called when the handle is closed.
//*******************************************************************************
setupServiceCon:{[service;reference;reconnect;disconHandler]
	'niy;
	}

//*******************************************************************************
// closeServiceCon[]
//
// Closes the connection and cleans out all references to it.
//*******************************************************************************
closeServiceCon:{[ref] 
	h:getCon[ref];
	hcloes[h];
	//delete from	
	'nyi;
	}

//*******************************************************************************
// handleServiceConnectionClose[]
//
// Handles all closes of handles that are of ServiceConnectinType. This function 
// should nevet be called manually. It should only be called by the .z.pc 
// function.
//
// Parameters
//		handle		The handle that was closed.
//
//*******************************************************************************
handleServiceConnectionClose:{[handle]
	servReconnect:any exec Reconnect 
							from .con.serviceConnections 
							where Handle = handle;

	//Call all diconnection handlers.
	{if[not x ~ ();
			(value x[`DisconnectionHandler])[x[`ServiceName];x[`Instance]]];} each 
		select from .con.serviceConnections where not DisconnectionHandler like "";

	//Check if we should reconnect.
	if[servReconnect;
		h:openCon `$":",(string first con[`Host]),":",string first con[`Port];
	//Setup pending connections if we can't get a new connection right away.
		delete from `.con.serviceConnections where Handle = handle, Reconnect=0b;
	  if[h=0i;
			[`.con.peindingServiceConnections upsert 
			 select Reference, ServiceName, Instance, DisconnectionHandler, Reconnect 
			 from .con.serviceConnections where Handle = handle;
			 delete from `.con.serviceConnections where Handle = handle];
			update Handle:h from `.con.serviceConnections where Handle = handle]];
	}

//************************ Internal functions and tables ************************

//*******************************************************************************
// Keeps track of connections to services. If a dieconnection occurs and it is 
// set to reconnect it might connect to another host and port if the service is
// in other ways correct. 
//*******************************************************************************
serviceConnections:([Reference:`$()]
	Handle:`int$();
	ServiceName:`$();
	Instance:`$();
	DisconnectionHandler:`$();
	Reconnect:`boolean$());

//*******************************************************************************
// Pending connections is connections that have been setup but the connection 
// isn't up for some reason.
//*******************************************************************************
pendingServiceConnections:([Reference:`$()]
	ServiceName:`$();
	Instance:`$();
	DisconnectionHandler:();
	Reconnect:`boolean$());


// Register the Service Connection close handler.
registerCloseHook[`.con.handleServiceConnectionClose];

\d .