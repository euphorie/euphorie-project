.PHONY: all
all: .installed.cfg

py38/bin/pip3.8:
	python3.8 -m venv py38

py38/bin/buildout: py38/bin/pip3.8 requirements.txt
	./py38/bin/pip3.8 install -IUr requirements.txt

.installed.cfg: py38/bin/buildout $(wildcard *.cfg config/*.cfg profiles/*.cfg)
	./py38/bin/buildout

.PHONY: upgrade
upgrade:
	./bin/upgrade plone_upgrade -S &&  ./bin/upgrade install -Sp

.PHONY: clean
clean:
	rm -rf ./py38

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
