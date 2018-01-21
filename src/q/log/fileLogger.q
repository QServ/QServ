//*******************************************************************************
// The fileLogger is used to log to a historic database. It will store all 
// logs in memory untill it is flushed to disk with a call to .log.flush.
// When .log.flush is called the in memory table will be flushed to the file 
// handle stored in .log.LOGOUT. By default this is std out but can be overriden 
// by using the function .log.setLogfile[filename].
//
// To write to the log the function .log.
// 
//
// The log levels available are:
//     .log.FATAL
//     .log.ERROR
//     .log.WARN
//     .log.INFO
//     .log.DEBUG       
//     .log.VERBOSE
//
// If 
//
//*******************************************************************************
\d .log

//*******************************************************************************
// All logs are stored in the log buffer initially. It is flushed 
// to file at a later point. 
//*******************************************************************************
logBuffer:([]Time:`timestamp$();
             Data:();
             Level:`$());

//*******************************************************************************
//Set the logfile 
//*******************************************************************************
setLogfile:{[file]
   .log.LOGOUT:hopen hsym file}


//*******************************************************************************
// log[]
//
// logs the given message if lvl is lower or equal to the current log level.
//*******************************************************************************
.log.log:{[lvl;data]
   if[not lvl>level;
      if[not 0 ~ type data; data: enlist data];
      `.log.logBuffer upsert (.z.P;data;levels lvl)];
   }

// Convinience logging functions:
verbose:{[data] .log.log[VERBOSE;data]}
debug:{[data] .log.log[DEBUG;data]}
info:{[data] .log.log[INFO;data]}
warn:{[data] .log.log[WARN;data]}
error:{[data] .log.log[ERROR;data]}
fatal:{[data] .log.log[FATAL;data]}


//*******************************************************************************
// Flush the logs from the log table to the selected file.
//*******************************************************************************
flushLog:{
   //Then flush the rest to file.
   fileOut: select Date:Time.date, Time:Time.time, Data, Level from .log.logBuffer; 
   writeToFile each fileOut;
   delete from `.log.logBuffer;
   }

//*******************************************************************************
// internal funcition. Should not be used by other systems.
//*******************************************************************************
writeToFile:{[Log]
   Time: (" " sv string (Log[`Date`Time`]));
   LOGOUT  Time, (string Log[`Level]), ": ", format[Log[`Data]], "\n";
   }
    
//*******************************************************************************
// Used internally to format the log string.
//*******************************************************************************
format:{[data]
   $[0>type data;
      string data;
     10h ~ type data;
      data;
      [" " sv {$[0>type x;
                   string x;
                 10h ~ type x;
                   x;
                   format x]
               } each data]
      ]
   }


//std out. The default logging
STDOUT:-1;
//std err. Can be used to redirect logs to std err.
STDERR:-2;
//Log handle. Default std out. Override this to log to file
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
level:INFO;

\d .
