The user side is configured in `/home/<user>`.

To set up a user configuration it must be declared in
`/modules/base/users/options.nix` and `/modules/base/users/<user>.nix` can be used for anything that is not preconfigured by `/modules/base/users/mkusers.nix`.
