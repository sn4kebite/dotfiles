if [ "$TERM" != "linux" ]; then
	source /etc/profile
else
	setterm -blength 0
fi
if [ "$TERM" == "rxvt-unicode" ]; then
	PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \W \$\[\033[00m\] '
else
	PS1='\[\033k\033\134\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \W \$\[\033[00m\] '
fi
EDITOR=vim
BROWSER=google-chrome
alias ls='ls --color=auto'
alias ll='ls -lh'
alias vi='vim'

alias mpv='mplayer -vo vdpau -vc ffh264vdpau,ffmpeg12vdpau,ffodivxvdpau,ffwmv3vdpau,ffvc1vdpau,'

alias pcs='packer -S'
alias pcss='packer -Ss'
alias pcql='pacman -Ql'
alias pcqi='pacman -Qi'
alias pcqo='pacman -Qo'
alias pcqs='pacman -Qs'
alias pcsi='packer -Si'

alias r='ranger'

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

eval `dircolors -b`
PATH=$PATH:~/.bin
shopt -s globstar
HISTCONTROL=ignoredups
#ARTOOLKIT_CONFIG='dv1394src ! dvdemux ! dvdec ! ffmpegcolorspace ! video/x-raw-rgb,bpp=24 ! identity name=artoolkit ! fakesink'
ARTOOLKIT_CONFIG="v4l2src ! ffmpegcolorspace ! video/x-raw-rgb,bpp=24,width=640,height=480 ! identity name=artoolkit ! fakesink"
SDL_AUDIODRIVER=alsa
HISTFILESIZE=2000

export PS1 EDITOR BROWSER PATH HISTCONTROL ARTOOLKIT_CONFIG SDL_AUDIODRIVER HISTFILESIZE
