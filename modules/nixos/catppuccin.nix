{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib.validators) isAcceptedDevice;
  nonAccepted = [
    "server"
    "wsl"
  ];
in
{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  config.catppuccin = {
    enable = !(isAcceptedDevice config nonAccepted);
    flavor = "mocha";
  };
}
