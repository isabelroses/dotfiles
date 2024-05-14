{ config, lib, ... }:
let
  inherit (lib) mkIf;
  MHz = x: x * 1000;
in
{
  config = {
    services = {
      # Enable the TLP daemon for laptop power management.

      tlp.enable = false;
      # don't get tlp settings evaluated if it's not enabled
      tlp.settings = mkIf config.services.tlp.enable {
        TLP_ENABLE = 1;
        TLP_DEFAULT_MODE = "BAT";

        # Timeout (in seconds) for the audio power saving mode (supports Intel HAD, AC97).
        # A value of 1 is recommended for Linux desktop environments with PulseAudio,
        # systems without PulseAudio may require 10. The value 0 disables power save.
        SOUND_POWER_SAVE_ON_AC = 10;
        SOUND_POWER_SAVE_ON_BAT = 10;

        # SOUND_POWER_SAVE_CONTROLLER = "Y";

        START_CHARGE_THRESH_BAT0 = 80;
        STOP_CHARGE_THRESH_BAT0 = 95;

        RESTORE_THRESHOLDS_ON_BAT = 1;

        # battery care drivers
        # NATACPI_ENABLE = 1;
        # TPACPI_ENABLE = 1;
        # TPSMAPI_ENABLE = 1;

        # DISK_DEVICES = "nvme0n1 mmcblk0";

        # DISK_APM_LEVEL_ON_AC = "254 254";
        # DISK_APM_LEVEL_ON_BAT = "128 128";

        # DISK_IDLE_SECS_ON_AC=0;
        DISK_IDLE_SECS_ON_BAT = 5;

        # Timeout (in seconds) for writing unsaved data in file system buffers to disk.
        # MAX_LOST_WORK_SECS_ON_AC = 15;
        # MAX_LOST_WORK_SECS_ON_BAT = 60;

        # RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
        RADEON_DPM_PERF_LEVEL_ON_BAT = "low";

        # RADEON_DPM_STATE_ON_AC = "performance";
        # RADEON_DPM_STATE_ON_BAT = "battery";

        RADEON_POWER_PROFILE_ON_AC = "high";
        RADEON_POWER_PROFILE_ON_BAT = "low";

        # NMI_WATCHDOG = 0;

        # Sets Wi-Fi power saving mode. Adapter support depends on kernel and driver.
        # WIFI_PWR_ON_AC = "off";
        # WIFI_PWR_ON_BAT = "on";

        # WOL_DISABLE = "Y";

        # Select the platform profile to control system operating characteristics
        # around power/performance levels, thermal and fan speed.
        # PLATFORM_PROFILE_ON_AC = "performance";
        # PLATFORM_PROFILE_ON_BAT = "low-power";

        # <https://www.kernel.org/doc/html/latest/admin-guide/pm/cpufreq.html>
        CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_SCALING_MIN_FREQ_ON_AC = MHz 1400;
        CPU_SCALING_MAX_FREQ_ON_AC = MHz 1700;
        CPU_SCALING_MIN_FREQ_ON_BAT = MHz 1400;
        CPU_SCALING_MAX_FREQ_ON_BAT = MHz 1600;

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        # SCHED_POWERSAVE_ON_AC = 0;
        # SCHED_POWERSAVE_ON_BAT = 1;

        # Restores radio device state (builtin Bluetooth, Wi-Fi, WWAN) from previous shutdown on boot.
        # RESTORE_DEVICE_STATE_ON_STARTUP = 0;

        DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";
        DEVICES_TO_ENABLE_ON_STARTUP = "wifi";

        # DEVICES_TO_DISABLE_ON_SHUTDOWN = "bluetooth wifi wwan";
        # DEVICES_TO_ENABLE_ON_SHUTDOWN = "bluetooth wifi wwan";

        # has precedence
        DEVICES_TO_ENABLE_ON_AC = "";
        DEVICES_TO_DISABLE_ON_BAT = "";

        DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "bluetooth wwan";

        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wwan";
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "";
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";

        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi";
        DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT = "";
        DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT = "";

        DEVICES_TO_ENABLE_ON_DOCK = "wifi bluetooth";
        # DEVICES_TO_DISABLE_ON_DOCK = "";

        DEVICES_TO_ENABLE_ON_UNDOCK = "";
        DEVICES_TO_DISABLE_ON_UNDOCK = "bluetooth";

        # RUNTIME_PM_ON_AC = "on";
        # RUNTIME_PM_ON_BAT = "auto";

        # RUNTIME_PM_DENYLIST = "11:22.3 44:55.6";
        RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon psmouse";

        # RUNTIME_PM_ENABLE="11:22.3";
        # RUNTIME_PM_DISABLE="44:55.6";

        # PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        # USB_AUTOSUSPEND = 1;
        # USB_DENYLIST = "1111:2222 3333:4444";
        # USB_EXCLUDE_AUDIO = 1;
        # USB_EXCLUDE_BTUSB = 1;
        # USB_EXCLUDE_PHONE = 1;
        # USB_EXCLUDE_PRINTER = 1;
        # USB_EXCLUDE_WWAN = 0;
        # USB_ALLOWLIST="5555:6666 7777:8888";
        # USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 0;
      };
    };
  };
}
