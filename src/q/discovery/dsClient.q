//*******************************************************************************
// The discovery client depends on the connection handler to get a connection to 
// the discovery service.
//*******************************************************************************

qServHome:getenv `QSERV_HOME;
system "l ", qServHome, "/src/q/configManager/configManager.q"
system "l ", qServHome, "/src/q/connectionHandler/con.q"
\d .ds

dsHost:.cfg.common[`discoveryHost];
dsPort:"I"$ string .cfg.common[`discoveryPort];

//initialise the connection to the discovery service.
.con.setupHostCon[dsHost;dsPort;`discovery;1b;""];

//*******************************************************************************
// getDsCon[]
// Gets the connection to the discovry service.
//*******************************************************************************
getDsCon:{.con.getCon[`discovery]}

//The table containing services registred by this service.
regServices:([Service:`symbol$();
   Instance:`symbol$()]
   Host:`symbol$();
   Port:`int$();
   Type:`symbol$();
   Active:`int$());

//The table containing tables registred by this service.
regTables:([Table:`symbol$();
   Part:`int$();
   Instance:`symbol$()]
   Host:`symbol$();
   Port:`int$();
   Active:`int$());

//The table containing functions registred by this service.
regFunctions:([Function:`symbol$();
   Instance:`symbol$()]
   Async:`boolean$();
   Host:`symbol$();
   Port:`int$();
   Active:`int$());

//*******************************************************************************
// registerService[]
// Registers the service defined in s.
// Parameter:  
//    svc   The name of this service (symbol).
//    inst  Ths instance of this service (symbol).
//    t
//    active
//*******************************************************************************
registerService:{[svc; inst; t; active]
   con:getDsCon[];
   s:(`Service`Instance`Host`Port`Type`Active)!
     (svc;inst;.z.h;system "p";t;active);
   `.ds.regServices upsert s;
   con (`.ds.registerService;s);
   }

getService:{
   getDsCon[] (`.ds.getService;x)}

//*******************************************************************************
// registerTables[]
// Registers the tables that are defined in t.
// Parameter:  
//    t  
//*******************************************************************************
registerTable:{[table; part; inst; active]
   con:getDsCon[];
   t:(`Table`Part`Instance`Host`Port`Active)!
     (table;part;inst;.z.h;system "p";active);
   `.ds.regTables upsert t;
   con (`.ds.registerTable;t);
   }

//*******************************************************************************
// getTableDetails[]
// A wraper to call the function getTableDetails in the discovery service.
// Parameter:
//  x   
//*******************************************************************************
getTableDetails:{
   getDsCon[] (`.ds.getTableDetails;x)}


//*******************************************************************************
// registerFunctions[]
// Parameter:  
//    
//*******************************************************************************
registerFunction:{[func;inst;async;active]
   con:getDsCon[];
   f:(`Function`Instance`Async`Host`Port`Active)!
      (func;inst;async;.z.h;system "p";active);
   `.ds.regFunctions upsert f;
   con (`.ds.registerFunction;f);
   }

getFunctionDetails:{
   getDsCon[] (`.ds.getFunctionDetails;x)}

//*******************************************************************************
// execFun[]
// 
// Executes a function that has been registred in the discovery service.
// if keepHandle is true The handle to the server that was called will be kept
// andsubsequent calls to the same function will go to the same server 
// (unless the connection is lost).
// params must be a list containing the parameters of the function, even if the 
// function is unary.
//*******************************************************************************
execFun:{[fun;instance;keepHandle;params]
   d:first () xkey getFunctionDetails[(fun;instance)];
   h:$[keepHandle;
         getFunCon[d];
         getFunHandle[d]];
   ret:$[d[`Async];
          [(neg h) raze (fun;params);1b];
          h raze (fun;params)];
   if[not keepHandle;
      hclose[h]];
   ret}

getFunHandle:{[funInfo]
   hopen `$":",(string funInfo[`Host]),":",string funInfo[`Port]}


getFunCon:{[funInfo]
   if[not funInfo[`Function] in .con.references;
       .con.setupHostCon[ funInfo[`Host]; funInfo[`Port];funInfo[`Function];1b;""]];
   .con.getCon[funInfo[`Function]]}

//*******************************************************************************
// hearbeat[]
// This fucntion is called by a service to indicate that the
// service, tables and functions defined by s, t, and f are
// still valid.
//
// Parameters:  
//*******************************************************************************
heartbeat:{[]
   getDsCon[] (`.ds.heartbeat;
                  flip key .ds.regServices;
                  flip key .ds.regTables;
                  flip key .ds.regFunctions);
   }

\d .