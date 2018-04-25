// Debugging utilitied for Q. 
//
// Author Johan Hemstrom.
// johan@hemstrom.st
//
// ©  2012 Johan Hemstrom. 
// All rights reserved.
//
\d .debug

// Init must be called before any of the trace functions
// are called (mainly the wrap* functions).
//init:`debug 2:(`init;1);
//init[];

TRACE:0b;
TRAP:1b;

//******************* Error trapping *******************
// Unary trap function. 
// Error trap that can be turned off during debugging
// by setting .debug.TRAP to 0b.
// It is desigend to be used as a drop in replacement
// of the @[fun:arg;expr] Q error trap.
utrap:{[fun;arg;expr]$[TRAP;@[fun;arg;expr];fun @ arg]}

// Multivalent trap function. 
// Error trap that can be turned off during debugging
// by setting .debug.TRAP to 0b.
// It is desigend to be used as a drop in replacement
// of the .[fun:args;expr] Q error trap.
mtrap:{[fun;args;expr]$[TRAP;.[fun;args;expr];fun . args]}


//Utility funxtions to turn error trapping on.
enableTrap:{.debug.TRAP:1b}
//Utility funxtions to turn error trapping off.
disableTrap:{.debug.TRAP:0b}

//******************* Tracing **************************
//Function used to log. Override with the function used 
//in the rest of the system.
logfun:{[x]
   -1 .Q.s1 x;
   }


//Utility function to turn on traceing.
enableTrace:{
   .debug.TRACE:1b;
   }

//Utility function to turn off traceing.
disableTrace:{
   .debug.TRACE:0b;
   }

// Logging function that can be turned on in debug mode
// to trace function calls in a running application.
// It will call the function traceLog if the flagg
// .debug.TRACE is set to 1b.
trace:{[str] if[TRACE;logfun[str]]}

// Helper functions to format the trace log string.
// If a logging framework is used in the rest of the 
// system the function 'logfun' should be overriden or 
// rewritten to use that framework.
errorTrace:{[ns;fn;err]
    logfun["STACK TRACE: ",($[ns~".";"";ns,"."]),fn,"\n\t reason: ",err]}

//***************** WARNING **************************
// The functions below should only be used when 
// debugging. Use at your own risk in a production 
// environment.
//****************************************************

// Helper function to get the full name of a function 
// as a string.
getFunctionNameAsString:{[ns;fn]
   $[ns~`.;
      string fn;
      (string ns),".",string fn]}

// This function replaces an existing function and 
// calls the original function with protected evaluation.
// if an error occurs the function name is printed out 
// and the error is rethrown.
// TODO: the variables in the functions should be saved 
// off for inspection in all levels of the stack trace. 
// These variables should be saved in a separate data
// structure and utility functions should be implemented
// to access them.
wrapTraceFunction:{[ns;fn]
   //Check if the function is already wrapped.
   if[fn like "wrapped_*"; :0b];
   if[(`$"wrapped_",string fn) in system "f ", string ns;:0b];
   //Check if it is a dynamic loaded function
   if[112h~type ns[fn];:0b];
   params:(value ns[fn])[1];
   e:$[2>count params;"enlist";""];
   fname:string fn;
   newFnName:$[ns~`.;"";(string ns),"."],"wrapped_",fname;
   //Save the old function
   (`$newFnName) set ns[fn];

   //Create the new function
   newFn:value "{[",(";" sv string params),"].debug.trace[\"--> ",((string ns),".",fname),"\"];res:.[",newFnName,"; ",e,"(",(";" sv string params),");{.debug.errorTrace[\"",(string ns),"\";\"",fname,"\";","x]; '`$x}];.debug.trace[\"<-- ",((string ns),".",fname),"\"];res}";
   //Overwrite the old function with the new.
   ![ns;();0b;(enlist fn)!enlist newFn];
   }


// Removes the trace wrapper from the fucntion. 
unwrapTraceFunction:{[ns;fn]
   newFnName:`$"wrapped_",string fn;
   oldFnName:getFunctionNameAsString[ns;fn];
   (`$oldFnName) set ns[newFnName];
   ![ns;();0b;enlist newFnName];
   }

// Wrapps all funcitons in a namespace by calling
// wrapTraceFunction on all functions defined in 
// the given namespace.
wrapAllNsFunctions:{[ns]
   functions:system "f ",string ns;
   wrapTraceFunction[ns]each functions;
   }

// Unwraps all functions in a namespace by restoring
// the original functions and deleting the temporary 
// functions.
unwrapAllNsFunctions:{[ns]
  fns:system "f ",string ns;
  fns:fns[where fns like "wrapped_*"];
  {unwrapTraceFunction[x;`$(count "wrapped_")_string y]}[ns] each fns; 
  }

//Wraps all functions in all namespaces except 
//the internal Q ones.
wrapAll:{[]
   ns:`$(enlist "."),"." ,/:  string raze enlist (key `)except `q`Q`h`o`debug;
   wrapAllNsFunctions each ns;}

//Unwraps all functions in all namespace except s 
//the internal Q ones.
unwrapAll:{[]
   ns:`$(enlist "."),"." ,/:  string raze enlist (key `)except `q`Q`h`o`debug;
   unwrapAllNsFunctions each ns;
   }

\d .
