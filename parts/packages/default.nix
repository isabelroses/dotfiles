{
  perSystem =
    { inputs', ... }:
    {
      packages.lix = inputs'.lix.packages.default.overrideAttrs (_: {
        # I've upstreamed this, waiting for merge
        patches = [ ./patches/0001-show-description.patch ];

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
    };
}
