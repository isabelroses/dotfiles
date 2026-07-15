{
  lib,
  writeShellApplication,
  curl,
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
    curl
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
    description = "Update the pinned brew, vicinae and chromium extension sources";
    license = lib.licenses.eupl12;
    mainProgram = "update-pins";
    maintainers = with lib.maintainers; [ isabelroses ];
  };
}
