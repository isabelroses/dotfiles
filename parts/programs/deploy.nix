{ self, inputs, ... }:
{
  flake.deploy = {
    autoRollback = true;
    magicRollback = true;

    # TODO: make this a function, that detects systems by their name
    nodes.minerva = {
      hostname = "minerva";
      skipChecks = true;
      sshUser = "isabel";
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.luz;
      };
    };
  };
}
