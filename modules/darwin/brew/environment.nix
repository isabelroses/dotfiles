{ config, ... }:
{
  environment = {
    variables = {
      # Do not send analytic data to Homebrew
      HOMEBREW_NO_ANALYTICS = "1";

      # don't allow insecure redirects
      HOMEBREW_NO_INSECURE_REDIRECT = "1";

      # don't show emoji in the output
      HOMEBREW_NO_EMOJI = "1";

      # I don't need any hints because nix handles homebrew for me
      HOMEBREW_NO_ENV_HINTS = "0";
    };

    # we add howbrew to the PATH so we can execute all the apps it installs
    systemPath = [ config.homebrew.brewPrefix ];
  };
}
