// All functions and tables here should not be
// used by services. The discovery service is a 
// self contained service and should only be
// accessed by the discovery service client 
// (dsClient.q).
//
// All registred services can be viewed using the 
// web intecface. 
//Move to config later
\l ../configManager/configManager.q

system "p ", string .cfg.common[`discoveryPort];

Services:([Service:`symbol$();
   Instance:`symbol$()]
   Host:`symbol$();
   Port:`int$();
   Type:`symbol$();
   Active:`int$();
   LastHeartBeat:`timestamp$());

Tables:([Table:`symbol$();
   Part:`int$();
   Instance:`symbol$()]
   Host:`symbol$();
   Port:`int$();
   Active:`int$();
   LastHeartBeat:`timestamp$());

Functions:([Function:`symbol$();
   Instance:`symbol$()]
   Async:`boolean$();
   Host:`symbol$();
   Port:`int$();
   Active:`int$();
   LastHeartBeat:`timestamp$());

\d .ds

//***********************************************************
// registerService[]
// Registers the service defined in s.
// Parameter:  
//    svc   A dictionary with the fields Service, Instance, 
//          Host, Type, and Active.
//***********************************************************
registerService:{[svc]
   `Services upsert update LastHeartBeat:.z.P from svc;
   1b}                    

//***********************************************************
// getService[]
// Returns all services that corresponds to x.
// 
// Parameters:
//    x  If x is a symbol all services that matches that name 
//       is returned.
//       if x is a list the fisrt entry is matched against 
//       the service name and the second is matched agains
//       the instanece.
//***********************************************************
getService:{
   $[2 = count x;
      select  from `.[`Services] where Service=x[0], Instance=x[1];
     1 = count x;
      select  from `.[`Services] where Service=x;
      'parameterLength]}

//***********************************************************
// registerTables[]
// Registers the tables that are defined in t.
// Parameter:  
//    t  A dictionary with the fields Table, Part, Instance, 
//       Host, Port and Active.
//***********************************************************
registerTable:{[t]
   `Tables upsert update LastHeartBeat:.z.P from t;
   1b}                    
//***********************************************************
// getTableHost[]
// Returns all hosts that have registred a table that 
// corresponds to x.
// 
// Parameters:
//    x  If x is a symbol all Table entries that name is 
//       returned.
//       if x is a list the fisrt entry is matched against 
//       the table name and the second is matched agains
//       the part. If a third entry is suplied that is
//       used to match the instance.
//***********************************************************
getTableHost:{
   $[3 = count x;
      select  from `.[`Tables] where Table=x[0], Part=x[1], Instrance=x[2];
     2 = count x;
      select  from `.[`Tables] where Table=x[0], Part=x[1];
     1 = count x;
      select  from `.[`Tables] where Table=x;
      'parameterLength]
   }


//***********************************************************
// registerFunctions[]
// Parameter:  
//    f  A dictionary with the fields Function, Host and 
//       Port.
//***********************************************************
registerFunction:{[f]
   `Functions upsert update LastHeartBeat:.z.P from f;
   1b}                    

getFunctionHost:{
   $[2 = count x;
      select  from `.[`Functions] where Function=x[0], Instance=x[1];
     1 = count x;
      select  from `.[`Functions] where Function=x;
      'parameterLength]}

//***********************************************************
// hearbeat[]
// This fucntion is called by a service to indicate that the
// service, tables and functions defined by s, t, and f are
// still valid.
//
// Parameters:  
//    s  A dictionary with the fields Service and Instance.
//    t  A dictionary with the fields Table, Part and 
//       Instance.
//    f  A dictionary with the fields Function, Host and 
//       Port.
//***********************************************************
heartbeat:{[s;t;f]
   serviceHeartbeat[s];
   tableHeartbeat[t];
   functionHeartbeat[f];
   }


serviceHeartbeat:{[s]
   if[not s~();
      update LastHeartBeat:.z.P from `Services where (flip (Service;Instance)) in flip value s];
   }
tableHeartbeat:{[t]
   if[not t~();
      update LastHeartBeat:.z.P from `Tables where (flip (Table;Part;Instance)) in flip value t];
   }
functionHeartbeat:{[f]
   if[not f~();
      update LastHeartBeat:.z.P from `Functions where (flip (Function;Instance)) in flip value f];
   }


//*********** Webs tuff *************************
\d .h
.z.ph:{
   x:uh$[type x;x; first x];
   //If no file have been specified then serve discoveryWeb.html.
   if[not count x; x:"discoveryWeb.html"];
   // Serve the requested file. If the file can't be found
   // we serve notFound.html. If that doesn't exist we 
   // just give an error message (404) as text.
   $[count r:@[read1;`$":",p:.h.HOME,"/",x;""];
       hy[`$(1+x?".")_x]"c"$r;
     count r:@[read1;`$":",.h.HOME,"/notFound.html";""];
       hy[`htm]"c"$r;
       hn["404 Not Found";`txt]p,": not found"]}

.z.ws:{
   if[not x~enlist"";(neg .z.w) value x];
   }

// Format a table as a html table
table:{[tbl;class]
 id:$[""~class;"";"class='",class,"'"];
 c:(cols tbl)except `even;
 ("<table ",id,">",th[c],/tr[;c] each ()xkey tbl),"</table>"}

//Format a html table header from a symbol list.
th:{[c]
   (("<tr class='header'>"),/"<th>",/:(string c),\:"</th>"),"</tr>"}

//Format a html table row from a dictionary.
tr:{[row;c]
   r:{$[(0h~type x);x;string x]}each row[c];
   class:$[not `even in key row;"";row[`even];"class='odd'";"class='even'"];
   ("<tr ",class,">",/"<td>",/:(r),\:"</td>"),"</tr>"}

//Get the columns we need to display the services on the webpage as html.
getServiceTable:{[filter]
   filter:$[-10h~type filter;enlist filter;filter];
   table[;"Services"] 
   update
      even: i mod 2      
   from
   select 
      Service, 
      Instance,
      Type,
      Host, 
      Port,
      Active
   from `.[`Services] 
   where Service like filter}

//Get the columns we need to display the tables on the webpage as html.
getTablesTable:{[filter]
   filter:$[-10h~type filter;enlist filter;filter];
   table[;"Tables"]
   update
      even: i mod 2      
   from
   select
      Table,
      Instance,
      Part,
      Host, 
      Port,
      Active
   from `.[`Tables] 
   where Table like filter}

//Get the columns we need to display the Functions on the webpage as html.
getFunctionsTable:{[filter]
   filter:$[-10h~type filter;enlist filter;filter];
   table[;"Functions"]
   update
      even: i mod 2      
   from
   select 
      Function,
      Instance,
      Host, 
      Port,
      Active
   from `.[`Functions] 
   where Function like filter}

\d .
