PYTHON_VERSION := 3.11
PYTHON := python$(PYTHON_VERSION)
ANSIBLE_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
VENV_DIR := $(ANSIBLE_DIR).venv
PKG_DIR := .venv/lib/$(PYTHON)/site-packages

.venv/bin/python:
	$(PYTHON) -m venv .venv

$(PKG_DIR)/%: .venv/bin/python
	$(VENV_DIR)/bin/pip install $*

inventory/static_inventory.yml: $(PKG_DIR)/boto3 $(PKG_DIR)/pyyaml
	$(VENV_DIR)/bin/python inventory/dynamic_inventory.py --generate >inventory/static_inventory.yml

.PHONY: inventory/static_inventory.yml
