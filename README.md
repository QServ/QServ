QServ is a Q/KDB+ service framework.

It has a number of parts that make up the complete service framework. 
Some parts depends on other parts but some can be used separately.

The directories are

config/ This directory contains example configuration. It is read by the configManager.

src/q/configManager/ Reads configurations files and saves them in .cfg

src/q/ConnectionHandeler/ Handles connections, reconnect and disconnection handlers.

sec/q/debug/ Contains functions useful for debugging and tracing through a running system.

src/q/log/ Handles logging to file and/or to a server.

src/q/tableHandler/ Not implemented yet. Will handle subscription to tables between services.

src/q/historyServer/ Not implemented yet. Will be a generic server that saves published table(s) to disk in a hdb.

src/q/scheduler/ This is a scheduler that can be used to schedule jobs to run at certain times. 
                 Will be implemented as separate service also.

src/test Contains tests on most components that make up QServ.
