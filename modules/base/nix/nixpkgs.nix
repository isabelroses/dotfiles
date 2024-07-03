{
  nixpkgs = {
    # pkgs = self.legacyPackages.${config.nixpkgs.system};

    config = {
      # I want to install packages that are not FOSS sometimes
      allowUnfree = true;
      allowUnfreePredicate = _: true;

      # If a package is broken, I don't want it
      # But occasionally we need to install some anyway so we can predicated those
      allowBroken = false;
      allowUnsupportedSystem = true;
      permittedInsecurePackages = [ ];

      # I don't want to use aliases for packages, usually because its slow
      # and also because it can get confusing
      allowAliases = false;

      # Maybe I can pickup so packages
      # Also a good idea to know which packages might be very out of date or broken
      # showDerivationWarnings = [ "maintainerless" ];
    };
  };
}
