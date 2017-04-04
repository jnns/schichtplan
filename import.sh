#!/bin/bash

# Configuration
API_USER=system
API_KEY=d0ac9e1fb86ff9ec98234ee9434814483191cc7a6b754b1f1f368f0111bcd6ef 

MSACCESS_DATABASE='mdb/Kurs.mdb'
SQLITE_DATABASE='data.sqlite'

TZ="Europe/Berlin"
LANG="de_DE.UTF-8"
DATE=`date +"%A %x %X Uhr"`


# Do not touch the contents below unless you know what you're doing


set -e  # abort immediately once a command exits with nonzero return value

GREEN='\033[1;32m'
NC='\033[0m'

# Create SQLite3 database beforehand
# Install using `sudo apt install sqlite3`

# Export schemas of all tables in database file
echo -e "${GREEN}Exporting schema${NC}"
mdb-schema $MSACCESS_DATABASE sqlite > sql/schema.sql

echo -e "${GREEN}Exporting tables${NC}"
for table in $( mdb-tables $MSACCESS_DATABASE ); do
	echo "$table";
	mdb-export -D "%Y-%m-%d %H:%M:%S" -I sqlite $MSACCESS_DATABASE $table > sql/$table.sql;
done

echo -e "${GREEN}Creating schema${NC}"
sqlite3 $SQLITE_DATABASE < sql/schema.sql

echo -e "${GREEN}Importing table Bardienst${NC}"
sqlite3 $SQLITE_DATABASE < sql/Bardienst.sql

echo -e "${GREEN}Importing table Mitarbeiter${NC}"
sqlite3 $SQLITE_DATABASE < sql/Mitarbeiter.sql

echo -e "${GREEN}Importing table Kurse${NC}"
sqlite3 $SQLITE_DATABASE < sql/Kurse.sql

echo -e "${GREEN}Importing table Ereignis${NC}"
sqlite3 $SQLITE_DATABASE < sql/Ereignis.sql


echo -e "${GREEN}Generate HTML output via SQLite${NC}"
sqlite3 -batch $SQLITE_DATABASE <<- EOF
.mode html
.output output.html
.read schichtplan.sql
EOF


echo -e "${GREEN}Render output through template.html${NC}"
PAYLOAD=payload.html

# Render HTML table
# The newline is very important here!
sed '/\${table_content}/{r output.html
    d;}' template.html > $PAYLOAD


# Add timestamp to payload
sed -i "s@<!-- timestamp -->@$DATE@" $PAYLOAD

# Update posting on Discourse
POST_ID=81

echo -e "${GREEN}Delivering payload${NC}"
curl -X PUT -F api_username=$API_USER \
  -F api_key=$API_KEY \
  -F post[raw]="`cat $PAYLOAD`" \
  https://intern.ostbloc.de/posts/$POST_ID

echo -e "${GREEN}Cleaning up${NC}"
rm output.html
rm $PAYLOAD
rm $SQLITE_DATABASE

echo -e "${GREEN}Done${NC}"
