In the past this repo used to hold templates. Now the templates are located at
[tgirlcloud/nix-templates](https://github.com/tgirlcloud/nix-templates).
Overall the commands remain the same except for the repo to use.

- `nix flake init -t github:tgirlcloud/nix-templates#<template>` to initialize
  a new project with the template
- `nix flake new -t github:tgirlcloud/nix-templates#<template> <out dir>` to
  create a new project in the specified directory

For the full list of templates check the [nix-templates
repo](https://github.com/tgirlcloud/nix-templates) directory or run `nix flake
show github:tgirlcloud/nix-templates`.
