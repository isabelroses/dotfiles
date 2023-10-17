{
  lib,
  inputs,
  osConfig,
  defaults,
  ...
}: let
  inherit (osConfig.modules.system) video;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  imports = [inputs.schizofox.homeManagerModule];
  config = lib.mkIf ((lib.isAcceptedDevice osConfig acceptedTypes) && osConfig.modules.programs.gui.enable && video.enable && defaults.browser == "schizofox") {
    programs.schizofox = {
      enable = true;

      theme = {
        background-darker = "181825";
        background = "1e1e2e";
        foreground = "cdd6f4";
        font = "RobotoMono Nerd Font";
        simplefox.enable = true;
        darkreader.enable = true;
        extraCss = ''
        '';
      };

      search = {
        defaultSearchEngine = "Searx";
        removeEngines = ["Google" "Bing" "Amazon.com" "eBay" "Twitter" "Wikipedia"];
        searxUrl = "https://search.isabelroses.com";
        # searxQuery = "https://search.isabelroses.com/search?q={searchTerms}&categories=general";
        addEngines = [];
      };

      security = {
        sanitizeOnShutdown = false;
        sandbox = true;
        userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:106.0) Gecko/20100101 Firefox/106.0";
      };

      misc = {
        drmFix = true;
        disableWebgl = false;
        startPageURL = "https://dash.isabelroses.com";
      };

      extensions.extraExtensions = {
        # Addon IDs are in manifest.json or manifest-firefox.json
        "{446900e4-71c2-419f-a6a7-df9c091e268b}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        "sponsorBlocker@ajay.app".install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/refined-github-/latest.xpi";
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
      };
    };
  };
}
