#!/usr/bin/env bash

ovn-nbctl ls-add network1
ovn-nbctl lsp-add network1 vm1
ovn-nbctl lsp-set-addresses vm1 "40:44:00:00:00:01 192.168.0.11"
ovn-nbctl lsp-add network1 vm2
ovn-nbctl lsp-set-addresses vm2 "40:44:00:00:00:02 192.168.0.12"

ovn-nbctl ls-add network2
ovn-nbctl lsp-add network2 child1 vm1 30
ovn-nbctl lsp-set-addresses child1 "40:44:00:00:00:03 192.168.1.13"
ovn-nbctl lsp-add network2 child2 vm2 50
ovn-nbctl lsp-set-addresses child2 "40:44:00:00:00:04 192.168.1.14"
