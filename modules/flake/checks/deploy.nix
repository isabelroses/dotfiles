{ self, inputs, ... }:
{
  flake = {
    checks = {
      x86_64-linux = inputs.deploy-rs.lib.x86_64-linux.deployChecks self.deploy;
      aarch64-linux = inputs.deploy-rs.lib.aarch64-linux.deployChecks self.deploy;
    };
  };
}
