#!/bin/bash

# Configuration
API_USER=system
API_KEY=
MSACCESS_DATABASE='mdb/Kurs.mdb'
SQLITE_DATABASE='data.sqlite'

# Do not touch the contents below unless you know what you're doing

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
#sqlite3 $SQLITE_DATABASE < sql/schema.sql

echo -e "${GREEN}Importing table Bardienst${NC}"
#sqlite3 $SQLITE_DATABASE < sql/Bardienst.sql

echo -e "${GREEN}Importing table Mitarbeiter${NC}"
#sqlite3 $SQLITE_DATABASE < sql/Mitarbeiter.sql

echo -e "${GREEN}Importing table Kurse${NC}"
#sqlite3 $SQLITE_DATABASE < sql/Kurse.sql

echo -e "${GREEN}Importing table Ereignis${NC}"
#sqlite3 $SQLITE_DATABASE < sql/Ereignis.sql


echo -e "${GREEN}Generate output for Kurse${NC}"
sqlite3 -batch $SQLITE_DATABASE <<- EOF
.mode html
.output kurse.output.html
.read kurse.sql
EOF

echo -e "${GREEN}Generate output for Bardienst${NC}"
sqlite3 -batch $SQLITE_DATABASE <<- EOF
.mode html
.output bardienst.output.html
.read bardienst.sql
EOF

echo -e "${GREEN}Modifying output${NC}"
PAYLOAD=payload.html

# Render HTML table
sed '/\${table_content_kurse}/{r kurse.output.html
    d;};
    /\${table_content_bardienst}/{r bardienst.output.html
    d;}' template.html > $PAYLOAD
rm $TMP_OUTPUT

# Add timestamp to payload
sed -i "s/{{ timestamp }}/$(date)/g" $PAYLOAD

# Update posting on Discourse
POST_ID=81
BODY=`cat $PAYLOAD`

echo -e "${GREEN}Delivering payload${NC}"
curl -X PUT \
	-d "api_username=$API_USER" \
	-d "api_key=$API_KEY" \
	-d "post[raw]=$BODY" \
	https://intern.ostbloc.de/posts/$POST_ID

echo -e "${GREEN}Cleaning up${NC}"
rm $PAYLOAD
rm $SQLITE_DATABASE

echo -e "${GREEN}Done${NC}"
