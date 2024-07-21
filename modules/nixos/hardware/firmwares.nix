# Enables non-free firmware on devices, this is usually done if
# `nixos-generate-config` cannot detect what firmware is needed for the device
# but i don't really care about that so lets just enable it for all devices
{ hardware.enableRedistributableFirmware = true; }
