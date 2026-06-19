# refer to ../base/nixpkgs.nix for proper docs
{ lib, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowVariants = false;
      allowBroken = false;
      permittedInsecurePackages = [ ];
      allowUnsupportedSystem = false;
      allowAliases = false;
    };

    # the upstream installer profile adds one overlay to trim mbrola voices for
    # speechd; drop it since i remove speechd anyways.
    # <https://github.com/NixOS/nixpkgs/blob/b75227dfa10fe49fd0cae2f5ef82e97babd16c44/nixos/modules/profiles/installation-device.nix#L136-L144>
    overlays = lib.modules.mkForce [ ];
  };
}
