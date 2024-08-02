# I would highly advise you do not use my flake as an input and instead you vendor this
# if you want to use this code, you may want to add my cachix cache to your flake
# you may want to not have to build this for yourself however
{ inputs, ... }:
{
  perSystem =
    { inputs', ... }:
    {
      packages.lix =
        (inputs'.lix.packages.default.override {
          aws-sdk-cpp = null;

          versionSuffix = "${
            builtins.substring 0 8 (inputs.lix.lastModifiedDate or inputs.lix.lastModified or "19700101")
          }-isabelroses_remix";
        }).overrideAttrs
          (_: {
            patches = [
              # allow users to remove aws-sdk
              # https://gerrit.lix.systems/c/lix/+/1696
              ./patches/lix-package-make-aws-sdk-cpp-build-input-optional.patch

              # preemptive merge of the pipe operator
              # https://gerrit.lix.systems/c/lix/+/1654
              ./patches/lix-libexpr-parser-Test-experimental-features.patch
              ./patches/lix-libexpr-Add-experimental-pipe-operator.patch
            ];

            # Kinda funny right
            # worth it https://akko.isabelroses.com/notice/AjlM7Vfq1zlgsEzk0G
            postPatch = ''
              substituteInPlace src/libmain/shared.cc \
                --replace-fail "(Lix, like Nix)" "(Lix, like Nix but for lesbians)"
            '';

            # WARNING: This greatly assumes that lix will never merge a CL that breaks
            # the tests. But I choose to disable them anyway because the build time is faster
            # We _also_ have to disable checks since they will fail since we cannot patch the package.nix
            # to add the extra deps that are needed for the tests that i had added
            doCheck = false;
          });
    };
}
