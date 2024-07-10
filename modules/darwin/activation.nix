{
  system.activationScripts = {
    # activateSettings -u will reload the settings from the database and apply them to the current session,
    # so we do not need to logout and login again to make the changes take effect.
    #
    # https://github.com/ryan4yin/nix-darwin-kickstarter/blob/d17dc19b616b0ea60f64e3b8460479e1ccb797b2/minimal/modules/system.nix#L14-L19
    postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
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
