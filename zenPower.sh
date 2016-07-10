#!/bin/bash
# ---------------------------------------------------------------------------
# zenPower.sh - modifies a number of power saving settings by modifying kernel boot arguments (DANGER: please test these arguments on your own system before relying on this script!)

# Copyright 2016, Rylan Shearn
  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

# Usage: zenPower.sh [-h|--help]

# Revision history:
# 2016-07-10 Created by Rylan Shearn
# ---------------------------------------------------------------------------

PROGNAME=${0##*/}
VERSION="0.1"

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  clean_up
  exit 1
}

graceful_exit() {
  clean_up
  exit
}

signal_exit() { # Handle trapped signals
  case $1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}

usage() {
  echo -e "Usage: $PROGNAME [-h|--help]
  Changes a number of power settings by modifying kernel boot arguments:
  - frame buffer compression -  reduces the memory bandwidth on screen refereshes
  - Intel RC6 - GPU enters a lower power state when idling
  - DRM vblank off delay - Direct Rendering Manager reduces 
    wakeup events and theoretically saves power
  - NMI Watchdog - turning off saves a fraction of power

  - the grub boot loader will be backed up at ~/Documents/
      - copy this backup file back to /etc/default/ if you have problems booting

  WARNING: Also enables Agressive Link Power Management
  - There is a possibility that ALPM may aggressively power down the SATA link 
    prematurely or incorrectly and cause data corruption or loss
  - please test on your own system, otherwise apply this at your own risk"
}

help_message() {
  cat <<- _EOF_
  $PROGNAME ver. $VERSION
  modifies a number of power saving settings by modifying kernel boot arguments 
  (DANGER: please test these arguments on your own system before relying on this script!)

  $(usage)

  Options:
  -h, --help  Display this help message and exit.

  NOTE: You must be the superuser to run this script.

_EOF_
  return
}

# Trap signals
trap "signal_exit TERM" TERM HUP
trap "signal_exit INT"  INT

# Check for root UID
if [[ $(id -u) != 0 ]]; then
  error_exit "You must be the superuser to run this script."
fi

# Parse command-line
while [[ -n $1 ]]; do
  case $1 in
    -h | --help)
      help_message; graceful_exit ;;
    -* | --*)
      usage
      error_exit "Unknown option $1" ;;
    *)
      echo "Argument $1 to process..." ;;
  esac
  shift
done

# Main logic

#backup grub to Documents directory (will not overwrite if backup already exists)
cp -n /etc/default/grub ~/Documents/ || True

#add entries to kernel boot arguments
sudo sed -i -e '
s/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i915.i915_enable_fbc=1 i915.i915_enable_rc6=1 drm.vblankoffdelay=1 nmi_watchdog=0"/g
' /etc/default/grub

#update grub
sudo update-grub

#Enable Aggressive Link Power Management (DANGEROUS - TEST BEFORE USE!)
echo SATA_ALPM_ENABLE=true | sudo tee /etc/pm/config.d/sata_alpm

graceful_exit

