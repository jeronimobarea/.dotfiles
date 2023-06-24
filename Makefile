grant_permissions:
	chmod +x ./macsetup
	chmod +x ./linkfolders
	chmod +x ./install
mac_setup: grant_permissions ./macsetup ./linkfolders ./install
tmux_update:
	tmux source-file ~/.tmux.conf
