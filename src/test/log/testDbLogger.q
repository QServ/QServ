system "l ", (getenv `QSERV_HOME), "/src/q/log/dbLogger.q"

\l ../k4unit.q
.KU.DEBUG:1
.KU.VERBOSE:0
KUltf `:testDbLogger.csv
\l db
KUrt[]

numTests:count  KUTR
passed:select from KUTR where ok = 1
show  "Ran ", (string numTests), " tests. Number of successfull tests: ", (string count passed)

failed:select from KUTR where ok = 0
if[0<count failed; show "Number of failed tests:", string count failed;1b; show select test:i, code from KUTR where ok=0]

\\
