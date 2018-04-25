## Error trapping
I have found it frustration to try to debug code that have error traps in it. For this reason I created helper functions that can be
used as drop in replacements for error traps but that can be turned off.
These funcitions are `utrap` (unary trap) and `mtrap` (multivalent). They have the same sytax as the error trapp functions in Q `@` (unary) and `.` (multivalent). 
The error trap can then be turned on or off by unsing the functions `enableTrap` and `disableTrap`.


## Tracing
This is a tool to help understand how the code is executed.  
It is used to wrap some or all functions in new functions that will print the function name when it enters or exits the wrapped function.
it will print `-->` in from of the function name when entering the function and `<--` when exiting it. 

The functions available are:
`wrapTraceFunction`: Wraps a single function.
`wrapAllNsFunctions`: Wraps all functions in the given namespace.
`wrapAll: Wraps all functions in all namespaces (except `.q`, `.Q`, `.h`, `.o` and `.debug`).

There are also corresponding functions to remove the tracing wrapper from the functions:
`unwrapTraceFunction`: Unwraps a single function.
`unwrapAllNsFunctions`: Unwraps all functions in the given namespace.
`unwrapAll`: Unwraps all functions in all namespaces (except `.q`, `.Q`, `.h`, `.o` and `.debug`).

Tracing can also be turned on or off using the functions `enableTrace` and `disableTrace`.

A simple example on how to use it:
```
q)\l debug.q
q).test.test1:{x+x} 
q).test.test2:{.test.test1[x+x]}
q).debug.wrapAllNsFunctions[`.test]
q).debug.enableTrace[]
q).test.test2[10]
"--> .test.test2"
"--> .test.test1"
"<-- .test.test1"
"<-- .test.test2"
40
q)
```