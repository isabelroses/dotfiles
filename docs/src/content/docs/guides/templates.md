---
title: Templates
description: Where the flake templates have moved to and how to use them.
---

In the past this repo used to hold templates. Now the templates are located at
[extersia-org/nix-templates](https://github.com/extersia-org/nix-templates).
Overall the commands remain the same except for the repo to use.

- `nix flake init -t github:extersia-org/nix-templates#<template>` — initialize a new project with the template.
- `nix flake new -t github:extersia-org/nix-templates#<template> <out dir>` — create a new project in the specified directory.

For the full list of templates, check the [nix-templates
repo](https://github.com/extersia-org/nix-templates) directory or run `nix
flake show github:extersia-org/nix-templates`.
