{ inputs', ... }:
{
  environment.systemPackages = [ inputs'.comfywm.packages.comfywm ];
  services.displayManager.sessionPackages = [ inputs'.comfywm.packages.comfywm ];
}
