{
  clangStdenv,

  # additional args
  inputs,
  inputs',
}:
(inputs'.lix.packages.default.override {
  versionSuffix = "${inputs.lix.shortRev}-isabelroses";

  # they do this in the lix module so lets do it too
  # https://git.lix.systems/lix-project/nixos-module/src/commit/621aae0f3cceaffa6d73a4fb0f89c08d338d729e/overlay.nix#L6
  stdenv = clangStdenv;

  # i also don't want the aws-sdk-cpp dependency
  aws-sdk-cpp = null;
}).overrideAttrs
  (oa: {
    patches = [
      # adds a --call-package or -C cli option to build a package from the cli
      # based on the work of https://github.com/privatevoid-net/nix-super
      ./callpackage-cli.patch

      # don't alter the names of derivations for nix store diff-closure
      ./closure-names.patch

      # add more builtins to lix, this consists of the following:
      # - `builtins.abs` which will get you a absolute value of a number
      ./feat-builtins-abs.patch
      # - `builtins.greaterThan` which will return true if the first argument is greater than the second
      ./feat-builtins-greaterThan.patch
      # - `builtins.pow` which will raise the first argument to the power of the second
      ./feat-builtins-pow.patch

      # properly handle osc escapes
      # https://gerrit.lix.systems/c/lix/+/3143/2
      ./osc-escapes.patch
      # doc rendering links
      # https://gerrit.lix.systems/c/lix/+/3144
      # ./doc-redering.patch
    ];

    # Kinda funny right
    # worth it https://akko.isabelroses.com/notice/AjlM7Vfq1zlgsEzk0G
    postPatch =
      (oa.postPatch or "")
      + ''
        substituteInPlace lix/libmain/shared.cc \
          --replace-fail "(Lix, like Nix)" "(Lix, like Nix but for lesbians)"
      '';

    # WARNING: This greatly assumes that lix will never merge a CL that breaks
    # the tests. But I choose to disable them anyway because the build time is faster
    # We may _also_ have to disable checks since they will fail since we cannot patch the package.nix
    # to add the extra deps that are needed for the tests that i had added
    doCheck = false;
  })
