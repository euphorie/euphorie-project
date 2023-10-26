.PHONY: all
all: .installed.cfg

py3/bin/pip:
	python3 -m venv py3

py3/bin/buildout: py3/bin/pip requirements.txt
	./py3/bin/pip uninstall -qy setuptools
	./py3/bin/pip install -qIUr requirements.txt

buildout_cfgs := $(wildcard *.cfg config/*.cfg profiles/*.cfg)
.installed.cfg: py3/bin/buildout $(buildout_cfgs)
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
alembic-history: .installed.cfg
	./bin/alembic --config etc/alembic.ini history

.PHONY: alembic-revision
alembic-revision: .installed.cfg
	./bin/alembic --config etc/alembic.ini revision --autogenerate

.PHONY: alembic-upgrade
alembic-upgrade: .installed.cfg
	./bin/alembic --config etc/alembic.ini upgrade head

.PHONY: restart
restart:
	./bin/supervisord 2> /dev/null || ( ./bin/supervisorctl reread && ./bin/supervisorctl restart all)

.PHONY: graceful
graceful: .installed.cfg
	./bin/supervisord 2> /dev/null || ( \
		./bin/supervisorctl reread && \
		./bin/supervisorctl update && \
		for process in `./bin/supervisorctl status|grep -v instance|awk '{print $$1}'`; do \
			./bin/supervisorctl restart "$$process" && \
			sleep 30; \
		done; \
		for process in `./bin/supervisorctl status|grep instance|awk '{print $$1}'`; do \
			./bin/supervisorctl restart "$$process" && \
			sleep 30; \
		done \
	)
