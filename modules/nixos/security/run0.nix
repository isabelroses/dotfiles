{ config, ... }:
{
  security.run0 = {
    # wheelNeedsPassword = false means wheel group can execute commands without
    # a password so just disable it
    wheelNeedsPassword = false;

    # yeah lets throw that in there too, if sudo is disabled
    enableSudoAlias = !(config.security.sudo.enable || config.security.sudo-rs.enable);
  };
}
