# .zsh Config Modules

A clean, modular, and performance-focused Zsh configuration tailored for modern CLI tools, terminal-based workflows, and local AI assistance.

## Features

- **Modular Layout:** Organized configs split into environment, options, aliases, completions, and custom utilities.
- **Modern CLI Power:** Deeply integrated with `fzf`, `bat`, `eza`, `zoxide`, `ripgrep`, and `fd` for rapid navigation and search.
- **Local AI Dev Environment:** Out-of-the-box support for Ollama and Claude Code infrastructure.
- **Language Fast-Tracks:** Production-ready shortcuts and tools for **Go**, **Rust**, **Python**, and **Docker**.

## 📂 Structure

- env.zsh         exports, PATH, VISUAL
- completion.zsh  fpath, compinit
- options.zsh     setopt, keybindings
- aliases.zsh     all aliases (docker, git, cargo, sys, cli replacements)
- functions.zsh   custom functions (tvim, dump, groot, serve, ...)
- tools.zsh       bat, delta, fzf, zoxide, dust, procs, btm config
- ai.zsh          Ollama + Claude
- dev_extras.zsh  fzf/rg/fd/sd/bat/eza functions
