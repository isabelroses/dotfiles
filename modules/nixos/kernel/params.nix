{
  # https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html
  boot.kernelParams = [
    # NixOS produces many wakeups per second, which is bad for battery life.
    # This kernel parameter disables the timer tick on the last 4 cores
    "nohz_full=4-7"

    # make stack-based attacks on the kernel harder
    "randomize_kstack_offset=on"

    # controls the behavior of vsyscalls. this has been defaulted to none back in 2016 - break really old binaries for security
    "vsyscall=none"

    # reduce most of the exposure of a heap attack to a single cache
    "slab_nomerge"

    # Disable debugfs which exposes sensitive kernel data
    "debugfs=off"

    # Sometimes certain kernel exploits will cause what is called an "oops" which is a kernel panic
    # that is recoverable. This will make it unrecoverable, and therefore safe to those attacks
    "oops=panic"

    # only allow signed modules
    "module.sig_enforce=1"

    # blocks access to all kernel memory, even preventing administrators from being able to inspect and probe the kernel
    "lockdown=confidentiality"

    # enable buddy allocator free poisoning
    "page_poison=on"

    # performance improvement for direct-mapped memory-side-cache utilization, reduces the predictability of page allocations
    "page_alloc.shuffle=1"

    # for debugging kernel-level slab issues
    "slub_debug=FZP"

    # disable sysrq keys. sysrq is seful for debugging, but also insecure
    "sysrq_always_enabled=0" # 0 | 1 # 0 means disabled

    # ignore access time (atime) updates on files, except when they coincide with updates to the ctime or mtime
    "rootflags=noatime"

    # linux security modules
    "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"

    # prevent the kernel from blanking plymouth out of the fb
    "fbcon=nodefer"
  ];
}
