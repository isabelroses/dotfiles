# WARNING: it will become very apparent very quickly that this is not a good idea
# or perhaps a bad idea, or something like that. maybe we should turn back now
# but im committed to the bit, now we pray i don't endup with a broken system
{ lib, config, ... }:
let
  inherit (lib.modules) mkForce;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.options) mkEnableOption;
in
{
  options.garden.system.banPerl = mkEnableOption "Ban perl from being installed";

  config =
    {
      system = {
        # WARNING: this leaves you without commands like `nixos-rebuild` which you don't
        # really need, you may consider enabling nh and using `nh os switch` instead
        # which is actually a really good alternative to using this
        disableInstallerTools = true;

        # I would rather use the rust implementation of the switch-to-configuration
        # called switch-to-configuration-ng, a thankfully perlless switcher.
        # It is a much better, faster and smaller implementation
        # WARNING: it is broken on WSL with a PR open to fix it
        # https://github.com/NixOS/nixpkgs/pull/321662
        switch = {
          enable = false; # disable the old implementation
          enableNg = true; # enable the new implementation
        };
      };

      # this can break things, perticualarly if you use containers
      # personally I don't so it should be fine to disable this
      boot.enableContainers = false;

    }
    // optionalAttrs config.garden.system.banPerl {
      # since we enable a hover fs we also need to allow for that filesystem in the supported filesystems
      boot = {
        supportedFilesystems = [ "erofs" ];
        initrd.supportedFilesystems = [ "erofs" ];
      };

      # WARNING: this is an experimental feature, and it is not enabled by default
      # and this will create users with a different script then the perl one
      # so it may cause breakages, be warned
      systemd.sysusers.enable = true;

      system = {
        # WARNING: agenix enables this like such so that user passwords can be encrypted
        # but we specificlly undo this so we can use a perlless implementation
        # system.activationScripts.users.deps = ["agenixInstall"];
        activationScripts = {
          users = mkForce "";

          # we have to help agenix out a bit by making it install the secrets
          # since the original script would only run agenixInstall as a user dep that would
          # give us an error, so we add the agenixInstall as a dep to the "main" agenix
          # activation script such that it will run install for us instead
          agenix.deps = [ "agenixInstall" ];
        };

        # Mount /etc as an overlayfs instead of generating it via a perl script.
        # WARNING: do not enable this if your not confident in your ability to fix it
        # it is a royal pain and is not worth half the effor it takes to fix it
        etc.overlay.enable = true;

        # we can use this to warn us if we have perl installed
        forbiddenDependenciesRegexes = [ "perl" ];
      };
    };
}
