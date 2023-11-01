#!/bin/bash

case $ROFI_RETV in
	0)
		echo -e "\0prompt\x1fMove to workspace"
		#echo -e "\0message\x1fEnter a new name to create a new workspace."
		i3-msg -t get_workspaces | jq -r '.[].name'
		;;
	1|2)
		i3-msg move container to workspace "$1" >&2
		exit 0
		;;
esac
