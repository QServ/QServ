// This is a logging service that can be used to handle diskl I/O 
// if 
\l log.q
\d .logServer
port:9999;
system "p ", string port;

logBuffer:update Service:`$() from .log.logBuffer;

clients:([name:`$()]
          filename:`$();
          handle:`int$());

// Registers a logging client.
// The name will be used to identify the client and should be unique
// between clients. The filename is used to 
register:{[name; filename]
   show "APA";
   if[filename in exec filename from .logServer.clients;
      '`$"filename already in use"];
   if[name in exec name from .logServer.clients;
      '`$"name already in use"];
   `.logServer.clients upsert (name;filename;.z.w);
   :1b
   }
   
unRegister:{[name;flushToFile]

   }

logg:{[name;Logrows]
   //TODO: check that name and .z.w are correct according to 
   // .logServer.clients.
   show "BANAN";
   
   `.logServer.logBuffer insert 
     (update Service:name, Data:.log.format each Data from Logrows);
   } 
// TODO: disconnection handler must be implemented. (.z.pc)

\d .

 


