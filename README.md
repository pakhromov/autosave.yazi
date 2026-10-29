# autosave.yazi

A Yazi plugin that saves and restores tab session state automatically.

## Features

- Saves and Restores each tab's folder and cursor position.
- Restores the last saved session after a shortcut exit (e.g., Super+Q) or system shutdown.
- Skips session restoration with path arguments (e.g., yazi ~/foo), so the paths take priority.

## Installation

**Via ya pkg:**
```bash
ya pkg add pakhromov/autosave
```

**Manual:**
```bash
git clone https://github.com/pakhromov/autosave.yazi ~/.config/yazi/plugins/autosave.yazi
```

## Configuration

Add to `~/.config/yazi/init.lua` to enable autosave and auto-restore:
```lua
require("autosave"):setup()
```

## Usage

Startup restore happens automatically.
