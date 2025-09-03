#!/bin/bash

install-kernel_command() {
  # Use custom kernel-install configuration
  export KERNEL_INSTALL_CONF_ROOT="$KERNEL_INSTALL_CONF"
  export KERNEL_INSTALL_PLUGINS="$KERNEL_INSTALL_CONF/install.d/50-mkinitcpio-rescue.install $KERNEL_INSTALL_CONF/install.d/90-loaderentry.install"
  # Set sort-key in boot loader entry, so that it appears after the main Manjaro entries
  export IMAGE_ID=manjaro-rescue

  # linux kernel version to install
  sudo -E --preserve-env=KERNEL_INSTALL_CONF_ROOT,KERNEL_INSTALL_PLUGINS,IMAGE_ID \
    kernel-install add "${KERNEL_VERSION}-rescue" "/usr/lib/modules/$KERNEL_VERSION/vmlinuz"
}
