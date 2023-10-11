_: {
  security = {
    pam = {
      # fix "too many files open" errors while writing a lot of data at once
      # (e.g. when building a large package)
      # if this, somehow, doesn't meet your requirements you may just bump the numbers up
      loginLimits = [
        {
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "@wheel";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }
      ];

      # allow screen lockers to also unlock the screen
      # (e.g. swaylock, gtklock)
      services = {
        swaylock.text = "auth include login";
        gtklock.text = "auth include login";
      };
    };
  };
}
