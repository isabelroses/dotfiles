{ inputs, ... }:
{
  imports = [ inputs.nix-topology.flakeModule ];

  # nix build .#topology.x86_64-linux.config.output
  # nix shell nixpkgs#librsvg
  # rsvg-convert -o docs/src/images/topology.webp ./result/main.svg
  perSystem.topology.modules = [ ./output.nix ];
}
