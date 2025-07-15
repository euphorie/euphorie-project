.PHONY: all
all: .installed.cfg
	@if [ -d py3 ]; then \
		echo "You have a py3 virtualenv in this directory. Please remove it as we are now using .venv."; \
		echo "Run 'rm -rf py3' to remove it."; \
	fi

.venv/bin/pip:
	python3 -m venv .venv

.venv/bin/buildout: .venv/bin/pip requirements.txt
	./.venv/bin/pip uninstall -qy setuptools
	./.venv/bin/pip install -qIUr requirements.txt

buildout_cfgs := $(wildcard *.cfg config/*.cfg profiles/*.cfg)
.installed.cfg: .venv/bin/buildout $(buildout_cfgs)
	./.venv/bin/buildout

.PHONY: upgrade
upgrade:
	./bin/upgrade plone_upgrade -A &&  ./bin/upgrade install -Ap

.PHONY: clean
clean:
	rm -rf ./.venv

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
