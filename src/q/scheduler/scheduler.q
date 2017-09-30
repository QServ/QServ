\d .cron

// The resolution of the timer used in ms.
res:5000h;

setTimerRes:{[res]
   .cron.res:res;
   start[];
   }

//Should the scheduler use local time or GMT?
useLocalTime:1b;

stop:{system "t 0";}
start:{system "t ", string .cron.res;}

//****** Functions to add commands to cron **************
addCron:{[dom;wd;h;m;command]
   .cron.cronSchedule:.cron.cronSchedule,flip (`DayOfMonth`Weekday`Hour`Min`Command)!
      (enlist dom; enlist wd; enlist h; enlist m; enlist command);
   }

addOneTimeJob:{[c;t]
   .cron.cronOnce:.cron.cronOnce,flip (`Command`Time)!(enlist c; enlist t)
   }

/*Loads a file with cron jobs*/
loadSchedule:{[fileName]
   `.cron.cronSchedule upsert ("IIII*";enlist ",")0:fileName
   }

//******************** Internal functions ****************
// -1i means the same as * in cron (any).
cronSchedule:([]
   DayOfMonth:`int$();
   Weekday:`int$();
   Hour:`int$();
   Min:`int$();
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

checkCroneOnce:{
   c:exec Command from .cron.cronOnce where Time < .cron.ts;
   executeCommands[c];
   }

executeCommands:{[c]
   if[count c;
      {eval parse x} each c;
      delete from `.cron.cronOnce where Time < .cron.ts];
   }


getTimestamp:{$[useLocalTime;.z.P;.z.p]}

ts:lastCheck:getTimestamp[];
.z.ts:checkAll;
start[];
\d .


