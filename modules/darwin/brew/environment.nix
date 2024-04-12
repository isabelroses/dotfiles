{config, ...}: {
  environment = {
    variables = {
      HOMEBREW_NO_ANALYTICS = "1";
      HOMEBREW_NO_INSECURE_REDIRECT = "1";
      HOMEBREW_NO_EMOJI = "1";
    };

    systemPath = [config.homebrew.brewPrefix];
  };
}
