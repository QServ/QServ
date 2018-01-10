
###Configuration Manager
The config manager loads the configuration files used by a service. The 
loading of filed makes the asumption that the service is running on a unix 
like system with ls installed.

####Environment variables
Two environment variables are used by the config manager. They are 
**KDB_COMMON_CONFIG_PATH** and **KDB_SVC_CONFIG_PATH**. Both variables should 
point to directories containing the configuration files you want to load.


All files in the KDB_COMMON_CONFIG_PATH are loaded by the config manager. 
The configuration items in these files will be available in the variable
.cfg.common.<name>

NOTE: All config failes must end with .cfg in the common config directory. 
      All other files will be ignored.


The variable KDB_SVC_CONFIG_PATH is used for the service speciffic config.
The files in this directory are not loaded automatically and will have to be 
loaded manually using the .cfg.loadFile[] function. To load all config files 
in this directory the function .cfg.loadAllSvcConfig[] should be used.  
The configuration items in these files will be available in the variable
.cfg.svc.<name>

NOTE: All config failes must end with .cfg if the .cfg.loadAllSvcConfig[] 
      is uesd to laod the configuration. All other files will be ignored.

NOTE2: Remember that the loading order is important. If the same config name 
       occurs in more than one config file only the last one to be loaded will
       be available.

