{
  config,
  lib,
  inputs,
  osConfig,
  defaults,
  ...
}:
with lib; let
  inherit (osConfig.modules) device programs system;
  acceptedTypes = ["desktop" "laptop" "hybrid"];
in {
  imports = [inputs.schizofox.homeManagerModule];
  config = mkIf (builtins.elem device.type acceptedTypes && programs.gui.enable && system.video.enable && defaults.browser == "firefox") {
    programs.schizofox = {
      enable = true;
      package = "firefox-esr-115-unwrapped";

      search = {
        defaultSearchEngine = "Searx";
        removeEngines = ["Google" "Bing" "Amazon.com" "eBay" "Twitter" "Wikipedia"];
        searxUrl = "https://search.isabelroses.com";
        searxQuery = "https://search.isabelroses.com/search?q={searchTerms}&categories=general";
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
        #startPageURL = "file://${./startpage.html}";
      };

      extensions.extraExtensions = {
        # Addon IDs are in manifest.json or manifest-firefox.json
        "{446900e4-71c2-419f-a6a7-df9c091e268b}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        "{b6129aa9-e45d-4280-aac8-3654e9d89d21}".install_url = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_sapphire.xpi";
        "sponsorBlocker@ajay.app".install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        "1018e4d6-728f-4b20-ad56-37578a4de76".install_url = "https://addons.mozilla.org/firefox/downloads/latest/flagfox/latest.xpi";
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/refined-github-/latest.xpi";
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/stylus/latest.xpi";
      };
    };
  };
}
