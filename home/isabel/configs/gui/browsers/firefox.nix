{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.programs.gui.browsers.firefox;
in
{
  config = lib.mkIf cfg.enable {
    programs.firefox = {
      arkenfox = {
        enable = true;
        version = "126.1";
      };

      search = {
        default = "Searx";
        engines = {
          Searx = {
            urls = [
              { template = "https://search.isabelroses.com/search?q={searchTerms}&categories=general"; }
            ];
          };

          Nix = {
            urls = [ { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; } ];
            definedAliases = [ "nix" ];
          };

          GitHub = {
            urls = [ { template = "https://github.com/search?q={searchTerms}&ref=opensearch"; } ];
            definedAliases = [ "gh" ];
          };

          YouTube = {
            urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
            definedAliases = [ "yt" ];
          };
        };
      };

      extensions = {
        # Addon IDs are in manifest.json or manifest-firefox.json
        "{446900e4-71c2-419f-a6a7-df9c091e268b}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        "sponsorBlocker@ajay.app".install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/refined-github-/latest.xpi";
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}".install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
      };

      # modified from getchoo since I'm too lazy to read the wiki right now
      # https://github.com/getchoo/flake/blob/b237ea94b95a7f75998a646fde903105807b24da/users/seth/programs/firefox/arkenfox.nix
      profiles.arkenfox.arkenfox =
        let
          enableSections =
            sections:
            lib.genAttrs sections (_: {
              enable = true;
            });
        in
        lib.recursiveUpdate
          {
            enable = true;

            # fix hulu
            "1200"."1201"."security.ssl.require_safe_negotiation".value = false;

            "2600"."2651"."browser.download.useDownloadDir" = {
              enable = true;
              value = true;
            };
          }
          (enableSections [
            "0100"
            "0200"
            "0300"
            "0400"
            "0600"
            "0700"
            "0800"
            "0900"
            "1000"
            "1200"
            "1600"
            "1700"
            "2000"
            "2400"
            "2600"
            "2700"
            "2800"
            "4500"
          ]);
    };
  };
}
