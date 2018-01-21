//*******************************************************************************
// The dbLogger is an experimental logger that saves all logs in a HDB instead 
// of regular files.
// If this logger is used it should only be used in a separate log server.
//
// It asumes that the database has been loaded using \l <db path> or as the 
// command line parameter.
//
// The log levels available are:
//     .log.FATAL
//     .log.ERROR
//     .log.WARN
//     .log.INFO
//     .log.DEBUG       
//     .log.VERBOSE
//
// 
//
//*******************************************************************************

\d .log

//*******************************************************************************
// log[]
//
// Logs the given message if lvl is lower or equal to the current log level.
//*******************************************************************************
.log.log:{[lvl;data]
   if[not lvl>level;
      //if[not 0h ~ type data; data: enlist data];
      `.log.logTable upsert (.z.P;levels lvl;format[data])];
   }

// Convinience logging functions:
verbose:{[data] .log.log[VERBOSE;data]}
debug:{[data] .log.log[DEBUG;data]}
info:{[data] .log.log[INFO;data]}
warn:{[data] .log.log[WARN;data]}
error:{[data] .log.log[ERROR;data]}
fatal:{[data] .log.log[FATAL;data]}

//*******************************************************************************
// Write the log to HDB partitioned on the date extracted from the timestamp.
//*******************************************************************************
flushLog:{[]
   dates:exec distinct "d"$Time from `.log.logTable;
   {(hsym  `$(string x), "/logHDB/") upsert .Q.en[`:.;] ?[`.log.logTable;enlist(=;($;"d";`Time);x);0b;()]}each dates;
   delete from `.log.logTable;
   system "l ."
   }

//*******************************************************************************
// The log table where all logs are stored (surprise surprise...). 
//*******************************************************************************
logTable:([]Time:`timestamp$();
             Level:`$();
             Message:());


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
                   format x]} each data]]
   }
\d .
