pkgs:
let
  inherit (builtins) readFile attrValues;
  inherit (pkgs) writeShellApplication;

  preview = writeShellApplication {
    name = "preview";
    runtimeInputs = attrValues { inherit (pkgs) bat eza catimg; };
    text = readFile ./preview.sh;
  };

  icat = writeShellApplication {
    name = "icat";
    text = readFile ./icat.sh;
  };

  # Extract the compressed file with the correct tool based on the extension
  extract = writeShellApplication {
    name = "extract";
    runtimeInputs = attrValues {
      inherit (pkgs)
        zip
        unzip
        gnutar
        p7zip
        ;
    };
    text = readFile ./extract.sh;
  };
in
{
  inherit preview icat extract;

  scripts = pkgs.symlinkJoin {
    name = "scripts";
    paths = [
      preview
      icat
      extract
    ];
  };
}
