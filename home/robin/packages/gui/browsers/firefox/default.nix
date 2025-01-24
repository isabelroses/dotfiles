{
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) genAttrs recursiveUpdate;

  cfg = config.garden.programs.firefox;
in
{
  imports = [
    inputs.arkenfox.hmModules.arkenfox
    ./extensions.nix
  ];

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      inherit (cfg) package;

      arkenfox = {
        enable = true;
        version = "128.0";
      };

      profiles.arkenfox = {
        isDefault = true;

        # modified from getchoo since I'm too lazy to read the wiki right now
        # https://github.com/getchoo/flake/blob/b237ea94b95a7f75998a646fde903105807b24da/users/seth/programs/firefox/arkenfox.nix
        arkenfox =
          let
            enableSections =
              sections:
              genAttrs sections (_: {
                enable = true;
              });
          in
          recursiveUpdate
            {
              enable = true;

              # fix hulu
              "1200"."1201"."security.ssl.require_safe_negotiation".value = false;

              "2600"."2651"."browser.download.useDownloadDir" = {
                enable = true;
                value = true;
              };

              "5000" = {
                "5003"."signon.rememberSignons".enable = true;
                # enable search autocomplete
                "5021"."keyword.enabled".value = true;
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
  };
}
