{
  system.defaults = {
    # use 12 hour time
    NSGlobalDomain.AppleICUForce24HourTime = false;

    menuExtraClock = {
      # show 12 hour clock
      Show24Hour = true;

      # show digital clock
      IsAnalog = false;

      # show AM/PM
      ShowAMPM = true;

      # Show date can imply the result of ShowDayOfMonth, ShowDayOfWeek, and ShowSeconds.
      # 0 = Show the date 1 = Don’t show 2 = Don’t show (hides date)
      ShowDate = 2;

      # show day of month
      # ShowDayOfMonth = false;

      # show day of week
      # ShowDayOfWeek = false;

      # show seconds
      # ShowSeconds = false;
    };
  };
}
