{
  lib,
  pkgs,
  osConfig,
  ...
}:
with lib; let
  device = osConfig.modules.device;
  env = osConfig.modules.usrEnv;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  config = mkIf (builtins.elem device.type acceptedTypes) {
    programs.chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "clngdbkpkpeebahjckkjfobafhncgmne" # stylus
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
      ];
    };
  };
}
