# ~/.config/fish/config.fish

# ── Suppress greeting ─────────────────────────────────────────────────────────
set -g fish_greeting ""

# ── PATH ──────────────────────────────────────────────────────────────────────
fish_add_path ~/.local/bin

# ── Aliases (eza) ─────────────────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias lt='eza --tree --icons'
alias l='eza -lh --icons'

# ── Starship prompt ───────────────────────────────────────────────────────────
starship init fish | source
