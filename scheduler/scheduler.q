\d .cron

// The resolution of the timer used in ms.
res:500h;
setTimerRes:{[res]
   .cron.res:res;
   start[];
   }

//Should the scheduler use local time or GMT?
useLocalTime:1b;

stop:{system "t 0";}
start:{system "t ", string .cron.res;}

//****** Functions to add commands to cron **************
addCron:{[dom;wd;h;m;s;command]
   .cron.cronSchedule:.cron.cronSchedule,flip (`DayOfMonth`Weekday`Hour`Min`Sec`Command)!
      (enlist dom; enlist wd; enlist h; enlist m; enlist s; enlist command);
   }

addOneTimeJob:{[c;t]
   .cron.cronOnce:.cron.cronOnce,flip (`Command`Time)!(enlist c; enlist t)
   }

/*Loads a file with cron jobs*/
loadSchedule:{[fileName]}

//******************** Internal functions ****************
// -1i means the same as * in cron (any).
cronSchedule:([]
   DayOfMonth:`int$();
   Weekday:`int$();
   Hour:`int$();
   Min:`int$();
   Sec:`int$();
   Command:());

cronOnce:([]
   Command:();
   Time:`timestamp$());

checkAll:{
   if[.cron.lastCheck + res < .cron.ts:getTimestamp[];
      checkCroneOnce[];
      checkCronSchedule[];
      .cron.lastCheck:.cron.ts;
   ];}

//Fungerar ej!!
checkCronSchedule:{
   dow:(-2+`date$.cron.ts) mod 7;
   c:exec 
      Command 
     from 
      .cron.cronSchedule 
     where 
      ((DayOfMonth=.cron.ts.dd) or(DayOfMonth<0)), 
      ((Weekday=dow) or(Weekday<0)), 
      ((Hour=.cron.ts.hh) or(Hour<0)), 
      ((Min=.cron.ts.uu) or(Min<0)); //,
      //((Sec within (.cron.lastCheck.second;.cron.ts.second)) or (Min<0));
   executeCommands[c];
   }

checkCroneOnce:{
   c:exec Command from .cron.cronOnce where Time < .cron.ts;
   executeCommands[c];
   }

executeCommands:{[c]
   if[count c;
      {show x; @[value;x;show "could not execute command ", x]} each c;
      delete from `.cron.cronOnce where Time < ts];
   }


getTimestamp:{$[useLocalTime;.z.P;.z.p]}

lastCheck:.z.P;
.z.ts:checkAll;
start[];
\d .


