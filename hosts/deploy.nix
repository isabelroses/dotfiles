{
  inputs,
  self,
  ...
}: {
  nodes.luz = {
    sshUser = "isabel";
    hostname = "91.107.198.173";
    sshOpts = ["-i" "/home/isabel/.ssh/nixos"];

    profiles.system = {
      user = "isabel";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.luz;
    };
  };
}
