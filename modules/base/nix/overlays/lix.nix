{ config, inputs', ... }:
{
  nixpkgs.overlays = [
    (_: prev: {
      # to reduce our closure size, we change nixos-rebuild to use the nix packages
      # specified by our flake' nix settings
      nixos-rebuild = prev.nixos-rebuild.override { nix = config.nix.package; };

      lix = inputs'.lix.packages.default.overrideAttrs (oldAttrs: {
        # I've upstreamed this, waiting for merge
        patches = [ ./patches/0001-show-description.patch ];

        # Kinda funny right
        # worth it https://akko.isabelroses.com/notice/AjlM7Vfq1zlgsEzk0G
        postPatch = ''
          substituteInPlace src/libmain/shared.cc \
            --replace-fail "(Lix, like Nix)" "but for lesbians"
        '';

        # create a symlink to from nix to lix so we can use it in scripts and such
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            ln -s $out/bin/nix $out/bin/lix
          '';

        # WARNING: This greatly assumes that lix will never merge a CL that breaks
        # the tests. But I choose to disable them anyway because the build time is faster
        doCheck = false;
      });
    })
  ];
}
