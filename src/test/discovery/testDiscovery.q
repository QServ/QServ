system "l ", (getenv `QSERV_HOME), "/src/q/configManager/configManager.q"
system "l ", (getenv `QSERV_HOME), "/src/q/connectionHandler/con.q"
system "l ", (getenv `QSERV_HOME), "/src/q/discovery/dsClient.q"

\l ../k4unit.q
.KU.DEBUG:1
.KU.SAVEFILE:`:discovery_tests.csv

KUltf `:testDiscovery.csv
show KUT

KUrt[]

show KUTR

KUstr[]
\\
