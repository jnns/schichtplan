# Description

This script copies schedules from an old MS Access `mdb` file to a Discourse installation.

# Installation

Install mdbtools and sqlite3

	apt install mdbtools sqlite3

Add German locale for proper date formatting

    dpgk-reconfigure locales  # check de_DE.UTF_8 in menu

Clone the repository with the script

    git clone git@github.com:jnns/schichtplan.git /var/schichtplan

Create a user for the sole purpose of transferring the mdb file to the script
host

    useradd --no-create-home --no-user-group -R /var/schichtplan
    passwd schichtplan
    chown schichtplan /var/schichtplan -R

Create both an `./mbd` and `./sql` directory for storing the MDB database file
and the generated import queries respectively.

Add the script to `cron`

    crontab -e
    TZ="Europe/Berlin"
    LANG=de_DE.UTF-8
    00 23 * * * /var/schichtplan/import.sh >>/var/schichtplan/cron.log 2>&1

Update the API_KEY and POST_ID in `import.sh` and then run the script:

	$ chmod +x import.sh
    $ ./import.sh