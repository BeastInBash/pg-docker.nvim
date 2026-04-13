-- lua/pg-docker/config.lua

local M = {}

local _cfg = {
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
  -- "split" | "float" — where to show docker output
  output_style  = "float",
}

function M.apply(opts)
  _cfg = vim.tbl_deep_extend("force", _cfg, opts)
end

function M.get()
  return _cfg
end

return M
