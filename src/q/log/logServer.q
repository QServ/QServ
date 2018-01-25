// This is a logging server that can be used to handle disk I/O 
// 

qServHome:getenv `QSERV_HOME;
system "l ", qServHome, "/src/q/configManager/configManager.q"
system "l ", qServHome, "/src/q/connectionHandler/con.q"
system "l ", qServHome, "/src/q/discovery/dsClient.q"

\l dbLogger.q
system "p ", string .cfg.common[`logServerPort]

.ds.registerFunction[`.log.log;`Primary;1b;1];
.ds.registerFunction[`.log.verbose;`Primary;1b;1];
.ds.registerFunction[`.log.debug;`Primary;1b;1];
.ds.registerFunction[`.log.info;`Primary;1b;1];
.ds.registerFunction[`.log.warn;`Primary;1b;1];
.ds.registerFunction[`.log.error;`Primary;1b;1];
.ds.registerFunction[`.log.fatal;`Primary;1b;1];




 


