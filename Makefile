SHELL := /usr/bin/env bash

DEPLOY  ?= vbox
STATE   ?= state.nixops
COMMIT  ?= $(shell nix eval --raw '(import nix/nixpkgs/versions.nix).nixpkgs.rev')
NIXPKGS ?= https://github.com/NixOS/nixpkgs/archive/$(COMMIT).tar.gz
INCLUDE ?= -I nixpkgs=$(NIXPKGS) $(APPEND)
NIXOPS  ?= --deployment $(DEPLOY) --state $(STATE) $(INCLUDE)

.PHONY: list start stop create deploy destroy delete shell vmdk cmd_nixops
.DEFAULT_GOAL := help

help: ## Print this message.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%12s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST)


### Public targets

list:  %: nixops_%  ## List all created deployments.
start: %: exists_$(DEPLOY) nixops_%  ## Start a previously stopped deployment.
stop:  %: exists_$(DEPLOY) nixops_%  ## Stop a currently running deployment.

create: not_exists_$(DEPLOY)  ## Create a new deployment template.
	@nixops create nix/deploy/$(DEPLOY).nix $(NIXOPS)

deploy: exists_$(DEPLOY)  ## Provision resources from a created template.
	@nixops deploy $(NIXOPS) --kill-obsolete --allow-reboot

destroy: exists_$(DEPLOY)  ## Destroy all data and provisioned resources.
	@nixops destroy $(NIXOPS) --confirm

delete: %: nixops_%  ## Delete a created deployment template.

shell: cmd_nix-shell  ## Start a Nix shell.
	@nix-shell --pure --argstr deploy $(DEPLOY) --argstr state $(STATE)

build-qcow: build-%: build_%   ## Build a QCOW2 OTA image.
build-vmdk: build-%: build_%   ## Build a VMDK OTA image.


### Auxiliary targets

nixops_%: cmd_nixops # Run a NixOps command.
	@nixops $* $(NIXOPS)

build_%: cmd_nix-build # Build an image.
	@nix-build $(INCLUDE) nix/images/$*.nix

exists_%: cmd_nixops # Check that a deployment exists.
	@$(if $(shell nixops list $(NIXOPS) | grep $(DEPLOY)),, $(error $(DEPLOY) deployment not found))

not_exists_%: cmd_nixops # Check that no deployment exists.
	@$(if $(shell nixops list $(NIXOPS) | grep $(DEPLOY)), $(error $(DEPLOY) deployment already exists))

cmd_%: # Check that a command exists.
	@$(if $(shell command -v $* 2>/dev/null),, $(error Please install "$*" first))
