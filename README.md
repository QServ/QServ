QServ is a Q/KDB+ service framework.

It has a number of parts that make up the complete service framework. 
Some parts depends on other parts but some can be used separatelly.

The directories are

config/ This directory contains example configuration. It is read by the configManager.

configManager/ Rades configurations files and saves them in .cfg

ConnectionHandeler/ Handeles connections, reconnect and disconnection handlers.

debug/ Contains functions usefull for debugging and tracing through a runnig system.

log/ Hanldes logging to file and/or to a server.

tableHandler/ Not implemented yet. Will handle subscription to tables between services.

historyServer/ Not implemented yet. Will be a generic server that saves published table(s) to disk in a hdb.

scheduler/ This is a scheduler that can be used to schedule jobs to run at sertain times. 
           Will be implemeted as separate service also.
