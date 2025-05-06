{
  nixpkgs.config = {
    # I want to install packages that are not FOSS sometimes
    allowUnfree = true;
    # A funny little hack to make sure that *everything* is permitted
    allowUnfreePredicate = _: true;

    # If a package is broken, I don't want it
    allowBroken = false;
    # But occasionally we need to install some anyway so we can predicated those
    # these are usually packages like electron because discord and others love
    # to take their sweet time updating it
    permittedInsecurePackages = [ ];

    # I allow packages that are not supported by my system
    # since I sometimes need to try and build those packages that are not directly supported
    allowUnsupportedSystem = true;

    # I don't want to use aliases for packages, usually because its slow
    # and also because it can get confusing
    allowAliases = false;

    # Maybe I can pickup so packages
    # Also a good idea to know which packages might be very out of date or broken
    # showDerivationWarnings = [ "maintainerless" ];
  };
}
