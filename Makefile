SHELL := /usr/bin/env bash

COMMIT  ?= $(shell nix eval --raw '(import nix/versions.nix).nixpkgs.rev')
NIXPKGS ?= https://github.com/NixOS/nixpkgs/archive/$(COMMIT).tar.gz

BUILD   ?= -I nixpkgs=$(NIXPKGS)
CREATE  ?= -I nixpkgs=$(NIXPKGS)
DEPLOY  ?= --kill-obsolete --allow-reboot
DESTROY ?= --confirm
DELETE  ?=


.PHONY: create-vbox delete-vbox
.DEFAULT_GOAL := help

help: ## Print this message.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%16s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST)

shell: cmd_nix-shell ## Start a Nix shell.
	@nix-shell nix/nixpkgs.nix --attr shell


create-vbox: create-%: build_vmdk create_%  ## Create a VirtualBox deployment.
delete-vbox: delete-%: delete_%             ## Delete an existing VirtualBox deployment.


create_%: not_exists_%
	@nixops create --deployment "ota-$*" $(CREATE) nix/$*
	@nixops deploy --deployment "ota-$*" $(DEPLOY)

delete_%: exists_%
	@nixops destroy --deployment "ota-$*" $(DESTROY)
	@nixops delete  --deployment "ota-$*" $(DELETE)

build_%: cmd_nix # Build a Nix derivation.
	@nix build nix/nixos/$*.nix $(BUILD)

exists_%: cmd_nixops # Check that a previous deployment exists
	@: $(if $(shell nixops list | grep "ota-$*"),, $(error "ota-$*" deployment not found))

not_exists_%: cmd_nixops # Check that a deployment doesn't already exist
	@: $(if $(shell nixops list | grep "ota-$*"), $(error "ota-$*" deployment already exists))

cmd_%: # Check that a command exists.
	@: $(if $(shell command -v $* 2>/dev/null),, $(error Please install "$*" first))
