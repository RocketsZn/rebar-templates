##
## - WARNING -
##
## Do not edit this file if possible.
## project.mk is meant to be common for all services.
## It's better to change Makefile instead.
## If you really need to change this file, consider
## making the change generic and update the file in
## rebar-templates as well:
## https://github.com/EchoTeam/rebar-templates/blob/master/service_project.mk
##

.PHONY: all compile test clean target generate rel
.PHONY: update-lock get-deps update-deps
.PHONY: run upgrade upgrade-from

REBAR_BIN := $(abspath ./)/rel/../rebar # "rel/../" is a workaround for rebar bug
ifeq ($(wildcard $(REBAR_BIN)),)
	REBAR_BIN := $(shell which rebar)
endif
REBAR_FREEDOM := $(REBAR_BIN) -C rebar.config
REBAR_LOCKED  := $(REBAR_BIN) -C rebar.config.lock skip_deps=true
REBAR := $(REBAR_FREEDOM)

DEFAULT_LOG_DIR  := /var/log/$(SERVICE_NAME)
DEV_LOG_DIR      := $(abspath ./rel/$(SERVICE_NAME)/log)

all: compile

compile:
	$(REBAR) compile
	
update-lock:
ifdef apps
	@echo "Updating rebar.config.lock for $(apps)..."
	$(eval apps_list = $(shell echo $(apps) | sed 's/,/ /g'))
	@for app in $(apps_list); do \
		rmcmd="rm -rI ./deps/$$app"; \
		echo "WARNING: Make sure you don't have code left to push in ./deps/$$app directory."; \
		echo $$rmcmd; \
		echo `[ -d ./deps/$$app ] && $$rmcmd`; \
	done
	$(REBAR_FREEDOM) get-deps
else
	$(REBAR_FREEDOM) update-deps
endif
	$(MAKE) compile # compiling to make lock-deps available
	$(REBAR_FREEDOM) lock-deps skip_deps=true keep_first=lager,echo_rebar_plugins

get-deps:
	$(REBAR_LOCKED) get-deps

update-deps:
	$(REBAR_LOCKED) update-deps ignore_deps=true

rel:
	$(MAKE) -C rel LOG_DIR="$(LOG_DIR)"

generate: compile rel
	$(eval relvsn := $(shell bin/relvsn-get.erl))
	cd rel; $(REBAR_BIN) generate -f
	cp rel/$(SERVICE_NAME)/releases/$(relvsn)/$(SERVICE_NAME).boot rel/$(SERVICE_NAME)/releases/$(relvsn)/start.boot #workaround for rebar bug
	echo $(relvsn) > rel/$(SERVICE_NAME)/relvsn

clean:
	$(REBAR) clean
	rm -rf rel/$(SERVICE_NAME)*

test:
	$(REBAR) eunit skip_deps=meck,lager

# make target system for production
target: clean update-deps
	$(MAKE) generate LOG_DIR="$(DEFAULT_LOG_DIR)"


######################################
## All targets below are for use    ##
## in development environment only. ##
######################################

# generates upgrade upon what is in rel/$(SERVICE_NAME)
upgrade:
	@[ -f rel/$(SERVICE_NAME)/relvsn ] || (echo "Run 'make target' first" && exit 1)
	$(eval prev_vsn := $(shell cat rel/$(SERVICE_NAME)/relvsn))
	-rm -rf rel/$(SERVICE_NAME)_$(prev_vsn)
	mv rel/$(SERVICE_NAME) rel/$(SERVICE_NAME)_$(prev_vsn)
	$(MAKE) generate LOG_DIR="$(DEV_LOG_DIR)"
	cd rel; $(REBAR_BIN) generate-upgrade previous_release=$(SERVICE_NAME)_$(prev_vsn)

# generate upgrade upon a specific git revision
upgrade-from: clean
	$(eval cur_rev := $(shell git rev-parse --abbrev-ref HEAD))
	git checkout $(rev)
	$(MAKE) target LOG_DIR="$(DEV_LOG_DIR)"
	git checkout $(cur_rev)
	$(MAKE) upgrade LOG_DIR="$(DEV_LOG_DIR)"

# runs the service
run: get-deps
	$(MAKE) generate LOG_DIR="$(DEV_LOG_DIR)"
	./rel/$(SERVICE_NAME)/bin/$(SERVICE_NAME) -u `whoami` -l "$(DEV_LOG_DIR)" console -s sync
