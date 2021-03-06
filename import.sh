#!/bin/bash

# Configuration
API_USER=system
API_KEY=d0ac9e1fb86ff9ec98234ee9434814483191cc7a6b754b1f1f368f0111bcd6ef 

# Discourse post id to update
POST_ID=81

MSACCESS_DATABASE='mdb/Kurs.mdb'
SQLITE_DATABASE='data.sqlite'
SQLITE_OUTPUT='output.csv'
PAYLOAD=payload.html

TZ="Europe/Berlin"
LANG="de_DE.UTF-8"
DATE=`date +"%A %x %X Uhr"`


# Do not touch the contents below unless you know what you're doing


GREEN='\033[1;32m'
NC='\033[0m'

# Create SQLite3 database beforehand
# Install using `sudo apt install sqlite3`

echo -e "${GREEN}Cleaning up${NC}"
rm $SQLITE_OUTPUT
rm $PAYLOAD
rm $SQLITE_DATABASE
rm sql/*  # remove generated sql dumps

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
.header on
.mode tabs
.output $SQLITE_OUTPUT
.read schichtplan.sql
EOF


echo -e "${GREEN}Render output through template.html${NC}"

# Render template
/var/schichtplan/.venv/bin/python render.py > $PAYLOAD

# The newline is very important here!
#sed '/\${table_content}/{r $SQLITE_OUTPUT
#    d;}' template.html > $PAYLOAD


# Add timestamp to payload
sed -i "s@<!-- timestamp -->@$DATE@" $PAYLOAD


echo -e "${GREEN}Delivering payload${NC}"
curl -X PUT -F api_username=$API_USER \
  -F api_key=$API_KEY \
  -F post[raw]="`cat $PAYLOAD`" \
  https://intern.ostbloc.de/posts/$POST_ID

echo -e "${GREEN}Done${NC}"
