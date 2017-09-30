//*******************************************************************************
//A simple implementation of a scheduler.
//
//
//*******************************************************************************

\d .cron

// The resolution of the timer used in ms.
res:5000h;

//*******************************************************************************
// setTimerRes[]
// Sets the resolution of the timer that triggers sheduled events.
// Default is 5 seconds.
// Parameter:
//    res    The time resolution in milliseconds 
//*******************************************************************************
setTimerRes:{[res]
   .cron.res:res;
   start[];
   }

stop:{system "t 0";}
start:{system "t ", string .cron.res;}

//****** Functions to add commands to cron **************

//*******************************************************************************
// addCron[]
// Adds a new cron job.
// Parameter:
//    dom      Day of month. -1 means don't care (same as * in linux cron).
//    wd       Day of week. -1 means don't care (same as * in linux cron).
//    h        Hour. -1 means don't care (same as * in linux cron).
//    m        Minute. -1 means don't care (same as * in linux cron).
//    command  The command that should be run.
//*******************************************************************************
addCron:{[dom;wd;h;m;command]
   .cron.cronSchedule:.cron.cronSchedule,flip (`DayOfMonth`Weekday`Hour`Min`Command)!
      (enlist dom; enlist wd; enlist h; enlist m; enlist command);
   }

//*******************************************************************************
// addOneTimeJob[]
// Adds a job that will be run once at a given time.
// Parameter:
//    command    The command that should be run.
//    dateTime   A datetime representing the time when the job should be run.
//*******************************************************************************
addOneTimeJob:{[command;dateTime]
   .cron.cronOnce:.cron.cronOnce,flip (`Command`Time)!(enlist command; enlist dateTime)
   }


//*******************************************************************************
// loadSchedule[]
// Loads a file with cron jobs. 
// The file should ebea csv with the headers :
// DayOfMonth, Weekday, Hour, Min, Command
// where all except Command is integers. Command is a string of Q code that will
// be executed when the schedule entry is triggered.
// Parameter:
//    filename  The file name of the csv file that should be loaded as a symbol
//              with a colon before the actual file name.
//              Example: `:MyFantasticSchedule.cs
//*******************************************************************************
loadSchedule:{[fileName]
   `.cron.cronSchedule upsert ("IIII*";enlist ",")0:fileName
   }

//******************** Internal functions ****************
// The table containing all the shedule entries.
cronSchedule:([]
   DayOfMonth:`int$();
   Weekday:`int$();
   Hour:`int$();
   Min:`int$();
   Command:());

// The table containing the ons shot entries.
cronOnce:([]
   Command:();
   Time:`datetime$());

//*******************************************************************************
// checkAll[]
// Checks if any sheduled entries should be triggered.
//*******************************************************************************
checkAll:{
   if[.cron.lastCheck + res < .cron.ts:getTimestamp[];
      checkCroneOnce[];
      checkCronSchedule[];
      .cron.lastCheck:.cron.ts;
   ];}

//*******************************************************************************
// checkCronSchedule[]
// Checks if any recuring schedules  shouldbe triggered. If any entries are found
// they will be executed.
//*******************************************************************************
checkCronSchedule:{
   dow:(-2+`date$.cron.ts) mod 7;
   matches:select 
     from 
      .cron.cronSchedule 
     where 
      ((DayOfMonth=.cron.ts.dd) or (DayOfMonth<0)), 
      ((Weekday=dow) or (Weekday<0)), 
      ((Hour=.cron.ts.hh) or (Hour<0)), 
      ((Min=.cron.ts.uu) or (Min<0));
   matches:delete 
      from matches 
      where  
        ((DayOfMonth=.cron.lastCheck.dd) or (DayOfMonth<0)), 
        ((Weekday=dow) or (Weekday<0)), 
        ((Hour=.cron.lastCheck.hh) or (Hour<0)), 
        ((Min=.cron.lastCheck.uu) or (Min<0));
   executeCommands[exec Command from matches];
   }

//*******************************************************************************
// checkCroneOnce[]
// Checks if any one of sheduled entries should be triggered. If any entries are
// found they will be triggered and removed from the .cron.cronOnce table.
//*******************************************************************************
checkCroneOnce:{
   c:exec Command from .cron.cronOnce where Time < .cron.ts;
   executeCommands[c];
   delete from `.cron.cronOnce where Time < .cron.ts;
   }

//*******************************************************************************
// executeCommands[]
// Executes commands.
// Parameter:
//    commands A list array where each string is a command that should be 
//             executed.
//*******************************************************************************
executeCommands:{[c]if[count c; {eval parse x} each c]}

//*******************************************************************************
// getTimestamp[]
// Gets the correct timestamp depending on the settings in .cron.useLocalTime.
//*******************************************************************************
getTimestamp:{$[useLocalTime;.z.P;.z.p]}

//Should the scheduler use local time or GMT?
useLocalTime:1b; //TODO: Move to configuration!

ts:lastCheck:getTimestamp[];
.z.ts:checkAll;
start[];
\d .


