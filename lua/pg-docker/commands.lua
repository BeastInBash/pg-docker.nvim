-- lua/pg-docker/commands.lua

local M = {}

local registered = false

function M.register()
  if registered then return end
  registered = true

  local pg = require("pg-docker")
  local cfg = require("pg-docker.config").get()

  local cmds = {
    { name = "PgCreate",     fn = pg.create,      desc = "Wizard: create a new PostgreSQL container" },
    { name = "PgQuickStart", fn = pg.quick_start, desc = "Start container with configured defaults" },
    { name = "PgStop",       fn = pg.stop,        desc = "Stop a running PostgreSQL container" },
    { name = "PgRemove",     fn = pg.remove,      desc = "Remove a PostgreSQL container" },
    { name = "PgLogs",       fn = pg.logs,        desc = "Tail logs of a PostgreSQL container" },
    { name = "PgList",       fn = pg.list,        desc = "List all postgres Docker containers" },
    { name = "PgLog",        fn = pg.show_log,    desc = "Open the pg-docker output window" },
  }

  for _, c in ipairs(cmds) do
    vim.api.nvim_create_user_command(c.name, c.fn, { desc = c.desc })
  end

  -- optional keymaps
  if cfg.keymaps then
    local p = cfg.keymap_prefix
    vim.keymap.set("n", p .. "n", pg.create,      { desc = "pg-docker: new (wizard)" })
    vim.keymap.set("n", p .. "q", pg.quick_start, { desc = "pg-docker: quick start" })
    vim.keymap.set("n", p .. "s", pg.stop,        { desc = "pg-docker: stop" })
    vim.keymap.set("n", p .. "r", pg.remove,      { desc = "pg-docker: remove" })
    vim.keymap.set("n", p .. "l", pg.logs,        { desc = "pg-docker: logs" })
    vim.keymap.set("n", p .. "L", pg.list,        { desc = "pg-docker: list" })
    vim.keymap.set("n", p .. "o", pg.show_log,    { desc = "pg-docker: open log" })
  end
end

return M
