_: prev: {
  wakatime-cli = prev.wakatime-cli.overrideAttrs (_: {
    doCheck = false;
  });
}
