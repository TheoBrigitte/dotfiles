# Boot management

In this document, we will discuss how to manage the bootloader and kernel for a Linux system using `systemd-boot`. We will cover how to backup the current bootloader and kernel, update the bootloader, and install a rescue kernel.

There are many assumptions made in this document, including:

- The system is using UEFI boot mode.
- The system is using `systemd-boot` as the bootloader.
- The system is using `kernel-install` to manage kernel installations.
- The `/boot` directory is on the EFI System Partition (ESP).
- The user has root privileges to perform the necessary operations.

Before moving into the automated scripts, it is important to understand elements such as UEFI boot mode, UEFI boot entries, systemd-boot, and kernel parameters.

## Boot mode, UEFI or BIOS ?

The boot mode of the system can be either UEFI or BIOS (also known as Legacy). Modern systems typically use UEFI, while older systems may use BIOS.

To check if the system is booted in UEFI or BIOS mode use the following command:

```bash
$ test -d /sys/firmware/efi && echo "UEFI mode" || echo "BIOS mode"
UEFI mode
```

The rest of this document will only cover UEFI boot.

## UEFI boot entries

The UEFI firmware maintains a list of boot entries that point to EFI applications (usually bootloaders) stored on the EFI System Partition (ESP). Each entry has a unique identifier and can be managed using the `efibootmgr` command.

To list the current UEFI boot entries, use the `efibootmgr` command:

```bash
$ sudo efibootmgr
BootCurrent: 0001
Timeout: 0 seconds
BootOrder: 0001,0000,001A,001B,001C,001D,001E,001F,0020,0021,0022
Boot0000* GRUB  HD(1,GPT,1b44a423-9d89-6841-9278-65506957ddf4,0x800,0x96800)/\EFI\GRUB\grubx64.efi
Boot0001* Linux Boot Manager    HD(1,GPT,1b44a423-9d89-6841-9278-65506957ddf4,0x800,0x96800)/\EFI\systemd\systemd-bootx64.efi
Boot0010  Setup FvFile(721c8b66-426c-4e86-8e99-3457c46ab0b9)
Boot0011  Boot Menu     FvFile(126a762d-5758-4fca-8531-201a7f57f850)
Boot0012  Diagnostic Splash Screen      FvFile(a7d8d9a6-6ab0-4aeb-ad9d-163e59a7a380)
Boot0013  Lenovo Diagnostics    FvFile(3f7e615b-0d45-4f80-88dc-26b234958560)
... and many more ...
```

This lists all the boot entries stored in the UEFI firmware. Each entry has a unique identifier (e.g., `0000`, `0001`, etc.) and points to an EFI application (usually a bootloader) located on the EFI System Partition (ESP).

Note that there is currently an issue with `efibootmgr` versions `18` which prevent entries modification, see https://github.com/ValveSoftware/SteamOS/issues/982.


To find out where the EFI applications are stored, use the following command to check the mount point of the EFI System Partition (ESP):

```bash
$ lsblk --filter 'PARTTYPENAME == "EFI System"'
NAME      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
nvme0n1p1 259:1    0  301M  0 part /boot
```

And then list the contents of the ESP partition:

```bash
$ tree /boot/EFI
/boot/EFI
├── BOOT
│   └── BOOTX64.efi
├── GRUB
│   └── grubx64.efi
└── systemd
    └── systemd-bootx64.efi

4 directories, 3 files
```

Note that systemd and BOOT are both created by systemd-boot when running `bootctl install` or `bootctl update`.

The rest of this document will focus on the `systemd-boot` bootloader.

## Backup before upgrading

### Backup current bootloader

Before upgrading the bootloader or kernel, it is important to backup the current configuration as rescue in order to be able to restore the system in case of failure after the upgrade.

To backup the current bootloader as rescue, use the following commands withe adjusted necessary arguments:

```bash
cp -r /boot/EFI/systemd/ /boot/EFI/systemd-rescue
```
```
# efibootmgr --create --disk /dev/nvme0n1 --part 1 --loader '\EFI\systemd-rescue\systemd-bootx64.efi' --label 'Linux Boot Manager (rescue)' --unicode
BootCurrent: 0001
Timeout: 0 seconds
BootOrder: 0001,0000
Boot0000* Linux Boot Manager    HD(1,GPT,1b44a423-9d89-6841-9278-65506957ddf4,0x800,0x96800)/\EFI\systemd\systemd-bootx64.efi
Boot0001* Linux Boot Manager (old)      HD(1,GPT,1b44a423-9d89-6841-9278-65506957ddf4,0x800,0x96800)/\EFI\systemd-old\systemd-bootx64.efi
```

