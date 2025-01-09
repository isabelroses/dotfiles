{
  lib,
  self,
  inputs,
  config,
  ...
}:
let
  inherit (builtins) elem mapAttrs attrNames;
  inherit (lib.attrsets) filterAttrs;

  # extract the names of the systems that we want to deploy
  deployableSystems = attrNames (filterAttrs (_: attrs: attrs.deployable) config.easyHosts.hosts);

  easyHostsFromDeployableSystems = filterAttrs (
    name: _: elem name deployableSystems
  ) self.nixosConfigurations;
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

      # then create a list of nodes that we want to deploy that we can pass to the deploy configuration
      nodes = mapAttrs (name: node: {
        hostname = name;
        profiles.system = {
          user = "root";
          sshUser = node.config.garden.system.mainUser or "root";
          path = inputs.deploy-rs.lib.${config.easyHosts.hosts.${name}.system}.activate.nixos node;
        };
      }) easyHostsFromDeployableSystems;
    };
  };
}
