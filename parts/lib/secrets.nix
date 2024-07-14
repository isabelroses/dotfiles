{ inputs }:
let
  inherit (inputs) self;

  mkSecret =
    {
      file,
      owner ? "root",
      group ? "root",
      mode ? "400",
      ...
    }:
    {
      file = "${self}/secrets/${file}.age";
      inherit owner group mode;
    };

  mkSecretWithPath =
    {
      file,
      path,
      owner ? "root",
      group ? "root",
      mode ? "400",
      ...
    }:
    mkSecret {
      inherit
        file
        owner
        group
        mode
        ;
    }
    // {
      inherit path;
    };

in
{
  inherit mkSecret mkSecretWithPath;
}
