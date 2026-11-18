# A simple buildout to run Euphorie

## Installation

This repository supports both Buildout and plonex. Choose one of the following
methods. Buildout is the default for `make`.

### Buildout

1. Create `custom.cfg` in the project root with your local settings, for example:

   ```ini
   [settings]
   main-package = your.euphorie.flavour
   saconfig-uri = postgresql://user@localhost:5432/database
   sqlalchemy_echo = false

   [instance]
   http-address = 9080
   ```

2. Create `buildout.cfg`, for example by linking to the development profile:

   ```bash
   ln -s profiles/development.cfg buildout.cfg
   ```

3. Run `make`.

### plonex

The shared configuration is in `etc/plonex.yml`. Put machine-specific settings
in the ignored `etc/plonex.local.yml`, for example:

```yaml
main_package: your.euphorie.flavour
saconfig_uri: postgresql://user@localhost:5432/database
sqlalchemy_echo: false
http_port: 9080
```

These settings correspond to `main-package`, `saconfig-uri`, and
`sqlalchemy_echo` in Buildout’s `[settings]` section, and `http-address` in
its `[instance]` section. The shared `pip_requirements` installs the configured
`main_package`; do not repeat it in `+pip_requirements`.

To install a package from a source checkout, translate its Buildout `[sources]`
entry to a plonex `sources` entry, for example:

```yaml
sources:
  your.euphorie.flavour:
    repo: https://example.com/your.euphorie.flavour.git
    rev: main
    install: true
```

Review the configuration, then run `plonex project init`
and `make -f Makefile.plonex`.

Plonex profiles live beside the Buildout profiles under
`profiles/<name>/etc/plonex.yml`. The root configuration selects `default`
(a ZEO server and one instance); use `profiles/zeo` for a ZEO-only server.
Both extend `profiles/common` and pinned `base` and `zeo` profiles from
[plonex-profiles](https://github.com/collective/plonex-profiles). Plonex
clones the remote profiles into `var/cache/profiles` on first use. Update the
commit in the local profile files together to upgrade the shared profiles.

The plonex template service renders `etc/alembic.ini` when compiling the
project or starting an instance. Run `plonex project compile` to refresh it
after changing settings; the plonex Alembic Make targets do this automatically.

## Setup alembic table on a fresh DB:

```console
# Creates the table if missing
./bin/alembic --config etc/alembic.ini ensure_version
# Sets the last version
./bin/alembic --config etc/alembic.ini stamp `./bin/alembic --config etc/alembic.ini heads|awk '{print $1}'`
```
