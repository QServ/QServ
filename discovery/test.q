\l ../configManager/configManager.q
\l ../connectionHandler/con.q
\l dsClient.q
\e 1
\p 12345

.test.mult:{
	show "recieved request to mult ", .Q.s1 x;
	result:(*)over x;
	show "result is: ", .Q.s1 result;
	result}

.ds.registerFunction[`.test.mult;0b;`Primary;1];
\t 1000
.z.ts:{[x] .ds.heartbeat[]}