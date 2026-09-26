# A simple buildout to run Euphorie

## Installation

1. You need to add a custom.cfg file to the buildout root directory.
   This file should contains something like:

```ini
[settings]
main-package = your.euphorie.flavour
```
For convenience, ``config/custom.cfg`` provides a working custom.cfg you can copy.

2. Create a buildout.cfg, you can symlink one in the `profiles` folder, e.g.:

```bash
ln -s profiles/development.cfg buildout.cfg
```

3. Run `make`

## Setup alembic table on a fresh DB:

```console
# Creates the table if missing
./bin/alembic --config etc/alembic.ini ensure_version
# Sets the last version
./bin/alembic --config etc/alembic.ini stamp `./bin/alembic --config etc/alembic.ini heads|awk '{print $1}'`
```
