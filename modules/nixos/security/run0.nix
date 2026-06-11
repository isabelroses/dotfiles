{ inputs', ... }:
{
  security.run0 = {
    enable = true;

    # wheelNeedsPassword = false means wheel group can execute commands without
    # a password so just disable it
    wheelNeedsPassword = false;
  };

  garden.packages = {
    inherit (inputs'.extersia.packages) run0-sudo-shim;
  };
}
