grantpermissions:
	chmod +x ./macsetup
	chmod +x ./linkfolders
	chmod +x ./install
macsetup: grantpermissions ./macsetup ./linkfolders ./install
tmuxupdate:
	tmux source-file ~/.tmux.conf

hxconfig:
	rm -f helix/.config/helix/config.toml
	./utils/toml-merge/toml-merge.ml -d ./helix/.config/helix/config/ -o ./helix/.config/helix/
