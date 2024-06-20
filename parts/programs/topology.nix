{ self, inputs, ... }:
{
  # You can build the topology configuration with the following command:
  #  nix build .#topology.<current-system>.config.output
  flake.topology =
    let
      host = self.nixosConfigurations.${builtins.head (builtins.attrNames self.nixosConfigurations)};
    in
    import inputs.nix-topology {
      inherit (host) pkgs;

      modules = [ { inherit (self) nixosConfigurations; } ];
    };
}
