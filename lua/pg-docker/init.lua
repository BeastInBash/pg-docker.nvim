-- pg-docker.nvim
-- Entry point: lua/pg-docker/init.lua

local M = {}

-- ── Lazy-load submodules ──────────────────────────────────────────
local config  = require("pg-docker.config")
local ui      = require("pg-docker.ui")
local docker  = require("pg-docker.docker")
local commands = require("pg-docker.commands")

-- Called automatically by plugin/pg-docker.vim on startup
function M._bootstrap()
  -- nothing needed yet; setup() is optional
end

-- Called by user in their init.lua / lazy spec
function M.setup(opts)
  config.apply(opts or {})
  commands.register()
end

-- Public API (also callable directly: require("pg-docker").create())
M.create      = function() require("pg-docker.wizard").start() end
M.quick_start = function() docker.run(config.get().defaults) end
M.stop        = function() ui.pick_container("stop",   docker.stop)   end
M.remove      = function() ui.pick_container("remove", docker.remove) end
M.logs        = function() ui.pick_container("logs",   docker.logs)   end
M.list        = docker.list
M.show_log    = function() require("pg-docker.log").open() end

return M
