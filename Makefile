.PHONY: all
all: .installed.cfg

py3/bin/pip3.8:
	python3.8 -m venv py3

py3/bin/buildout: py3/bin/pip3.8 requirements.txt
	./py3/bin/pip3.8 uninstall -qy setuptools
	./py3/bin/pip3.8 install -qIUr requirements.txt

.installed.cfg: py3/bin/buildout $(wildcard *.cfg config/*.cfg profiles/*.cfg)
	./py3/bin/buildout

.PHONY: upgrade
upgrade:
	./bin/upgrade plone_upgrade -S &&  ./bin/upgrade install -Sp

.PHONY: clean
clean:
	rm -rf ./py3

.PHONY: read_registry
read_registry: .installed.cfg
	./bin/instance run scripts/read_registry.py etc/registry/*.xml

.PHONY: alembic-history
alembic-history:
	./bin/alembic --config etc/alembic.ini history

.PHONY: alembic-revision
alembic-revision:
	./bin/alembic --config etc/alembic.ini revision --autogenerate

.PHONY: alembic-upgrade
alembic-upgrade:
	./bin/alembic --config etc/alembic.ini upgrade head
