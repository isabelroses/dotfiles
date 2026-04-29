---
title: Lix
description: Why and how this flake uses Lix.
---

I use [Lix](https://git.lix.systems/lix-project/lix).

:::note
Furthermore this is with a custom patch set through [izlix](https://github.com/isabelroses/izlix). I don't recommend using izlix. If you want the patches you may copy them for personal use.
:::

This flake makes a point of using Lix where possible. The package is wired up directly in [`modules/base/nix/nix.nix`](https://github.com/isabelroses/dotfiles/blob/main/modules/base/nix/nix.nix) via:

```nix
nix.package = inputs'.izlix.packages.lix;
```

If you'd rather use upstream Lix without my patches, swap `izlix` for the `lix-module`/`lix` flake of your choice.
