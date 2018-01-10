//*******************************************************************************
// The config manager loads the configuration files used by a service. The 
// loading of filed makes the asumption that the service is running on a unix 
// like system with ls installed.
//
// Two environment variables are used by the config manager. They are 
// KDB_COMMON_CONFIG_PATH and KDB_SVC_CONFIG_PATH.
// 
// All files in the KDB_COMMON_CONFIG_PATH are loaded by the config manager. 
// The configuration items in these files will be available in the variable
// .cfg.common.<name>
//
// NOTE: All config failes must end with .cfg in the common config directory. 
//       All other files will be ignored.
//
//
// The variable KDB_SVC_CONFIG_PATH is used for the service speciffic config.
// The files in this directory are not loaded automatically and will have to be 
// loaded manually using the .cfg.loadFile[] function. To load all config files 
// in this directory the function .cfg.loadAllSvcConfig[] should be used.  
// The configuration items in these files will be available in the variable
// .cfg.svc.<name>
//
// NOTE: All config failes must end with .cfg if the .cfg.loadAllSvcConfig[] 
//       is uesd to laod the configuration. All other files will be ignored.
//
// NOTE2: Remember that the loading order is important. If the same config name 
//        occurs in more than one config file only the last one to be loaded will
//        be available.
//
//*******************************************************************************

\d .cfg

//*******************************************************************************
// loadFile[]
//
// Loads a service speciffic config file into the service config. The file must
// be in the folder defined by KDB_SVC_CONFIG_PATH.
//*******************************************************************************
loadFile:{[filename]
   prefix:`svc;
   // create the prefix if needed
   if[not prefix in key .cfg; .cfg[prefix]:(()!())];
   loadFileIntoPrefix[svcConfigPath;prefix;filename];
   }

//*******************************************************************************
// loadCommonCfg[]
//
// Loads all config files pressent in the foder defined by 
// KDB_COMMON_CONFIG_PATH.
//*******************************************************************************
loadCommonCfg:{[]
   loadAllFiles[commonConfigPath;`common];
   }

//*******************************************************************************
// loadAllSvcConfig[]
//
// Loads all config files in the folder defined by KDB_SVC_CONFIG_PATH.
//*******************************************************************************
loadAllSvcConfig:{[]
   loadAllFiles[svcConfigPath;`svc];
   }

//*******************************************************************************
// loadAllFiles[path;prefix]
// 
// Loads all files in the directory defined by 'Path' into the name space
// .cfg.[prefix]. 
// This can be used to load config files from any directory and is not dependant 
// on the environment variables being set.
//*******************************************************************************
loadAllFiles:{[path;prefix]
   // create the prefix if needed
   if[not prefix in key .cfg; .cfg[prefix]:(()!())];
   
   f:getConfigFileNames[path];
   loadFileIntoPrefix[path;prefix] each f;
   }

//*******************************************************************************
// loadFileIntoPrefix[path;prefix;filename]
//
// Loads a given file pressent in the given path into the given namespace in .cfg
// This can be used to load config files from any directory and is not dependant 
// on the environment variables being set.
//*******************************************************************************
loadFileIntoPrefix:{[path;prefix;filename]
   {[prefix;x] 
      if[not (x[0] like "#*") or (x[0] like "");
      .cfg[prefix;x[0]]:x[1]]
   }[prefix]each flip ("SS";"=")0: `$":", path ,"/",filename;
   }

//************* Internal functions. Not intended for external use ***************

svcConfigPath:getenv `KDB_SVC_CONFIG_PATH;
commonConfigPath:getenv `KDB_COMMON_CONFIG_PATH;

//*******************************************************************************
// getConfigFileNames[]
//
// Returns the name of all files in the directory defined by path 
//
// Parameters:
//    path  (string) The path to the directory containing the config files that 
//                   should be listed.
//
//*******************************************************************************
getConfigFileNames:{[path]
   f @ where (f: system "ls ",path) like "*.cfg"}

\d .
