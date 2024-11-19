{ inputs, ... }:
let
  # we need to remove lilith from the list of nixosConfigurations since
  # it does not import nix-topology, as of thus it will throw an error
  inherit (inputs.self) nixosConfigurations;
  filteredConfigs = builtins.removeAttrs nixosConfigurations [ "lilith" ];
in
{
  imports = [ inputs.nix-topology.flakeModule ];

  # nix build .#topology.x86_64-linux.config.output
  perSystem.topology = {
    nixosConfigurations = filteredConfigs;
    modules = [ ./output.nix ];
  };
}
