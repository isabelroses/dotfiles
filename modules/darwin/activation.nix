{
  lib,
  config,
  ...
}: {
  system.activationScripts = {
    # https://github.com/ryan4yin/nix-darwin-kickstarter/blob/main/minimal/modules/system.nix#L14-L19
    postUserActivation.text = let
      persistentApps =
        lib.concatMapStrings (x: ''"'' + x + ''" '')
        config.system.defaults.CustomUserPreferences."com.apple.dock".persistent-apps;
    in ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      # Choose and order dock icons
      defaults write com.apple.dock persistent-apps -array ${persistentApps}
    '';

    # Settings that don't have an option in nix-darwin
    postActivation.text = ''
      echo "Allow apps from anywhere"
      SPCTL=$(spctl --status)
      if ! [ "$SPCTL" = "assessments disabled" ]; then
          sudo spctl --master-disable
      fi
    '';
  };
}
