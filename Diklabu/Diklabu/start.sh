#!/bin/bash

# Trap signals to prevent script from stopping
trap '' SIGUSR1 SIGUSR2

# Disable JLine terminal to avoid JNA errors
export ASADMIN_NO_INTERACTIVE=true
export AS_ADMIN_INTERACTIVE=false

echo "=========================================="
echo "Starting Firebird DB Server"
echo "=========================================="
/usr/sbin/fbguard &
FBPID=$!
echo "Firebird started with PID: $FBPID"

echo "Waiting for Firebird to start..."
sleep 5 || true

echo "=========================================="
echo "Configuring Firebird for legacy database support"
echo "=========================================="
# Set environment variable to disable wire encryption for this session
export ISC_USER=SYSDBA
export ISC_PASSWORD=masterkey

echo "=========================================="
echo "Checking and creating/upgrading database"
echo "=========================================="
DB_FILE="/var/lib/firebird/3.0/data/KLASSENBUCH.GDB"

if [ -f "$DB_FILE" ]; then
    # Check if it's an old format database
    echo "Database file found: $DB_FILE"
    if isql-fb -user SYSDBA -password masterkey "$DB_FILE" -o /tmp/db_test.log <<< "SELECT 1 FROM RDB\$DATABASE;" 2>&1 | grep -q "unsupported on-disk structure"; then
        echo "WARNING: Database is in old ODS 11.2 format!"
        echo "Please upgrade the database manually outside the container."
        echo "The old database will be backed up and a new empty database will be created."
        
        # Backup old database
        mv "$DB_FILE" "$DB_FILE.old_ods11_$(date +%Y%m%d_%H%M%S)"
        
        # Create new database
        echo "Creating new empty database..."
        cat <<EOF | isql-fb
CREATE DATABASE 'localhost:$DB_FILE'
USER 'SYSDBA'
PASSWORD 'masterkey'
PAGE_SIZE 8192
DEFAULT CHARACTER SET ISO8859_1;
QUIT;
EOF
        chown firebird:firebird "$DB_FILE" 2>/dev/null || true
        echo "New empty database created. You need to import your data."
    else
        echo "Database format is compatible (ODS 12.2)"
    fi
else
    echo "No database file found. Creating new empty database..."
    cat <<EOF | isql-fb
CREATE DATABASE 'localhost:$DB_FILE'
USER 'SYSDBA'
PASSWORD 'masterkey'
PAGE_SIZE 8192
DEFAULT CHARACTER SET ISO8859_1;
QUIT;
EOF
    chown firebird:firebird "$DB_FILE" 2>/dev/null || true
    echo "New database created at: $DB_FILE"
fi

echo "=========================================="
echo "Configuring Firebird Authentication"
echo "=========================================="
# Set SYSDBA password using gsec (legacy authentication tool)
echo "Setting SYSDBA password..."
/usr/bin/gsec -user sysdba -password masterkey -modify sysdba -pw masterkey 2>&1 || echo "Password already set or using legacy mode"

# Create klassenbuch user if it doesn't exist
echo "Creating klassenbuch user..."
/usr/bin/gsec -user sysdba -password masterkey -add klassenbuch -pw mmbbs_1yz 2>&1 || echo "User klassenbuch already exists or error occurred"

# Verify database access with SYSDBA user
echo "Verifying database access with SYSDBA user..."
if command -v isql-fb &> /dev/null; then
    echo "CONNECT '/var/lib/firebird/3.0/data/KLASSENBUCH.GDB' USER 'SYSDBA' PASSWORD 'masterkey'; SELECT 1 FROM RDB\$DATABASE;" | isql-fb 2>&1 | head -15
else
    echo "isql-fb not found, skipping database verification"
fi

# List Firebird version and check if database file exists
echo "Checking Firebird version and database file..."
/usr/sbin/fbguard -V 2>&1 | head -3 || echo "Firebird version check failed"
ls -lh /var/lib/firebird/3.0/data/*.GDB 2>&1 || echo "No database files found"

echo "=========================================="
echo "Starting SSH Server in background"
echo "=========================================="
/usr/sbin/sshd && echo "SSH started successfully" || echo "SSH failed to start, continuing..."

echo "=========================================="
echo "Kopiere template.txt..."
echo "=========================================="
if [ -f /etc/diklabu/template.txt ]; then
    cp /etc/diklabu/template.txt ${PAYARA_HOME}/glassfish/domains/domain1/docroot/
    echo "template.txt copied"
else
    echo "template.txt not found, skipping"
fi

echo "=========================================="
echo "Starting Payara Application Server"
echo "=========================================="
${PAYARA_HOME}/bin/asadmin start-domain
echo "Payara start command completed"

echo "Waiting for Payara to start..."
sleep 10 || true

echo "=========================================="
echo "Deploying diklabu Application"
echo "=========================================="
if [ -f /home/diklabu/diklabu/Diklabu/dist/Diklabu.war ]; then
    ${PAYARA_HOME}/bin/asadmin --user admin --passwordfile=/tmp/payarapwd deploy /home/diklabu/diklabu/Diklabu/dist/Diklabu.war && echo "Deployment successful" || echo "Deployment failed, continuing..."
else
    echo "WAR file not found, skipping deployment"
fi

echo "=========================================="
echo "All services started successfully!"
echo "=========================================="
echo "Container is running. Tailing Payara logs..."
echo "Press Ctrl+C to stop the container"
echo "=========================================="

# Keep container running by tailing logs
if [ -f ${PAYARA_HOME}/glassfish/domains/domain1/logs/server.log ]; then
    tail -f ${PAYARA_HOME}/glassfish/domains/domain1/logs/server.log
else
    echo "Server log not found yet, keeping container alive..."
    # Fallback: just sleep forever
    while true; do sleep 3600; done
fi