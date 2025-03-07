{ inputs', inputs }:
(inputs'.lix.packages.default.override {
  versionSuffix = "${inputs.lix.shortRev}-isabelroses";
}).overrideAttrs
  (oa: {
    patches = [
      # adds a --call-package or -C cli option to build a package from the cli
      # based on the work of https://github.com/privatevoid-net/nix-super
      ./patches/lix-callpackage-cli.patch

      # add more builtins to lix, this consists of the following:
      # - `builtins.abs` which will get you a absolute value of a number
      ./patches/lix-feat-builtins-abs.patch
      # - `builtins.greaterThan` which will return true if the first argument is greater than the second
      ./patches/lix-feat-builtins-greaterThan.patch
      # - `builtins.pow` which will raise the first argument to the power of the second
      ./patches/lix-feat-builtins-pow.patch
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
