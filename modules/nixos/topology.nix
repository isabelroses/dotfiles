{ inputs, config, ... }:
{
  imports = [ inputs.nix-topology.nixosModules.default ];

  topology.self = {
    name = config.networking.hostName;
  };
}
