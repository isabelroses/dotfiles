# WARNING: it will become very apparent very quickly that this is not a good idea
# or perhaps a bad idea, or something like that. maybe we should turn back now
# but im committed to the bit, now we pray i don't endup with a broken system
#
# { lib, ... }:
{
  system = {
    # WARNING: agenix enables this like such so that user passwords can be encrypted
    # but we specificlly undo this so we can use a perlless implementation
    # system.activationScripts.users.deps = ["agenixInstall"];
    #
    # activationScripts.users = lib.modules.mkForce "";

    # Mount /etc as an overlayfs instead of generating it via a perl script.
    # WARNING: do not enable this if your not confident in your ability to fix it
    # it is a royal pain and is not worth half the effor it takes to fix it
    #
    # etc.overlay.enable = true;

    # WARNING: this leaves you without commands like `nixos-rebuild` which you don't
    # really need, you may consider enabling nh and using `nh os switch` instead
    # which is actually a really good alternative to using this
    disableInstallerTools = true;

    # we can use this to warn us if we have perl installed
    # forbiddenDependenciesRegexes = [ "perl" ];
  };

  # WARNING: this can break things, perticualarly if you use containers
  # personally I don't so it should be fine to disable this
  boot.enableContainers = false;

  # WARNING: this is an experimental feature, and it is not enabled by default
  # and this will create users with a different script then the perl one
  # so it may cause breakages, be warned
  #
  # systemd.sysusers.enable = true;
}
