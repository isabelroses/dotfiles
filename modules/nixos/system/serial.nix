{
  # its nice to have at least some color in our tty
  systemd.services."serial-getty@".environment.TERM = "xterm-256color";
}
