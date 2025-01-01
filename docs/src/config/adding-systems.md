The systems are configured in `/systems/<hostname>`.

To set up a system configuration it must be declared in `/systems/default.nix`.

- arch:

  - default: "x86_64"
  - options: "x86_64", "aarch64"

- target:

  - default: "nixos"
  - options: "nixos", "darwin", "iso"

- system:

  - default: `constructSystem config.hosts.<hostname>.target config.hosts.<hostname>.arch`
  - note: This is a function that constructs the system configuration, it will make `x86_64-linux` by from the `target` and `arch` attributes or `aarch64-darwin`

- deployable:

  - default: false

- modules:

  - default: "[ ]"
  - options:
    - laptop: for laptop type configurations
    - desktop: for desktop type configurations
    - server: for server type configurations
    - wsl: for wsl systems
    - gaming: for systems that have a graphical interface
    - headless: for systems that do not have a graphical interface

- specialArgs:
  - default: "{ }"
