grantpermissions:
	chmod +x ./macsetup
	chmod +x ./linkfolders
	chmod +x ./install
macsetup: grantpermissions ./macsetup ./linkfolders ./install
tmuxupdate:
	tmux source-file ~/.tmux.conf
