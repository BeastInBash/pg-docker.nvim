-- lua/pg-docker/ui.lua

local M      = {}
local docker = require("pg-docker.docker")

-- Pick a running postgres container then call action(name)
function M.pick_container(verb, action)
  docker.get_containers(function(names)
    if #names == 0 then
      vim.notify("[pg-docker] No postgres containers found", vim.log.levels.WARN)
      return
    end
    if #names == 1 then
      action(names[1])
      return
    end
    vim.ui.select(names, {
      prompt = "Select container to " .. verb .. ":",
    }, function(choice)
      if choice then action(choice) end
    end)
  end)
end

-- Show a read-only review float; keymaps: y = confirm, q/n/Esc = cancel
function M.confirm(fields, on_yes)
  local conn = string.format(
    "postgresql://%s:***@localhost:%s/%s",
    fields.db_user, fields.host_port, fields.db_name
  )
  local lines = {
    "",
    "  Container  : " .. fields.container_name,
    "  Image      : postgres:" .. fields.pg_version,
    "  Database   : " .. fields.db_name,
    "  User       : " .. fields.db_user,
    "  Password   : ********",
    "  Port       : " .. fields.host_port .. " → 5432",
    "  Conn       : " .. conn,
    "",
    "  y  →  start container     q / n  →  cancel",
    "",
  }

  local width = 58
  local buf   = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local ui_info = vim.api.nvim_list_uis()[1]
  local win = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = #lines,
    col       = math.floor((ui_info.width  - width)    / 2),
    row       = math.floor((ui_info.height - #lines)   / 2),
    style     = "minimal",
    border    = "rounded",
    title     = " 🐘 review ",
    title_pos = "center",
  })
  vim.wo[win].winhl = "Normal:Normal,FloatBorder:Comment"

  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  end

  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "y",     function() close(); on_yes() end, opts)
  vim.keymap.set("n", "n",     close, opts)
  vim.keymap.set("n", "q",     close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
end

return M
