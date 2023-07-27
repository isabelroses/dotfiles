_: {
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = false;
      };
      style = {
        command_name = {
          bold = false;
          foreground = "red";
        };
        example_code = {
          bold = false;
          foreground = "blue";
        };
        example_text = {
          bold = false;
          foreground = "green";
        };
        example_variable = {
          bold = false;
          foreground = "blue";
          underline = false;
        };
      };
      updates = {auto_update = true;};
    };
  };
}
