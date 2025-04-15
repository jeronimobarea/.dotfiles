# Zenburn colors
set -g status-bg colour235   # dark grey (background)
set -g status-fg colour223   # light beige (foreground)
set -g status-style default

# Window title colors
set-window-option -g window-status-style fg=colour144,bg=colour235  # light green on dark grey
set-window-option -g window-status-current-style fg=colour223,bg=colour237,bold  # beige on grey

# Pane border
set -g pane-border-style fg=colour237
set -g pane-active-border-style fg=colour107  # greenish

# Message text
set -g message-style bg=colour236,fg=colour223  # dark background, light text

# Command prompt
set -g message-command-style bg=colour236,fg=colour223

# Mode (copy mode etc)
set -g mode-style bg=colour236,fg=colour223

# Clock mode
set -g clock-mode-colour colour107
set -g clock-mode-style 24

# Status Left/Right
set -g status-left-length 30
set -g status-right-length 150
set -g status-left "#[fg=colour108,bold]#S #[fg=colour239]|"
set -g status-right "#[fg=colour239]%Y-%m-%d #[fg=colour239]%H:%M #[default]"

# Bell
set -g visual-bell on
set -g bell-action any

