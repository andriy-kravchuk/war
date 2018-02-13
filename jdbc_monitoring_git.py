# JDBC monitoring
# ver 0.1
# Andriy Kravchuk, UNION, 16.08.2017
# this script has to be started by Oracle WLST scripts (formally Jython 3.2)
#!/oracle/Middleware/.../common/bin/wlst.sh
import re


UAT = "t"
PROD = "p"

ENVIRONMENT_IS = UAT

SERVER_RE = "Appserver_%s" % (ENVIRONMENT_IS)
DATASOURCE_RE = "my_datasource"
DATASOURCE_GOOD_STATUS = "Running"
LOG_PATH = "/var/log/monitoring/"
LOG_FILENAME = "datasource_jdbc.log"
ON = "1"
OFF = "0"
RESULTS = []
f = open(LOG_PATH + LOG_FILENAME, "a")
connect()

# get all servers list
allServers=domainRuntimeService.getServerRuntimes();

# filter necessary servers
myServers = [i for i in allServers if re.findall(SERVER_RE, i.name)]

for server in myServers:
	# get a server Runtime
	jdbcServiceRT = server.getJDBCServiceRuntime();

	# Datasources
	dataSources = jdbcServiceRT.getJDBCDataSourceRuntimeMBeans();

	# Necessary datasource
	datasource = [i for i in dataSources if re.findall(DATASOURCE_RE, i.name)][0]

	# get datasource status
	datasourceStatus = datasource.getState()

	# checking
	if datasourceStatus in DATASOURCE_GOOD_STATUS:
		datasourceLogStatus = ON
	else:
		datasourceLogStatus = OFF

	RESULTS.append(datasourceLogStatus)
	print "%s %s %s" % ( server.name, i.name, datasourceLogStatus)

# save a final status
if OFF in RESULTS:
	finalStatus = OFF
else:
	finalStatus = ON
f.write(finalStatus+"\n")
f.close()
