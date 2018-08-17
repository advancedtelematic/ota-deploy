SHELL := /usr/bin/env bash

DEPLOY  ?= vbox
NIXOPS  ?= $(shell which nixops)
COMMIT  ?= $(shell grep 'commit' nixpkgs.json | cut -d '"' -f4)
NIXPKGS ?= https://github.com/NixOS/nixpkgs/archive/$(COMMIT).tar.gz

.PHONY: create-kafka delete-kafka create-db destory-db create-kube delete-kube
.DEFAULT_GOAL := help

help: ## Print this message and exit
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%16s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST)


create-kafka: create-%: create_%  ## Create a new Kafka deployment.
delete-kafka: delete-%: delete_%  ## Delete an existing Kafka deployment.

create-mariadb: create-%: create_%  ## Create a new MariaDB deployment.
delete-mariadb: delete-%: delete_%  ## Delete an existing MariaDB deployment.

create-kube: create-%: create_%   ## Create a new Kubernetes deployment.
delete-kube: delete-%: delete_%   ## Delete an existing Kubernetes deployment.


create_%: not_exists_%
	@$(NIXOPS) create -d "$(DEPLOY)-$*" -I nixpkgs=$(NIXPKGS) nix/$*/deploy.nix nix/$*/$(DEPLOY).nix
	@$(NIXOPS) deploy -d "$(DEPLOY)-$*" --option system x86_64-linux --kill-obsolete --allow-reboot

delete_%: exists_%
	@$(NIXOPS) destroy -d "$(DEPLOY)-$*" --confirm
	@$(NIXOPS) delete  -d "$(DEPLOY)-$*"


exists_%: cmd_nixops # Check that a previous deployment exists
	@: $(if $(shell $(NIXOPS) list | grep "$(DEPLOY)-$*"),, $(error "$(DEPLOY)-$*" deployment not found))

not_exists_%: cmd_nixops # Check that a deployment doesn't already exist
	@: $(if $(shell $(NIXOPS) list | grep "$(DEPLOY)-$*"), $(error "$(DEPLOY)-$*" deployment already exists))

cmd_%: # Check that a command exists.
	@: $(if $(shell command -v $* 2>/dev/null),, $(error Please install "$*" first))
