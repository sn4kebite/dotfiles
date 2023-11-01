#!/bin/bash

case $ROFI_RETV in
	0)
		echo -e "\0prompt\x1fFind workspace"
		#echo -e "\0message\x1fEnter a new name to create a new workspace."
		i3-msg -t get_workspaces | jq -r '.[].name'
		;;
	1|2)
		i3-msg workspace "$1" >&2
		exit 0
		;;
esac
