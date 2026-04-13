-- lua/pg-docker/docker.lua

local M   = {}
local log = require("pg-docker.log")

local SEP = string.rep("─", 52)

-- ── Async job runner ──────────────────────────────────────────────
local function run(cmd, on_done)
  log.open()
  log.write("$ " .. cmd)
  log.write(SEP)

  vim.fn.jobstart({ "sh", "-c", cmd }, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then log.write(line) end
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then log.write("ERR: " .. line) end
      end
    end,
    on_exit = function(_, code)
      log.write(SEP)
      log.write(code == 0 and "✔  Done" or ("✘  Exited with code " .. code))
      if on_done then
        vim.schedule(function() on_done(code) end)
      end
    end,
  })
end

-- ── Check docker is available ─────────────────────────────────────
local function docker_ok()
  if vim.fn.executable("docker") == 0 then
    vim.notify("[pg-docker] docker not found in PATH", vim.log.levels.ERROR)
    return false
  end
  return true
end

-- ── Operations ────────────────────────────────────────────────────

function M.run(f)
  if not docker_ok() then return end
  log.clear()

  local cmd = table.concat({
    -- remove old container with same name if exists
    string.format("docker rm -f %s 2>/dev/null || true", f.container_name),
    "&&",
    string.format("docker pull postgres:%s", f.pg_version),
    "&&",
    string.format(
      "docker run -d --name %s -e POSTGRES_USER=%s -e POSTGRES_PASSWORD=%s -e POSTGRES_DB=%s -p %s:5432 postgres:%s",
      f.container_name,
      f.db_user,
      f.db_password,
      f.db_name,
      f.host_port,
      f.pg_version
    ),
  }, " ")

  run(cmd, function(code)
    if code ~= 0 then return end

    local conn = string.format(
      "postgresql://%s:%s@localhost:%s/%s",
      f.db_user, f.db_password, f.host_port, f.db_name
    )

    log.write("")
    log.write("  Container  : " .. f.container_name)
    log.write("  Image      : postgres:" .. f.pg_version)
    log.write("  Database   : " .. f.db_name)
    log.write("  User       : " .. f.db_user)
    log.write("  Port       : " .. f.host_port .. " → 5432")
    log.write("")
    log.write('  DATABASE_URL="' .. conn .. '"')
    log.write("")
    log.write("  Stop  : docker stop "  .. f.container_name)
    log.write("  Shell : docker exec -it " .. f.container_name ..
              " psql -U " .. f.db_user .. " -d " .. f.db_name)
    log.write("")

    -- copy DATABASE_URL to system clipboard
    local env_line = 'DATABASE_URL="' .. conn .. '"'
    vim.fn.setreg("+", env_line)
    vim.fn.setreg('"', env_line)
    vim.notify('[pg-docker] DATABASE_URL copied to clipboard ✔', vim.log.levels.INFO)
  end)
end

function M.stop(name)
  if not docker_ok() then return end
  log.clear()
  run("docker stop " .. name, nil)
end

function M.remove(name)
  if not docker_ok() then return end
  log.clear()
  run("docker rm -f " .. name, nil)
end

function M.logs(name)
  if not docker_ok() then return end
  log.clear()
  run("docker logs --tail 80 " .. name, nil)
end

function M.list()
  if not docker_ok() then return end
  log.clear()
  run(
    "docker ps -a --filter ancestor=postgres --format 'table {{.Names}}\\t{{.Status}}\\t{{.Ports}}'",
    nil
  )
end

-- Returns list of running postgres container names (for pickers)
function M.get_containers(cb)
  local result = {}
  vim.fn.jobstart(
    "docker ps -a --filter ancestor=postgres --format '{{.Names}}'",
    {
      stdout_buffered = true,
      on_stdout = function(_, data)
        for _, line in ipairs(data) do
          if line ~= "" then table.insert(result, line) end
        end
      end,
      on_exit = function()
        vim.schedule(function() cb(result) end)
      end,
    }
  )
end

return M
