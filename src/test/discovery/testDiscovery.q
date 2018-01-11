system "l ", (getenv `QSERV_HOME), "/src/q/configManager/configManager.q"
system "l ", (getenv `QSERV_HOME), "/src/q/connectionHandler/con.q"
system "l ", (getenv `QSERV_HOME), "/src/q/discovery/dsClient.q"

\l ../k4unit.q
.KU.DEBUG:1
KUltf `:testDiscovery.csv
KUrt[]
show KUTR
\\
