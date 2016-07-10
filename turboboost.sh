#!/bin/bash -   
#title          :turboboost.sh
#description    :disables or enables turbo boost on all cores of intel cpu
#author         :Rylan Shearn
#date           :20151018
#last tested	:20160710 on Ubuntu 15.10 (not working on 16.04)
#version        :1.0    
#usage          :./turboboost.sh
#notes          :       
#bash_version   :4.3.30(1)-release
#============================================================================

### BEGIN INIT INFO
# Provides: stops intel CPU turbo boost
# Required-Start:    $local_fs $syslog
# Required-Stop:     $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: stop intel CPU turbo boost
### END INIT INFO

#check status with cpupower frequency-info

sudo modprobe msr 
sudo wrmsr -p0 0x1a0 0x4000850089
sudo wrmsr -p1 0x1a0 0x4000850089
sudo wrmsr -p2 0x1a0 0x4000850089
sudo wrmsr -p3 0x1a0 0x4000850089
