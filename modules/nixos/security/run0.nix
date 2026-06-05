{ inputs', ... }:
{
  security.run0 = {
    # wheelNeedsPassword = false means wheel group can execute commands without
    # a password so just disable it
    wheelNeedsPassword = false;
  };

  garden.packages = {
    inherit (inputs'.extersia.packages) run0-sudo-shim;
  };
}
