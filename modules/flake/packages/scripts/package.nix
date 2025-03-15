{
  writeShellApplication,
  symlinkJoin,
  bat,
  eza,
  catimg,
  zip,
  unzip,
  gnutar,
  p7zip,
}:
let
  inherit (builtins) readFile;

  preview = writeShellApplication {
    name = "preview";
    runtimeInputs = [
      bat
      eza
      catimg
    ];
    text = readFile ./preview.sh;
  };

  icat = writeShellApplication {
    name = "icat";
    text = readFile ./icat.sh;
  };

  # Extract the compressed file with the correct tool based on the extension
  extract = writeShellApplication {
    name = "extract";
    runtimeInputs = [
      zip
      unzip
      gnutar
      p7zip
    ];
    text = readFile ./extract.sh;
  };
in
{
  inherit
    preview
    icat
    extract
    ;

  scripts = symlinkJoin {
    name = "scripts";
    paths = [
      preview
      icat
      extract
    ];
  };
}
