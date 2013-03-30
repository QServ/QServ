\l ../configManager/configManager.q
\l ../connectionHandler/con.q
\l dsClient.q

\p 12346

.test.mult:{(*)over x}

//.ds.registerFunction[`.test.mult;`Primary;1];

show " executing .ds.execFun[`.test.mult;`Primary;0b;(1 2 3 4 5)]"
show p.ds.execFun[`.test.mult;`Primary;0b;(1 2 3 4 5)];