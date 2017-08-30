// There are three ways to log with the logging farmework.
// 1. Use the standard log functions .log.info, .log.warn etc.
//    These functions use the default logging output. The default
//    is stdout but can be set to log to a file.
//    To change the default logging output to a file the function
//    setDefaultLogfile[`filename] should be used.
// 2. Named references can be used to log output to other files.
//    These references have to be setup before they are used. The
//    function setupLogFile[`ref;`filename] should be used to 
//    register new logfiles.
//    To log to a custom log file the functions .log.finfo, 
//    .log.fwarn etc. should be used.
//
//    Example:
//    We want to log to the file myNewLogFile.log. As reference to 
//    this log file we want to use the name newLog when we log to
//    it.
//    
//    setupLogFile[`newLog; myNewLogFile.log];
//    .log.fwarn[`newLog;("This is a warning and will be printed to the file myNewLogFile.log")];
//
// 3. A logging service can be setup to handle all logging.
//    To log to a service a named reference to the service is used
//    in the same way using the same functions as the named files. 
//    The setup of the reference uses a different function
// 
\d .log

// A logfile have to be setup using this function
// before it is used.
setupLogFile:{[ref;fileName]
   if[ref in exec Reference from .log.logOutputs;   
         line: first select from .log.logOutputs where Reference = ref;
         warn[("reference ";ref ;" is already setup as "string line[`Type]; " logger")];
         :0b]; 
   if[fileName in exec Name from .log.logOutputs;
         line first select from .log.logOutputs where Name=fileName;   
         warn[("The name ";(string fileName); " have already been setup. The reference used is ";
         line[`Reference]); " The type is "; line[`Type]];
         :0b]; 
   `.log.logOutputs upsert (fileName;ref;hopen hsym fileName;0n;`file);
   1b}

//TODO: name and filename...fix.
setupLogServer:{[ref;host;port]
   if[ref in exec Reference from .log.logOutputs;   
         line: first select from .log.logOutputs where Reference = ref;
         warn[("reference ";ref ;" is already setup as "string line[`Type]; " logger")];
         :0b]; 
   if[host in exec Name from .log.logOutputs;
         line first select from .log.logOutputs where Name=host;   
         warn[("The name ";(string host); " have already been setup. The reference used is ";
         line[`Reference]); " The type is "; line[`Type]];
         :0b]; 
   handle:hopen `$":",(string host),":", string port;
   if[handle = 0i;
      warn["Could not open connection to ";host; ":";port]];
   (neg handle) (".logServer.register";`test;`test.log);
   `.log.logOutputs upsert (host;ref;handle;port;`server);
   1b}

// flog (file log) logs to the given file.
flog:{[file;lvl;data]
   if[not lvl>logLvl;
      if[not 0 ~ type data; data: enlist data];
      `.log.logBuffer upsert (.z.P;data;levels lvl;file)];
   }


// Convinience logging functions:
verbose:{[data] flog[`;VERBOSE;data]}
debug:{[data] flog[`;DEBUG;data]}
info:{[data] flog[`;INFO;data]}
warn:{[data] flog[`;WARN;data]}
error:{[data] flog[`;ERROR;data]}
fatal:{[data] flog[`;FATAL;data]}

fverbose:{[fileRef;data] flog[fileRef;VERBOSE;data]}
fdebug:{[fileRef;data] flog[fileRef;DEBUG;data]}
finfo:{[fileRef;data] flog[fileRef;INFO;data]}
fwarn:{[fileRef;data] flog[fileRef;WARN;data]}
ferror:{[fileRef;data] flog[fileRef;ERROR;data]}
ffatal:{[fileRef;data] flog[fileRef;FATAL;data]}

// All logging is stored in the log buffer to be flushed 
// to file or sent to a log service at a later point. 
// Setting up a separate log service on the same machine 
// can be a good idea if you don't want to block the service
// during file I/O.
logBuffer:([]Time:`timestamp$();
             Data:();
             Level:`$();
             File:`$());

// All trace messages are stored in the trace buffer 
// to be flushed to file at a later point.
//
traceBuffer:([]Time:`timestamp$();
               fun:`symbol$());

// logOutputs keeps track of 
logOutputs:([]Name:`$();
            Reference:`$();
            Handle:`int$();
            Port:`int$();
            Type:`$());

//std out. Override to write to file.
STDOUT:-1;
//std err. Override to write to file.
STDERR:-2;
//Log handle. Default std out.
LOGOUT:STDOUT;

//Varable to enable trace logging.
TRACE:0b;

//Standard log levels
FATAL:1;
ERROR:2;
WARN:3;
INFO:4;
DEBUG:5;
VERBOSE:6;

levels:(FATAL;ERROR;WARN;INFO;DEBUG;VERBOSE)!(`FATAL;`ERROR;`WARN;`INFO;`DEBUG;`VERBOSE);

//The current log level.
//Default: INFO
logLvl:INFO;

//Set the logfile 
setDefaultLogfile:{[file]
   LOGOUT:hopen hsym file}

trace:{[fun]
   if[TRACE;
      .log.traceBuffer insert (.z.P;fun)];
   }
    
format:{[data]
   $[0>type data;
      string data;
     10h ~ type data;
      data;
      [" " sv {$[0>type x;
                   string x;
                 10h ~ type x;
                   x;
                   format x]} each data]]}

flushLog:{
   //Start with the stuff that should be sent to a logging serer.
   serverOut:select from .log.logBuffer 
         where File in (exec Reference from .log.logOutputs where Type = `server);
   sendToServer[serverOut]
   delete from `.log.logBuffer 
          where File in (exec Reference from .log.logOutputs where Type = `server);
   
   //Then flush the rest to file.
   fileOut: select Date:Time.date, Time:Time.time, Data, File, Level 
        from .log.logBuffer; 
   writeToFile each fileOut;
   delete from `.log.logBuffer;
   }

sendToServer:{[Log]
   servers:exec distinct File from Log;
   {[logTable;server]
      handle:first exec Handle from .log.logOutputs where Reference = server;
      data: select from logTable where File=server;
      (neg handle) (`.logServer.logg;`test;data);
   }[Log]each servers;
   }

// internal funcition. Should not be used by other systems.
writeToFile:{[Log]
   file: Log[`File];
   fileHandle:$[null file;
                LOGOUT;
                first exec Handle from logOutputs where Reference=file];
   Time: (" " sv string (Log[`Date`Time`]));
   $[null fileHandle;
      [LOGOUT  Time, "WARNING: logfile ", (string file), " Has not been setup correct. Logging to default logger\n";
       LOGOUT  Time, (string Log[`Level]), ": ", format[Log[`Data]], "\n"];
      fileHandle  Time,(string Log[`Level]), ": ", format[Log[`Data]], "\n"];
   }

\d .