The newly created entry is set as the first entry in the boot order, we change the boot order using:

```bash
efibootmgr --bootorder 0000,0001
```

### Backup current kernel

Systemd ships with a tool called `kernel-install` that is used to install and manage kernel images and initramfs images on the system. It is typically used in conjunction with package managers to automate the installation of new kernels.

To backup the current kernel as rescue first start by finding the current kernel version using:

```bash
# kernel-install list
VERSION            HAS KERNEL PATH
5.15.190-2-MANJARO          ✓ /usr/lib/modules/5.15.190-2-MANJARO
6.6.103-2-MANJARO           ✓ /usr/lib/modules/6.6.103-2-MANJARO
```

Then create a backup of the current kernel and initramfs images using:

```bash
kernel-install --entry-token=literal:rescue add 6.6.103-2-MANJARO-rescue /usr/lib/modules/6.6.103-2-MANJARO/vmlinuz
==> Starting build: '6.6.103-2-MANJARO'
  -> Running build hook: [base]
  -> Running build hook: [systemd]
  -> Running build hook: [shadowcopy]
shadowcopy: Using /etc/shadow
  -> Running build hook: [keyboard]
  -> Running build hook: [autodetect]
  -> Running build hook: [microcode]
  -> Running build hook: [modconf]
  -> Running build hook: [kms]
  -> Running build hook: [block]
  -> Running build hook: [sd-vconsole]
  -> Running build hook: [sd-encrypt]
  -> Running build hook: [openswap]
  -> Running build hook: [resume]
  -> Running build hook: [filesystems]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating zstd-compressed initcpio image: '/tmp/kernel-install.staging.c3TVVY/initrd'
  -> Early uncompressed CPIO image generation successful
==> Initcpio image generation successful
```

There should now be a new entry in `/boot/loader/entries/` named `6.6.103-2-MANJARO-rescue.conf` that can be used to boot into the rescue kernel.

```
# bootctl list
         type: Boot Loader Specification Type #1 (.conf)
        title: Manjaro Linux (6.6.103-2-MANJARO-rescue)
           id: rescue-6.6.103-2-MANJARO-rescue.conf
       source: /boot//loader/entries/rescue-6.6.103-2-MANJARO-rescue.conf (on the EFI System Partition)
     sort-key: manjaro
      version: 6.6.103-2-MANJARO-rescue
        linux: /boot//rescue/6.6.103-2-MANJARO-rescue/linux
       initrd: /boot//rescue/6.6.103-2-MANJARO-rescue/initrd
      options: root=UUID=4604eb05-9aeb-453f-9cd2-6d6e6f30ee9f rw apparmor=1 security=apparmor resume=UUID=d463e634-4e5a-4ca3-9de7-297df5e0ac08 udev.log_priority=3 add_efi_memmap nmi_watchdog>
```

## Uppgrade

Now that we have a backup of the current bootloader and kernel, we can proceed to upgrade the bootloader and kernel.

### Upgrade bootloader

To upgrade the `systemd-boot` bootloader, use the following command:

```bash
bootctl update
```

This will update the `systemd-boot` bootloader to the latest version available in the system.

### Upgrade kernel

To upgrade the kernel, use the package manager to install the latest kernel version, the method will depend on the distribution used.

On Arch Linux the upgrade can be done using:

```bash
sudo pacman -Syu linux
```

On Manjaro, you can use the `mhwd-kernel` command to install a new kernel version:

```bash
sudo mhwd-kernel -i linux616
```

This will install the latest stable kernel version available in the Manjaro repositories.

### Conclusion

You system should now be upgraded to the latest bootloader and kernel versions.

## Resuce tips

Here are some tips to use in case the new bootloader or kernel is not working as expected:

- If microcode updates are causing issues, you can try disabling them by adding the following parameters to the kernel command line:
  - dis_ucode_ldr

## Links

[kernel-parameters]: https://docs.kernel.org/admin-guide/kernel-parameters.html
[kernel-command-line]: https://man.archlinux.org/man/kernel-command-line.7
