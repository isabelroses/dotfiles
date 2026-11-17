---
title: Debugging
description: How to debug the config using the Nix REPL.
---

Sometimes you may want to debug the config. One easy way to do this is to enter the Nix REPL. From there you can load `default.nix` using `nix repl --expr 'import ./default.nix { }'` (or `just repl-host <host>` for a single host), and start debugging with [`nix-select`](https://clan.lol/blog/nix-select/).

```console
$ nix repl --expr 'import ./default.nix { }'

nix-repl> select = (builtins.getFlake "github:clan-lol/select").lib.select

nix-repl> select "*.config.boot.swraid.enable" hosts
```
