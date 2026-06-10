---
title: Style
description: Code style and conventions for this flake.
---

## Introduction

When writing a module, you should follow these guidelines:

### Module Headers

Use a tree-like structure for the head lambda args if and only if it is needed.

```nix
{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # omitted config
}
```

### File Structure

Every use of `imports` should make a good attempt not to use `../`, i.e. going
up in the file structure. I would like to have a simple file structure and this
helps achieve that.

### Options

All options this flake defines live under the `garden` namespace, grouped by
subcategories (e.g. `garden.services.*`, `garden.system.*` and
`garden.profiles.*`). This keeps what we define cleanly separated from upstream
module options.

Following [RFC
42](https://github.com/NixOS/rfcs/blob/master/rfcs/0042-config-option.md), keep
options minimal, through the use of freeform `settings` attrset backed by
`pkgs.formats`. For an example see `modules/home/programs/discord.nix`.

### Lib usage

Be as specific as possible when reaching into `lib`. Prefer
`lib.options.mkOption` over `lib.mkOption`, and pull the functions you use into
a `let..in` with `inherit` rather than qualifying them inline:

```nix
let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
in
```

#### Garden Lib

On occasion you may find yourself repeating code. This is why I expose `lib`.
Within the config this is accessible via `self.lib`. Some uses of this currently include:

- `mkServiceOption` declares the usual `enable`/`host`/`port`/`domain` options
  for a service.
- `mkSecret` wires up a `sops` secret from `secrets/services/`.

### Pipe operator

The pipe operator (`|>`, [RFC 148](https://github.com/NixOS/rfcs/pull/148)). I
have intentions to use this at some point.

### Formatting

Just run `nix fmt` or `treefmt` thanks.

### Documenting lib

Reusable functions in `lib` carry a nixdoc comment with their arguments and
type signature. Match the existing entries in `modules/flake/lib/` when adding
one.

This form is the doc-comment standard from [RFC
145](https://github.com/NixOS/rfcs/blob/master/rfcs/0145-doc-strings.md): the
and the body is CommonMark with `# Arguments` and `# Type` sections. That
CommonMark choice comes from [RFC
72](https://github.com/NixOS/rfcs/blob/master/rfcs/0072-commonmark-docs.md),
which is also why option `description`s and these generated pages are written
in Markdown.
