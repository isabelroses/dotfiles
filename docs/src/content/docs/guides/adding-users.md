---
title: Adding users
description: How to declare a new user in this flake.
---

The user side is configured in `/home/<user>`.

Add the username to the `garden.system.users` list (defined at `/modules/base/users/options.nix`). `/modules/base/users/<user>.nix` can be used for anything that is not preconfigured by `/modules/base/users/mkuser.nix` (such as the user's SSH keys). You'll also want to add a hashed password generated from `mkpasswd` to `/modules/nixos/users/<user>.nix`.

You should also add your user into the `users.nix` file for your system, following this template:

```nix
{
  garden.system = {
    mainUser = "kitty";
    users = [ "kitty" ];
  };

  # you can add a home-manager configuration here for the user if it needs
  # anything special
  home-manager.users.kitty.garden = {};
}
```
