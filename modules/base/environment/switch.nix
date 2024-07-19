# I would rather use the rust implementation of the switch, then the perl one
# It should be a much better, faster and smaller implementation
{
  system.switch = {
    enable = false; # disable the old implementation
    enableNg = true; # enable the new implementation
  };
}
