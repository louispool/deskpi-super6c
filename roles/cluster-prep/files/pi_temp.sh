#!/bin/bash
# Displays the ARM CPU and GPU temperature of a Raspberry Pi. Assumes `vcgencmd` has been installed
#
# Shamelessly copied from https://github.com/ricsanfre/pi-cluster/blob/master/ansible/roles/basic_setup/scripts/pi_temp

cpu=$(</sys/class/thermal/thermal_zone0/temp)
echo "$(date) @ $(hostname)"
echo "-------------------------------------------"
echo "GPU => $(vcgencmd measure_temp)"
echo "CPU => $((cpu / 1000))'C"
