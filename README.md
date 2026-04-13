# 🐘 pg-docker.nvim

A Neovim plugin to spin up, manage and connect to **PostgreSQL Docker containers** without leaving your editor.

---

## Features

- Step-by-step wizard to create containers (`PgCreate`)
- Quick-start with your saved defaults (`PgQuickStart`)
- Stop / remove / tail logs via command or keymap
- Async — never blocks the editor
- Output in a floating window (or bottom split)
- Auto-copies `DATABASE_URL` to clipboard after start
- Works with `dressing.nvim` / `telescope-ui-select` for nicer pickers

---

## Requirements

- Neovim `>= 0.9`
- [Docker](https://docs.docker.com/get-docker/) installed and running

---

## Installation

### lazy.nvim (recommended)

```lua
{
  "YOUR_GITHUB_USERNAME/pg-docker.nvim",
  cmd = { "PgCreate", "PgQuickStart", "PgStop", "PgRemove", "PgLogs", "PgList", "PgLog" },
  opts = {},
}
```

With custom defaults and keymaps:

```lua
{
  "YOUR_GITHUB_USERNAME/pg-docker.nvim",
  cmd = { "PgCreate", "PgQuickStart", "PgStop", "PgRemove", "PgLogs", "PgList", "PgLog" },
  keys = {
    { "<leader>pgn", desc = "pg-docker: new container" },
    { "<leader>pgq", desc = "pg-docker: quick start" },
    { "<leader>pgs", desc = "pg-docker: stop" },
    { "<leader>pgr", desc = "pg-docker: remove" },
    { "<leader>pgl", desc = "pg-docker: logs" },
    { "<leader>pgL", desc = "pg-docker: list" },
  },
  opts = {
    defaults = {
      container_name = "myapp-db",
      pg_version     = "16",
      db_name        = "mydb",
      db_user        = "admin",
      db_password    = "secret",
      host_port      = "5432",
    },
    keymaps       = true,
    keymap_prefix = "<leader>pg",
    output_style  = "float",  -- "float" | "split"
  },
}
```

### packer.nvim

```lua
use {
  "YOUR_GITHUB_USERNAME/pg-docker.nvim",
  config = function()
    require("pg-docker").setup({})
  end
}
```

---

## Commands

| Command | Description |
|---|---|
| `:PgCreate` | Step-by-step wizard to create a container |
| `:PgQuickStart` | Start instantly with your configured defaults |
| `:PgStop` | Stop a running container |
| `:PgRemove` | Remove a container |
| `:PgLogs` | Tail the last 80 lines of container logs |
| `:PgList` | List all postgres containers |
| `:PgLog` | Re-open the output window |

---

## Default Keymaps

Enable with `keymaps = true` in `setup()`.

| Key | Action |
|---|---|
| `<leader>pgn` | New container (wizard) |
| `<leader>pgq` | Quick start |
| `<leader>pgs` | Stop |
| `<leader>pgr` | Remove |
| `<leader>pgl` | Logs |
| `<leader>pgL` | List |
| `<leader>pgo` | Open log window |

---

## Configuration

Full config with defaults:

```lua
require("pg-docker").setup({
  defaults = {
    container_name = "postgresDB",
    pg_version     = "16",
    db_name        = "mydb",
    db_user        = "admin",
    db_password    = "password",
    host_port      = "5432",
  },
  keymaps       = false,
  keymap_prefix = "<leader>pg",
  output_style  = "float",   -- "float" | "split"
})
```

---

## Tips

- After `PgCreate` or `PgQuickStart`, the `DATABASE_URL` is automatically copied to your clipboard.
- If you have [dressing.nvim](https://github.com/stevearc/dressing.nvim) installed, all `vim.ui.input` and `vim.ui.select` calls will use it automatically.
- Use `output_style = "split"` if you prefer a persistent bottom panel over a floating window.

---

## License

MIT
