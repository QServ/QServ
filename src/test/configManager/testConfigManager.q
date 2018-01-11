system "l ", (getenv `QSERV_HOME), "/src/q/configManager/configManager.q"

\l ../k4unit.q
.KU.DEBUG:1
.KU.SAVEFILE:`:configManager_tests.csv

KUltf `:testConfigManager.csv
show KUT

KUrt[]

show KUTR

KUstr[]
\\
