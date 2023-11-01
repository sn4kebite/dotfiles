#!/bin/bash

case $ROFI_RETV in
	0)
		echo -e "\0prompt\x1fNew name"
		echo -en "\0message\x1fRenaming workspace: "
		i3-msg -t get_workspaces | jq -r '.[] | select(.focused).name'
		;;
	2)
		i3-msg rename workspace to "\"$1\"" >&2
		exit 0
		;;
esac
