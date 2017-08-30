//*******************************************************************
// A simple test client that uses the discovery client to execute 
// the function .test.mult
//
//*******************************************************************

\l ../../../configManager/configManager.q
\l ../../../connectionHandler/con.q
\l ../../../q/discovery/dsClient.q

show "executing .ds.execFun[`.test.mult;`Primary;0b;(1 2 3 4 5)]"
show p.ds.execFun[`.test.mult;`Primary;0b;(1 2 3 4 5)];