{
  system.autoUpgrade = {
    # disable auto updating
    # (personally I think that auto updates are one of the dumbest things that exists)
    enable = false;

    # update at 3am every day
    dates = "*-*-* 03:00:00";

    # randomize the update time by up to an hour
    # we do this so all the machines don't update at the same time
    randomizedDelaySec = "1h";

    # specify the where we want to get the updates from
    flake = "github:isabelroses/dotfiles";
  };
}
