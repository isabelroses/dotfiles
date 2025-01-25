The user side is configured in `/home/<user>`.

To set up a user configuration it must be declared in
`/modules/base/users/options.nix` and `/modules/base/users/<user>.nix` can be
used for anything that is not preconfigured by
`/modules/base/users/mkusers.nix`.

You should also add your user into the `users.nix` file for your system. Whilst
following the template:

```nix
{
  garden.system = {
    mainUser = "robin";
    users = [ "robin" ];
  };

  # you can add a home-manager configuration here for the user if it needs
  # anything special
  home-manager.users.robin.garden = {};
}
```
