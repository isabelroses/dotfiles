{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  options.modules.usrEnv.services = {
    mailserver.enable = mkEnableOption "Enable the mailserver service";
    gitea.enable = mkEnableOption "Enable the gitea service";
    vaultwarden.enable = mkEnableOption "Enable the vaultwarden service";
    photoprism.enable = mkEnableOption "Enable the photoprism service";
    vscode-server.enable = mkEnableOption "Enables remote ssh vscode server";
    isabelroses-web.enable = mkEnableOption "Enables my website";
    searxng.enable = mkEnableOption "Enables searxng search engine service";
    cloudflared.enable = mkEnableOption "Enables cloudflared tunnels";

    jellyfin = {
      enable = mkEnableOption "Enables the jellyfin service";
      asDockerContainer = mkEnableOption "Enables the service as a docker container";
    };

    smb = {
      enable = mkEnableOption "Enables smb shares";
      host.enable = mkEnableOption "Enables hosting of smb shares";

      # should smb shares be enabled as a recpient machine
      recive = {
        general = mkEnableOption "genral share";
        media = mkEnableOption "media share";
      };
    };
  };
}
