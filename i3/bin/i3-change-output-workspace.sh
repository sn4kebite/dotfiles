#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 INDEX"
	exit 1
fi

index="$1"
shift

i3-msg -t get_workspaces | jq -r '.[] | .output + ";" + (.num | tostring) + ";" + .name + ";" + (.focused | tostring)' | ( \
tags=()
last_outout=''
use_output=''
while IFS=';' read -r output num name focused; do
	if [[ "$focused" == "true" ]]; then
		focused=1
		use_output="$output"
	else
		if [[ -n "$use_output" && "$output" != "$use_output" ]]; then
			break
		fi
		focused=0
	fi
	if [[ "$output" != "$last_outout" ]]; then
		tags=()
		last_outout="$output"
	fi
	tags+=("$name")
done
if [[ $index -lt ${#tags[@]} ]]; then
	i3-msg workspace "${tags[$index]}"
else
	i3-msg workspace "$output-$[$index + 1]"
fi
)
