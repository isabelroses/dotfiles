# I would highly advise you do not use my flake as an input and instead you vendor this
# if you want to use this code, you may want to add my cachix cache to your flake
# you may want to not have to build this for yourself however
{ inputs, ... }:
{
  perSystem =
    { pkgs, inputs', ... }:
    {
      packages = {
        inherit (import ./scripts/package.nix pkgs)
          scripts
          preview
          icat
          extract
          ;

        lix =
          (inputs'.lix.packages.default.override {
            # sometimes this builds from source and i hate it
            # plus i don't use the features it provides so lets just disable it
            aws-sdk-cpp = null;

            versionSuffix = "${inputs.lix.shortRev}-isabelroses";
          }).overrideAttrs
            (oa: {
              patches = [
                # add a --call-package or -C cli option to build a package from the cli
                # based on the work of https://github.com/privatevoid-net/nix-super
                ./patches/lix-callpackage-cli.patch

                # allow flakes to trivially eval to attrsets
                ./patches/lix-flake-trivial-eval.patch
              ];

              # Kinda funny right
              # worth it https://akko.isabelroses.com/notice/AjlM7Vfq1zlgsEzk0G
              postPatch =
                (oa.postPatch or "")
                + ''
                  substituteInPlace src/libmain/shared.cc \
                    --replace-fail "(Lix, like Nix)" "(Lix, like Nix but for lesbians)"
                '';

              # WARNING: This greatly assumes that lix will never merge a CL that breaks
              # the tests. But I choose to disable them anyway because the build time is faster
              # We may _also_ have to disable checks since they will fail since we cannot patch the package.nix
              # to add the extra deps that are needed for the tests that i had added
              doCheck = false;
            });
      };
    };
}
