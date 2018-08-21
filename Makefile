SHELL := /usr/bin/env bash

NIXOPS  ?= $(shell which nixops)
COMMIT  ?= $(shell grep 'commit' nixpkgs.json | cut -d '"' -f4)
NIXPKGS ?= https://github.com/NixOS/nixpkgs/archive/$(COMMIT).tar.gz

CREATE  ?= -I nixpkgs=$(NIXPKGS)
DEPLOY  ?= --option system x86_64-linux --kill-obsolete --allow-reboot
DESTROY ?= --confirm
DELETE  ?=

.PHONY: create-vbox delete-vbox
.DEFAULT_GOAL := help

help: ## Print this message and exit
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%16s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST)


create-vbox: create-%: create_%  ## Create a VirtualBox deployment.
delete-vbox: delete-%: delete_%  ## Delete an existing VirtualBox deployment.


create_%: not_exists_%
	@$(NIXOPS) create --deployment "ota-$*" $(CREATE) nix/$*
	@$(NIXOPS) deploy --deployment "ota-$*" $(DEPLOY)

delete_%: exists_%
	@$(NIXOPS) destroy --deployment "ota-$*" $(DESTROY)
	@$(NIXOPS) delete  --deployment "ota-$*" $(DELETE)


exists_%: cmd_nixops # Check that a previous deployment exists
	@: $(if $(shell $(NIXOPS) list | grep "ota-$*"),, $(error "ota-$*" deployment not found))

not_exists_%: cmd_nixops # Check that a deployment doesn't already exist
	@: $(if $(shell $(NIXOPS) list | grep "ota-$*"), $(error "ota-$*" deployment already exists))

cmd_%: # Check that a command exists.
	@: $(if $(shell command -v $* 2>/dev/null),, $(error Please install "$*" first))
