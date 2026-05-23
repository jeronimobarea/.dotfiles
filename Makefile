.PHONY: all setup themes helix-config refresh

all: themes helix-config refresh

setup:
	bash scripts/setup.sh

themes:
	python3 scripts/build_theme.py

helix-config:
	bash scripts/build_helix_config.sh

refresh:
	bash scripts/refresh_configs.sh
