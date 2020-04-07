#!/bin/sh -ex

# sql server jdbc driver
MSSQL_VERSION=8.2.2
JRE_VERSION=11
mvn install:install-file -Dfile=/tmp/mssql-jdbc-${MSSQL_VERSION}.jre${JRE_VERSION}.jar -DgroupId=com.microsoft.sqlserver -DartifactId=mssql-jdbc -Dversion=${MSSQL_VERSION} -Dpackaging=jar

case ${DISTRO} in
    wildfly*)
        cat <<-EOF > batch.cli
batch
embed-server --std-out=echo

module add --name=com.microsoft.sqlserver --slot=main --resources=/tmp/mssql-jdbc-${MSSQL_VERSION}.jar --dependencies=javax.api,javax.transaction.api
/subsystem=datasources/jdbc-driver=mssql:add(driver-name="sqlserver",driver-module-name="com.microsoft.sqlserver",driver-xa-datasource-class-name=com.microsoft.sqlserver.jdbc.SQLServerXADataSource)

run-batch
EOF
        /camunda/bin/jboss-cli.sh --file=batch.cli
        ;;
    *)
        cp /tmp/mssql-jdbc-${MSSQL_VERSION}.jre${JRE_VERSION}.jar /camunda/lib
        ;;
esac
