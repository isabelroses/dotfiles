{
  lib,
  self,
  inputs,
  ...
}:
let
  inherit (builtins) mapAttrs;
  inherit (lib.attrsets) filterAttrs;
  inherit (lib.lists) elem;

  # create a list of all systems that are allowed to be deployed
  allowedSystems = [ "minerva" ];
  # then extract those systems that we allow to be deployed from our nixosConfigurations
  systems = filterAttrs (name: _: elem name allowedSystems) self.nixosConfigurations;

  # then create a list of nodes that we want to deploy that we can pass to the deploy configuration
  nodes = mapAttrs (name: node: {
    hostname = name;
    skipChecks = true;
    sshUser = "isabel";
    profiles.system = {
      user = "root";
      path = inputs.deploy-rs.lib.${node.config.nixpkgs.hostPlatform.system}.activate.nixos node;
    };
  }) systems;
in
{
  flake = {
    checks = {
      x86_64-linux = inputs.deploy-rs.lib.x86_64-linux.deployChecks self.deploy;
      aarch64-linux = inputs.deploy-rs.lib.aarch64-linux.deployChecks self.deploy;
    };

    deploy = {
      autoRollback = true;
      magicRollback = true;

      inherit nodes;
    };
  };
}
