{
  config,
  lib,
  pkgs,
  ...
}: let
  sys = config.modules.system;
  inherit (lib) optionals concatLists;
in {
  security = {
    protectKernelImage = true;
    lockKernelModules = false; # breaks virtd, wireguard and iptables

    # force-enable the Page Table Isolation (PTI) Linux kernel feature
    forcePageTableIsolation = true;

    # User namespaces are required for sandboxing.
    allowUserNamespaces = true;

    # Disable unprivileged user namespaces, unless containers are enabled
    unprivilegedUsernsClone = config.virtualisation.containers.enable;

    # apparmor configuration
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = [pkgs.apparmor-profiles];
    };
  };

  boot = {
    kernel.sysctl = {
      # The Magic SysRq key is a key combo that allows users connected to the
      # system console of a Linux kernel to perform some low-level commands.
      # Disable it, since we don't need it, and is a potential security concern.
      "kernel.sysrq" = 0;
      # Restrict ptrace() usage to processes with a pre-defined relationship
      # (e.g., parent/child)
      # "kernel.yama.ptrace_scope" = 2;
      # Hide kptrs even for processes with CAP_SYSLOG
      "kernel.kptr_restrict" = 2;
      # Disable bpf() JIT (to eliminate spray attacks)
      "net.core.bpf_jit_enable" = false;
      # Disable ftrace debugging
      "kernel.ftrace_enabled" = false;
      # Avoid kernel memory address exposures via dmesg (this value can also be set by CONFIG_SECURITY_DMESG_RESTRICT).
      "kernel.dmesg_restrict" = 1;
    };

    # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
    kernelParams = [
      # make stack-based attacks on the kernel harder
      "randomize_kstack_offset=on"

      # controls the behavior of vsyscalls. this has been defaulted to none back in 2016 - break really old binaries for security
      "vsyscall=none"

      # reduce most of the exposure of a heap attack to a single cache
      "slab_nomerge"

      # only allow signed modules
      "module.sig_enforce=1"

      # blocks access to all kernel memory, even preventing administrators from being able to inspect and probe the kernel
      "lockdown=confidentiality"

      # enable buddy allocator free poisoning
      "page_poison=1"

      # performance improvement for direct-mapped memory-side-cache utilization, reduces the predictability of page allocations
      "page_alloc.shuffle=1"

      # for debugging kernel-level slab issues
      "slub_debug=FZP"

      # disable sysrq keys. sysrq is seful for debugging, but also insecure
      "sysrq_always_enabled=0" # 0 | 1 # 0 means disabled

      # ignore access time (atime) updates on files, except when they coincide with updates to the ctime or mtime
      "rootflags=noatime"

      # linux security modules
      "lsm=landlock,lockdown,yama,apparmor,bpf"

      # prevent the kernel from blanking plymouth out of the fb
      "fbcon=nodefer"
    ];

    blacklistedKernelModules = concatLists [
      [
        # Obscure network protocols
        "dccp" # Datagram Congestion Control Protocol
        "sctp" # Stream Control Transmission Protocol
        "rds" # Reliable Datagram Sockets
        "tipc" # Transparent Inter-Process Communication
        "n-hdlc" # High-level Data Link Control
        "netrom" # NetRom
        "x25" # X.25
        "ax25" # Amatuer X.25
        "rose" # ROSE
        "decnet" # DECnet
        "econet" # Econet
        "af_802154" # IEEE 802.15.4
        "ipx" # Internetwork Packet Exchange
        "appletalk" # Appletalk
        "psnap" # SubnetworkAccess Protocol
        "p8022" # IEEE 802.3
        "p8023" # Novell raw IEEE 802.3
        "can" # Controller Area Network
        "atm" # ATM
      ]
      [
        # Old or rare or insufficiently audited filesystems
        "adfs"
        "affs"
        "bfs"
        "befs"
        "cramfs"
        "efs"
        "erofs"
        "exofs"
        "freevxfs"
        "f2fs"
        "vivid"
        "gfs2"
        "ksmbd"
        "nfsv4"
        "nfsv3"
        "cifs"
        "nfs"
        "cramfs"
        "freevxfs"
        "jffs2"
        "hfs"
        "hfsplus"
        "squashfs"
        "udf"
        "hpfs"
        "jfs"
        "minix"
        "nilfs2"
        "omfs"
        "qnx4"
        "qnx6"
        "sysv"
        "vivid" # Video Test Driver (unnecessary)
      ]
      (optionals (!sys.security.fixWebcam) [
        "uvcvideo" # this is why your webcam no worky
      ])
      (optionals (!sys.bluetooth.enable) [
        "bluetooth" # let bluetooth work
        "btusb" # let bluetooth dongles work
      ])
      (optionals (!config.modules.services.smb.enable) [
        "cifs" # allows smb to work
      ])
    ];
  };
}
