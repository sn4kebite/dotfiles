echo "args: $*"
while [ "$1" = "xterm" ] || [ "$1" = "startx" ]; do
	shift
done
if [ "$DISPLAY" = ":0" ]; then
	skype &
	keepassx &
	uim-xim &
	./notipyd &
fi
XINITRC="$HOME/.xinitrc.$1"
[ -f $XINITRC ] && source $XINITRC
exit 0
