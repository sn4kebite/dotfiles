echo "args: $*"
while [ "$1" = "xterm" ] || [ "$1" = "startx" ]; do
	shift
done
XINITRC="$HOME/.xinitrc.$1"
[ -f $XINITRC ] && source $XINITRC || exec $1
exit 0
