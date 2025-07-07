I use [lix](https://git.lix.systems/lix-project/lix).

> [!NOTE]
> Furthermore this is with a custom
patch set through [izlix](https://github.com/isabelroses/izlix). Though I don't
recommend using izlix. If you want the patches you may copy them for personal
use.

This flake makes a point of using lix where possible.

To do so we add the following snippet taken from [modules/base/nix/overlays/default.nix](https://github.com/isabelroses/dotfiles/blob/463e509725f610d802c483fdc00ce0b77cd778c2/modules/base/nixpkgs/overlays/default.nix#L13-L25).
What this does is use lix where possible rather than nix.

```nix
_: prev: {
  # in order to reduce our closure size, we can override these packages to
  # use the nix package that we have installed, this will trigget a rebuild
  # of the packages that depend on them so hopefully its worth it for that
  # system space
  nixVersions = prev.nixVersions // {
    stable = config.nix.package;
  };

  # make sure to restore nix for linking back to nix from nixpkgs as its
  # used for other things then the cli implementaion
  nixForLinking = prev.nixVersions.stable;
}
```
