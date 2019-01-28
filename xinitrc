export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
vmware-user-suid-wrapper &
xrdb -merge ~/.Xresources&

# -R restores the last pywal colorscheme that was in use.
wal -R

