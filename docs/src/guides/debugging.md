sometimes you may want to debug the flake. one easy way to do this is to enter
the nix repl. from there you can load the flake using `:lf`. and start
debugging with [`nix-select`](https://clan.lol/blog/nix-select/).

```console
nix-repl> :lf

nix-repl> select = (builtins.getFlake "github:clan-lol/select").lib.select

nix-repl> select "*.config.boot.swraid.enable" nixosConfigurations
```
