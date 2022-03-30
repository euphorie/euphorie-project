# A simple buildout to run Euphorie


## Setup alembic table on a fresh DB:
```
# Creates the table if missing
./bin/alembic --config etc/alembic.ini ensure_version
# Sets the last version
./bin/alembic --config etc/alembic.ini stamp `./bin/alembic --config etc/alembic.ini heads|awk '{print $1}'`
```
