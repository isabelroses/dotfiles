{
  lib,
  writeShellApplication,
  jq,
  gnused,
  gawk,
  gh,
  gitMinimal,
  nurl,
  prefetch-npm-deps,
}:
writeShellApplication {
  name = "update-pins";

  runtimeInputs = [
    jq
    gnused
    gawk
    gh
    gitMinimal
    nurl
    prefetch-npm-deps
  ];

  text = builtins.readFile ./update-pins.sh;

  meta = {
    description = "Update the pinned brew and vicinae extension sources";
    license = lib.licenses.eupl12;
    mainProgram = "update-pins";
    maintainers = with lib.maintainers; [ isabelroses ];
  };
}
