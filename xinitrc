# used for testing other stuff
#exec gnome-session
#exec wmfs
#exec openbox-session

export XMODIFIERS=@im=uim
setxkbmap no
setxkbmap -option compose:caps
xset b off
xset s off
xset dpms 600
xset fp+ /home/snakebite/.fonts/
xset fp rehash
numlockx on
wakoopa &
skype &
keepassx &
uim-xim &
cow-notify/cow-notify &
exec ck-launch-session awesome
