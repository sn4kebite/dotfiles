if [ "$TERM" != "linux" ]; then
	source /etc/profile
	_PROMPT_COMMAND='DEFTITLE="${USER}@${HOSTNAME}:${PWD/$HOME/~} $TITLE"; echo -ne "\033]0;${TITLE:-$DEFTITLE}\007"'
	if [ -n "$PROMPT_COMMAND" ]; then
		PROMPT_COMMAND="${PROMPT_COMMAND}; "
	fi
	PROMPT_COMMAND="${_PROMPT_COMMAND}"
else
	setterm -blength 0
fi

if [ "$TERM" == "rxvt-unicode" ] || [ "$TERM" == "xterm-kitty" ]; then
	PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \W \$\[\033[00m\] '
else
	PS1='\[\033k\033\134\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \W \$\[\033[00m\] '
fi
EDITOR=vim
BROWSER=google-chrome-stable
alias ls='ls --color=auto'
alias ll='ls -lh'
alias vi='vim'
alias viro='vim -Rn'
alias cal='cal -m'

#alias mpvd='mplayer -vo vdpau -vc ffh264vdpau,ffmpeg12vdpau,ffodivxvdpau,ffwmv3vdpau,ffvc1vdpau,'

alias pcs='pacaur -S'
alias pcss='pacaur -Ss'
alias pcql='pacman -Ql'
alias pcqi='pacman -Qi'
alias pcqo='pacman -Qo'
alias pcqs='pacman -Qs'
alias pcsi='pacaur -Si'
alias pcfs='pacman -Fs'

alias r='ranger'
#alias steam='~/.bin/steam'
#alias icat='kitty +kitten icat'

function aew() {
	if [ $# -ne 2 ]; then
		echo "USAGE: ae${1:0:1} name"
		return
	fi
	aectl $1 ~/.aectl/$2
}

function aes() {
	aew save $1
}
function ael() {
	aew load $1
}
function t() {
	TITLE="$*"
}

#alias scrot='scrot -z -e "mv \$f ~/shots/; echo \\\\~/shots/\$f"'

if [ -z "$LS_COLORS" ]; then
	eval `dircolors -b`
fi
PATH=$PATH:~/.bin:~/bin
shopt -s globstar
HISTCONTROL=ignoreboth
#ARTOOLKIT_CONFIG='dv1394src ! dvdemux ! dvdec ! ffmpegcolorspace ! video/x-raw-rgb,bpp=24 ! identity name=artoolkit ! fakesink'
ARTOOLKIT_CONFIG="v4l2src ! ffmpegcolorspace ! video/x-raw-rgb,bpp=24,width=640,height=480 ! identity name=artoolkit ! fakesink"
#SDL_AUDIODRIVER=alsa
SDL_AUDIODRIVER=pulse
SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
HISTFILESIZE=2000
FG_ROOT=/usr/share/FlightGear/data/
_JAVA_AWT_WM_NONREPARENTING=1
_ZO_EXCLUDE_DIRS=/mnt/raid/.temp

. /usr/share/fzf/key-bindings.bash
eval "$(zoxide init bash)"

LIBVA_DRIVER_NAME=vdpau

export PROMPT_COMMAND PS1 EDITOR BROWSER PATH HISTCONTROL ARTOOLKIT_CONFIG SDL_AUDIODRIVER SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS HISTFILESIZE _JAVA_AWT_WM_NONREPARENTING LIBVA_DRIVER_NAME

#complete -C /usr/bin/mcli mc
