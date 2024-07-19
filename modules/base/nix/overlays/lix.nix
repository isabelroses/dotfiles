{ config, inputs', ... }:
{
  nixpkgs.overlays = [
    (_: prev: {
      # in order to reduce our closure size, we can override these packages to use the nix package
      # that we have installed, this will trigget a rebuild of the packages that depend on them
      # so hopefully its worth it for that system space
      agenix = inputs'.agenix.packages.default.override { nix = config.nix.package; };
      nix-direnv = prev.nix-direnv.override { nix = config.nix.package; };
      nix-index = prev.nix-index.override { nix = config.nix.package; };

      # NOTE: this is not installed because i have a almost perlless system setup
      # but this will remain here incase i change my mind
      nixos-rebuild = prev.nixos-rebuild.override { nix = config.nix.package; };

      lix = inputs'.lix.packages.default.overrideAttrs (_: {
        # I've upstreamed this, waiting for merge
        patches = [
          ./patches/0001-show-description.patch
          # TODO: work on cli --call-package arg
        ];

        # Kinda funny right
        # worth it https://akko.isabelroses.com/notice/AjlM7Vfq1zlgsEzk0G
        postPatch = ''
          substituteInPlace src/libmain/shared.cc \
            --replace-fail "(Lix, like Nix)" "(Lix, like Nix but for lesbians)"
        '';

        # WARNING: This greatly assumes that lix will never merge a CL that breaks
        # the tests. But I choose to disable them anyway because the build time is faster
        doCheck = false;
      });
    })
  ];
}
