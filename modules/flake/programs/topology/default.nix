{ inputs, ... }:
{
  imports = [ inputs.nix-topology.flakeModule ];

  # nix build .#topology.x86_64-linux.config.output
  perSystem.topology.modules = [ ./output.nix ];
}
