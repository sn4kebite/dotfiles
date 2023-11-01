#!/bin/bash

if bluetoothctl show | grep Powered | grep -q yes; then
	bluetoothctl power off
else
	bluetoothctl power on
fi
