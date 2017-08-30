//*********************************************************************
// A simple test service that registers a function (.test.mult) in the 
// discovery service.
//
//
//*********************************************************************

\l ../../../q/configManager/configManager.q
\l ../../../q/connectionHandler/con.q
\l ../../../q/discovery/dsClient.q
\e 1
\p 12345

.test.mult:{
	show "recieved request to mult ", .Q.s1 x;
	result:(*)over x;
	show "result is: ", .Q.s1 result;
	result}

//Register the function in the discovery service
.ds.registerFunction[`.test.mult;0b;`Primary;1];

//Send heartbeats to the discovery service every second. 
\t 1000
.z.ts:{[x] .ds.heartbeat[]}