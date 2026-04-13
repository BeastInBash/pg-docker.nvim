-- lua/pg-docker/wizard.lua

local M      = {}
local config = require("pg-docker.config")
local ui     = require("pg-docker.ui")
local docker = require("pg-docker.docker")

local function steps()
  local d = config.get().defaults
  return {
    { key = "container_name", label = "Container name",     default = d.container_name },
    { key = "pg_version",     label = "PostgreSQL version", default = d.pg_version },
    { key = "db_name",        label = "Database name",      default = d.db_name },
    { key = "db_user",        label = "DB user",            default = d.db_user },
    { key = "db_password",    label = "Password",           default = d.db_password },
    { key = "host_port",      label = "Host port",          default = d.host_port },
  }
end

local function collect(list, idx, acc, done)
  if idx > #list then done(acc); return end
  local s = list[idx]
  vim.ui.input({
    prompt  = string.format("[%d/%d] %s [%s]: ", idx, #list, s.label, s.default),
    default = s.default,
  }, function(val)
    if val == nil then
      vim.notify("[pg-docker] wizard cancelled", vim.log.levels.WARN)
      return
    end
    acc[s.key] = (val == "" and s.default or val)
    -- schedule next prompt to avoid nested ui.input issues
    vim.schedule(function()
      collect(list, idx + 1, acc, done)
    end)
  end)
end

function M.start()
  collect(steps(), 1, {}, function(fields)
    ui.confirm(fields, function()
      docker.run(fields)
    end)
  end)
end

return M
