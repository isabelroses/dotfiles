{
  lib,
  self,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (self.lib.services) mkServiceOption;

  rdomain = config.networking.domain;
  cfg = config.garden.services.mediawiki;
in
{
  options.garden.services.mediawiki = mkServiceOption "mediawiki" { domain = "ctp-wiki.${rdomain}"; };

  config = mkIf cfg.enable {
    services.mediawiki = {
      enable = true;
      passwordFile = "/etc/mediawikipwd";

      name = "Catppuccin Wiki";

      extensions = {
        # some extensions are included and can enabled by passing null
        VisualEditor = null;

        Highlightjs_Integration = pkgs.fetchzip {
          url = "https://github.com/Nicolas01/Highlightjs_Integration/archive/master.zip";
          hash = "sha256-GNE1z/gw2TmLOW+2k+20fhwurzOEfhqCfq3NxIeNzVY=";
        };

        # using pkgs.fetchzip here fails????
        Mermaid = "/var/lib/mediawiki/Mermaid";
      };

      extraConfig = ''
        $wgFavicon = "https://raw.githubusercontent.com/catppuccin/website/main/public/favicon.png";
        $wgLogos = ['icon' => "https://raw.githubusercontent.com/catppuccin/website/main/public/favicon.png"];

        # set out own license
        # $wgRightsPage = "Project:About";
        $wgRightsIcon = "";
        $wgRightsText = "CC-BY-4.0 International License";
        $wgRightsUrl = "https://github.com/catppuccin/community/blob/main/LICENSE";

        # Disable anonymous editing
        $wgGroupPermissions['*']['createpage'] = false;
        $wgGroupPermissions['*']['createtalk'] = false;
        $wgGroupPermissions['*']['edit'] = false;
        $wgGroupPermissions['*']['writeapi'] = false;

        # prevent people from creating accounts and just editing anything
        unset($wgGroupPermissions['user']);

        # create a new group
        $wgGroupPermissions['maintainer'];
        # $wgGroupPermissions['maintainer']['createpage'] = true;
        $wgGroupPermissions['maintainer']['edit'] = true;
        $wgGroupPermissions['maintainer']['minoredit'] = true;
        $wgGroupPermissions['maintainer']['writeapi'] = true;
        $wgGroupPermissions['maintainer']['upload'] = true;
        $wgGroupPermissions['maintainer']['reupload'] = true;

        # regive admin perms
        $wgGroupPermissions['sysop']['createpage'] = true;
        $wgGroupPermissions['sysop']['edit'] = true;
        $wgGroupPermissions['sysop']['minoredit'] = true;
        $wgGroupPermissions['sysop']['writeapi'] = true;
        $wgGroupPermissions['sysop']['changetags'] = true;
        $wgGroupPermissions['sysop']['move'] = true;
        $wgGroupPermissions['sysop']['movefile'] = true;
        $wgGroupPermissions['sysop']['move-categorypages'] = true;
        $wgGroupPermissions['sysop']['move-subpages'] = true;
        $wgGroupPermissions['sysop']['move-rootuserpages'] = true;
        $wgGroupPermissions['sysop']['upload'] = true;
        $wgGroupPermissions['sysop']['reupload'] = true;
        $wgGroupPermissions['sysop']['reupload-shared'] = true;
        $wgGroupPermissions['sysop']['sendemail'] = true;

        # remove the powered by mediawiki icon
        unset($wgFooterIcons['poweredby']);
      '';

      # TODO: read this later
      # https://www.mediawiki.org/wiki/Manual:Preventing_access
      # https://www.mediawiki.org/wiki/Manual:User_rights

      webserver = "nginx";
      nginx.hostName = cfg.domain;
    };
  };
}
