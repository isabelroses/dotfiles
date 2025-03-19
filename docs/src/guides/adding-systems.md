The systems are configured in `/systems/<hostname>`.

To set up a system configuration it must be declared in `/systems/default.nix`.

- arch:

  - default: "x86_64"
  - options: "x86_64", "aarch64"

- class:

  - default: "nixos"
  - options: "nixos", "darwin", "iso", "wsl"

- system:

  - default: `constructSystem config.easyHosts.hosts.<hostname>.target config.easy-hosts.hosts.<hostname>.arch`
  - note: This is a function that constructs the system configuration, it will make `x86_64-linux` by from the `target` and `arch` attributes or `aarch64-darwin`

- deployable:

  - default: false

- modules:

  - default: "[ ]"
  - options:

- specialArgs:
  - default: "{ }"

> [!TIP]
> Please consult [easy-hosts](https://github.com/isabelroses/easy-hosts) for more information on how to set up a system configuration.
