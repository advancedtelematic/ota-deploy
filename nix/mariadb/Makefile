SHELL := /usr/bin/env bash

DEPLOY  ?= ota-mariadb
NIXOPS  ?= $(shell which nixops)
COMMIT  ?= d0c868ec17c2cb2ca845f33fbfe381e9c7e55516
NIXPKGS ?= https://github.com/NixOS/nixpkgs-channels/archive/$(COMMIT).tar.gz

.PHONY: vbox-create vbox-destroy
.DEFAULT_GOAL := help

help: ## Print this message and exit
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%16s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST)

vbox-create: %-create: create-%     ## Deploy MariaDB to VirtualBox.
vbox-destroy: %-destroy: destroy-%  ## Destroy an existing VirtualBox deployment.

create-%: cmd-nixops
	@$(if $(shell $(NIXOPS) list | grep "$(DEPLOY)-$*"), $(error "$(DEPLOY)-$*" deployment already exists))
	@$(NIXOPS) create -d "$(DEPLOY)-$*" -I nixpkgs=$(NIXPKGS) deploy.nix $*.nix
	@$(NIXOPS) deploy -d "$(DEPLOY)-$*" --option system x86_64-linux --kill-obsolete --allow-reboot

destroy-%: cmd-nixops
	@$(if $(shell $(NIXOPS) list | grep "$(DEPLOY)-$*"),, $(error "$(DEPLOY)-$*" deployment not found))
	@$(NIXOPS) destroy -d "$(DEPLOY)-$*" --confirm
	@$(NIXOPS) delete -d "$(DEPLOY)-$*"

cmd-%: # Check that a command exists.
	@: $(if $(shell command -v $* 2>/dev/null),,$(error Please install "$*" first))
