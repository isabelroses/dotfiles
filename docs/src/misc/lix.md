This flake makes a point of using lix where possible.

To do so we add the following snippet taken from [modules/base/nix/overlays/default.nix](https://github.com/isabelroses/dotfiles/blob/63a58bee7e7273c82a4c502cac64bcfb68b8e54f/modules/base/nix/overlays/default.nix#L13-L23).
What this does is use lix where possible rather than nix.

```nix
_: prev: {
  # in order to reduce our closure size, we can override these packages to
  # use the nix package that we have installed, this will trigget a rebuild
  # of the packages that depend on them so hopefully its worth it for that
  # system space
  nixVersions.stable = config.nix.package;

  # make sure to restore nix for linking back to nix from nixpkgs as its
  # used for other things then the cli implementaion
  nixForLinking = prev.nixVersions.stable;
}
```

Futhermore, I add the following patches:

- [callpackage cli](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/packages/lix/patches/lix-callpackage-cli.patch) - a patch to add `-C` to `nix build` to allow you to build a package from a file.
- [abs builtin](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/packages/lix/patches/lix-feat-builtins-abs.patch) - adds the `abs` builtin
- [greaterThan builtin](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/packages/lix/patches/lix-feat-builtins-greaterThan.patch) - adds the `greaterThan` builtin
- [pow builtin](https://github.com/isabelroses/dotfiles/blob/main/modules/flake/packages/lix/patches/lix-feat-builtins-pow.patch) - adds the `pow` builtin

None of the patches should be used in production code but are nice to have.
