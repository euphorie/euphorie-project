PYTHON ?= python3
BUILDOUT_CFGS := $(wildcard *.cfg config/*.cfg profiles/*.cfg)

.PHONY: all
all: .installed.cfg

.venv/bin/pip:
	$(PYTHON) -m venv .venv

.venv/bin/uv: .venv/bin/pip constraints.txt
	.venv/bin/pip install -q uv -c constraints.txt

.venv/bin/buildout: .venv/bin/uv requirements.txt constraints.txt
	.venv/bin/uv pip install -qr requirements.txt -c constraints.txt

.installed.cfg: .venv/bin/buildout $(BUILDOUT_CFGS)
	./.venv/bin/buildout

.PHONY: upgrade
upgrade:
	./bin/upgrade plone_upgrade -A
	./bin/upgrade install -Ap

.PHONY: clean
clean:
	rm -rf .venv
	rm -f .installed.cfg

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
restart: .installed.cfg
	@if ./bin/supervisorctl status >/dev/null 2>&1; then \
		./bin/supervisorctl reread && \
		./bin/supervisorctl update && \
		./bin/supervisorctl restart all; \
	else \
		./bin/supervisord; \
	fi

.PHONY: graceful
graceful: .installed.cfg
	./bin/supervisord 2> /dev/null || ( \
		./bin/supervisorctl reread && \
		./bin/supervisorctl update && \
		for process in `./bin/supervisorctl status | grep -v instance | awk '{print $$1}'`; do \
			./bin/supervisorctl restart "$$process" || exit 1; \
			sleep 30; \
		done; \
		for process in `./bin/supervisorctl status | grep instance | awk '{print $$1}'`; do \
			./bin/supervisorctl restart "$$process" || exit 1; \
			sleep 30; \
		done \
	)
