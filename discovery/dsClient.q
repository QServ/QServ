//*******************************************************************************
// The discovery client depends on the connection handler to get a connection to 
// the discovery service.
//*******************************************************************************
\l ../configManager/configManager.q
\l ../connectionHandler/con.q

\d .ds
dsHost:.cfg.common[`discoveryHost];
dsPort:"I"$ string .cfg.common[`discoveryPort];

//initialise the connection to the discovery service.
.con.setupHostCon[dsHost;dsPort;`discovery;1b;""];
getDsCon:{.con.getCon[`discovery]}

regServices:([Service:`symbol$();
   Instance:`symbol$()]
   Host:`symbol$();
   Port:`int$();
   Type:`symbol$();
   Active:`int$());

regTables:([Table:`symbol$();
   Part:`int$();
   Instance:`symbol$()]
   Host:`symbol$();
   Port:`int$();
   Active:`int$());

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

getTableDetails:{
   getDsCon[] (`.ds.getTableHost;x)}


//*******************************************************************************
// registerFunctions[]
// Parameter:  
//    f  A dictionary with the fields Function, Host and 
//       Port.
//*******************************************************************************
registerFunction:{[func;inst;async;active]
   con:getDsCon[];
   f:(`Function`Instance`Async`Host`Port`Active)!
      (func;async;inst;.z.h;system "p";active);
   `.ds.regFunctions upsert f;
   con (`.ds.registerFunction;f);
   }

getFunctionDetails:{
   getDsCon[] (`.ds.getFunctionHost;x)}

execFun:{[fun;instance;keepHandle;params]
   d:first () xkey getFunctionDetails[(fun;instance)];
   h:$[keepHandle;
         getFunCon[d];
         getFunHandle[d]];
   ret:$[d[`Async];
          [(neg h) (fun;params);1b];
          h (fun;params)];
   if[not keepHandle;
      hclose[h]];
   ret}

getFunHandle:{[funInfo]
   hopen `$":",(string funInfo[`Host]),":",string funInfo[`Port]}


getFunCon:{[funInfo]
   if[not fun in .con.references;
       .con.setupHostCon[ funInfo[`Host]; funInfo[`Port];fun;1b;""]];
   .con.getCon[fun]}

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