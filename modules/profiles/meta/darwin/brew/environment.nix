{config, ...}: {
  environment = {
    variables = {
      HOMEBREW_NO_ANALYTICS = "1";
    };

    systemPath = [config.homebrew.brewPrefix];
  };
}
