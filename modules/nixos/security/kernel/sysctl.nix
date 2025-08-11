{ lib, options, ... }:
{
  # you can find out whats recommended for you, by following these steps
  # > sudo sysctl -a > sysctl.txt
  # > kernel-hardening-checker -l /proc/cmdline -c /proc/config.gz -s ./sysctl.txt
  #
  # better read up
  # https://docs.kernel.org/admin-guide/sysctl/vm.html
  #
  # a good place to quickly find what each setting does
  # https://sysctl-explorer.net/
  #
  # we disable sysctl tweaks on wsl since they don't work
  boot.kernel.sysctl = lib.mkIf (!(options ? "wsl")) {
    # The Magic SysRq key is a key combo that allows users connected to the
    # system console of a Linux kernel to perform some low-level commands.
    # Disable it, since we don't need it, and is a potential security concern.
    "kernel.sysrq" = 0;

    # Restrict ptrace() usage to processes with a pre-defined relationship
    # (e.g., parent/child)
    "kernel.yama.ptrace_scope" = 3;

    # Hide kptrs even for processes with CAP_SYSLOG
    "kernel.kptr_restrict" = 2;

    # Disable bpf() JIT (to eliminate spray attacks)
    "net.core.bpf_jit_enable" = false;

    # Disable ftrace debugging
    "kernel.ftrace_enabled" = false;

    # Avoid kernel memory address exposures via dmesg (this value can also be set by CONFIG_SECURITY_DMESG_RESTRICT).
    "kernel.dmesg_restrict" = 1;

    # Disable SUID binary dump
    "fs.suid_dumpable" = 0;

    # Disable late module loading
    # "kernel.modules_disabled" = 1;
    # Disallow profiling at all levels without CAP_SYS_ADMIN
    "kernel.perf_event_paranoid" = 3;

    # Require CAP_BPF to use bpf
    "kernel.unprivileged_bpf_disabled" = true;

    # Prevent boot console log leaking information
    "kernel.printk" = "3 3 3 3";

    # Restrict loading TTY line disaciplines to the CAP_SYS_MODULE capablitiy to
    # prevent unprvileged attackers from loading vulnrable line disaciplines
    "dev.tty.ldisc_autoload" = 0;

    # Kexec allows replacing the current running kernel. There may be an edge case where
    # you wish to boot into a different kernel, but I do not require kexec. Disabling it
    # patches a potential security hole in our system.
    "kernel.kexec_load_disabled" = true;

    # Disable TIOCSTI ioctl, which allows a user to insert characters into the input queue of a terminal
    # this has been known for a long time to be used in privilege escalation attacks
    "dev.tty.legacy_tiocsti" = 0;

    # Disable the ability to load kernel modules, we already load the ones that we need
    # FIXME: this breaks boot, so we should track down what modules we need to boot if
    # we are going to commit to enabling this
    # "kernel.modules_disabled" = 1;

    # This enables hardening for the BPF JIT compiler, however it costs at a performance cost
    # "net.core.bpf_jit_harden" = 2;

    # awesome stuff from
    # https://github.com/NixOS/nixpkgs/pull/391473/
    #
    # Mitigate some TOCTOU vulnerabilites
    # cf. https://www.kernel.org/doc/Documentation/admin-guide/sysctl/fs.rst
    #
    # Don’t allow O_CREAT open on FIFOs not owned by the user in world‐ or
    # group‐writable sticky directories (e.g. /tmp), unless owned by the
    # directory owner
    "fs.protected_fifos" = 2;

    # Don’t allow users to create hardlinks unless they own the source
    # file or have read/write access to it
    "fs.protected_hardlinks" = 1;

    # Don’t allow O_CREAT open on regular files not owned by user in world‐
    # or group‐writable sticky directories (e.g. /tmp), unless owned by the
    # directory owner
    "fs.protected_regular" = 2;

    # Don’t follow symlinks in sticky world‐writable directories (e.g. /tmp),
    # unless the user ID of the follower matches the symlink, or the
    # directory owner matches the symlink
    "fs.protected_symlinks" = 1;
  };
}
