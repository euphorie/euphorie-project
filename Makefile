PLONE_CONSTRAINTS = https://raw.githubusercontent.com/collective/experimental-plone-pins/6e638bb633183649e28cc49b4f9902df833971c6/plone62-py311+/constraints.txt
PYTHON ?= python3.14
BUILDOUT_CFGS := $(wildcard *.cfg config/*.cfg profiles/*.cfg)

.PHONY: all
all: .installed.cfg

.venv/bin/pip:
	@if command -v uv >/dev/null 2>&1; then \
		uv venv --python=$(PYTHON) --seed; \
	elif command -v pipx >/dev/null 2>&1; then \
		pipx run uv venv --python=$(PYTHON) --seed; \
	else \
		$(PYTHON) -m venv .venv; \
	fi

.venv/bin/uv: .venv/bin/pip
	.venv/bin/pip install -q uv

.venv/bin/buildout: .venv/bin/uv requirements.txt
	.venv/bin/uv pip install -qr requirements.txt

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

.PHONY: update-pins
update-pins: .venv/bin/uv  ## Resolve and update Python and buildout pins
	mkdir -p tmp/update-pins
	.venv/bin/uv venv tmp/update-pins/.venv --seed --allow-existing;
	. tmp/update-pins/.venv/bin/activate && uv pip install uv -c "$(PLONE_CONSTRAINTS)"
	. tmp/update-pins/.venv/bin/activate && uv pip install --upgrade \
		-r profiles/packages.txt \
		-r "$(PLONE_CONSTRAINTS)"
	. tmp/update-pins/.venv/bin/activate && uv pip freeze > profiles/constraints.txt;
	./.venv/bin/uvx --from plone.releaser manage constraints2versions -p profiles/constraints.txt
	mv profiles/versions.cfg config/versions.cfg
