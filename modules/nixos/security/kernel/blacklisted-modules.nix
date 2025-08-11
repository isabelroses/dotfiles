{ config, lib, ... }:
let
  inherit (lib) optionals concatLists mkEnableOption;

  sys = config.garden.system;
in
{
  options.garden.system.security = {
    fixWebcam = mkEnableOption "Fix the broken webcam by un-blacklisting the related kernel module.";
  };

  config = {
    boot.blacklistedKernelModules = concatLists [
      # Obscure network protocols
      [
        # keep-sorted start
        "af_802154" # IEEE 802.15.4
        "appletalk" # Appletalk
        "atm" # ATM
        "ax25" # Amateur X.25
        "can" # Controller Area Network
        "dccp" # Datagram Congestion Control Protocol
        "decnet" # DECnet
        "econet" # Econet
        "ipx" # Internetwork Packet Exchange
        "n-hdlc" # High-level Data Link Control
        "netrom" # NetRom
        "p8022" # IEEE 802.3
        "p8023" # Novell raw IEEE 802.3
        "psnap" # SubnetworkAccess Protocol
        "rds" # Reliable Datagram Sockets
        "rose" # ROSE
        "sctp" # Stream Control Transmission Protocol
        "tipc" # Transparent Inter-Process Communication
        "x25" # X.25
        # keep-sorted end
      ]

      # Old or rare or insufficiently audited filesystems
      [
        # keep-sorted start
        "adfs" # Active Directory Federation Services
        "affs" # Amiga Fast File System
        "befs" # "Be File System"
        "bfs" # BFS, used by SCO UnixWare OS for the /stand slice
        "cifs" # smb (Common Internet File System)
        "cramfs" # compressed ROM/RAM file system
        "efs" # Extent File System
        "exofs" # EXtended Object File System
        "f2fs" # Flash-Friendly File System
        "freevxfs" # Veritas filesystem driver
        "gfs2" # Global File System 2
        "hfs" # Hierarchical File System (Macintosh)
        "hfsplus" # " same as above, but with extended attributes
        "hpfs" # High Performance File System (used by OS/2)
        "jffs2" # Journalling Flash File System (v2)
        "jfs" # Journaled File System - only useful for VMWare sessions
        "ksmbd" # SMB3 Kernel Server
        "minix" # minix fs - used by the minix OS
        "nfs" # Network File System
        "nfsv3" # " (v3)
        "nfsv4" # Network File System (v4)
        "nilfs2" # New Implementation of a Log-structured File System
        "omfs" # Optimized MPEG Filesystem
        "qnx4" # extent-based file system used by the QNX4 and QNX6 OSes
        "qnx6" # ^
        "squashfs" # compressed read-only file system (used by live CDs)
        "sysv" # implements all of Xenix FS, SystemV/386 FS and Coherent FS.
        "udf" # https://docs.kernel.org/5.15/filesystems/udf.html
        "vivid" # Virtual Video Test Driver (unnecessary)
        # keep-sorted end

        # in the past this was blacklisted, but i had to remove it to be able
        # to use `system.etc.overlay.enable`
        # "erofs" # Enhanced Read-Only File System
      ]

      # Disable pc speakers, does anyone actually use these
      [
        # keep-sorted start
        "pcspkr"
        "snd_pcsp"
        # keep-sorted end
      ]

      # Disable Thunderbolt and FireWire to prevent DMA attacks
      [
        # keep-sorted start
        "firewire-core"
        "thunderbolt"
        # keep-sorted end
      ]

      # this is why your webcam no worky
      (optionals (!sys.security.fixWebcam) [ "uvcvideo" ])

      (optionals (!sys.bluetooth.enable) [
        "bluetooth"
        "btusb" # bluetooth dongles
      ])
    ];
  };
}
