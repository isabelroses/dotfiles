{
  # a headless system shoudld not mount any removable media
  # without explicit user action
  services.udisks2.enable = false;
}
