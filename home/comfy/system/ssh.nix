{ osConfig, ... }:
let
  inherit (osConfig.age) secrets;
in
{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    compression = true;

    matchBlocks = {
      # git clients
      "github.com" = {
        user = "git";
        hostname = "github.com";
        identityFile = secrets.keys-comfy-gh.path;
      };

      "gitlab.com" = {
        user = "git";
        hostname = "gitlab.com";
      };

      "git.isabelroses.com" = {
        user = "git";
        hostname = "git.isabelroses.com";
        port = 2222;
      };
    };
  };
}
