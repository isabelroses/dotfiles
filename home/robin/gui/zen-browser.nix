{
  lib,
  pkgs,
  config,
  inputs,
  inputs',
  ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  config =
    mkIf (config.garden.profiles.graphical.enable && config.garden.programs.defaults.browser == "zen")
      {
        programs.zen-browser = {
          enable = true;
          package = lib.mkForce (
            pkgs.wrapFirefox (
              (inputs'.zen-browser.packages.beta-unwrapped.override {
                policies = lib.removeAttrs config.programs.zen-browser.policies [ "Preferences" ];
              }).overrideAttrs
              (oa: {
                installPhase = (oa.installPhase or "") + ''
                  mkdir -p $out/lib/zen-bin-${oa.version}/defaults/pref/
                  chmod 777 $out/lib/zen-bin-${oa.version}/defaults/pref/
                  cat > "$out/lib/zen-bin-${oa.version}/defaults/pref/config-prefs.js" << EOF
                  pref("general.config.obscure_value", 0);
                  pref("general.config.filename", "config.js");
                  // Sandbox needs to be disabled in release and Beta versions
                  pref("general.config.sandbox_enabled", false);
                  EOF
                  cat > "$out/lib/zen-bin-${oa.version}/config.js" << EOF
                  // skip 1st line
                  try {
                    let cmanifest = Cc['@mozilla.org/file/directory_service;1'].getService(Ci.nsIProperties).get('UChrm', Ci.nsIFile);
                    cmanifest.append('utils');
                    cmanifest.append('chrome.manifest');
                    if(cmanifest.exists()){
                      Components.manager.QueryInterface(Ci.nsIComponentRegistrar).autoRegister(cmanifest);
                      ChromeUtils.importESModule('chrome://userchromejs/content/boot.sys.mjs');
                    }
                  } catch(ex) {};
                  EOF
                '';
              })
            ) { }
          );

          policies = {
            DisableAppUpdate = true;
            DisableFirefoxStudies = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DontCheckDefaultBrowser = true;
            NoDefaultBookmarks = true;
            OfferToSaveLogins = false;
            Preferences =
              let
                locked = value: {
                  Value = value;
                  Status = "locked";
                };
                inherit (config.evergarden) variant accent;
                palette = inputs.evergarden.lib.palette.${variant};
              in
              builtins.mapAttrs (_: locked) {
                "browser.tabs.warnOnClose" = false;
                "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
                "browser.tabs.groups.enabled" = true;
                "zen.urlbar.behavior" = "float";
                "zen.theme.accent-color" = palette.${accent};
              };
          };
        };

        programs.zen-browser.nativeMessagingHosts = [ pkgs.firefoxpwa ];
      };
}
