-- lua/pg-docker/log.lua

local M = {}
local config = require("pg-docker.config")

local _buf = nil
local _win = nil

local function ensure_buf()
  if _buf and vim.api.nvim_buf_is_valid(_buf) then return end
  _buf = vim.api.nvim_create_buf(false, true)
  vim.bo[_buf].buftype   = "nofile"
  vim.bo[_buf].bufhidden = "hide"
  vim.bo[_buf].swapfile  = false
  vim.bo[_buf].filetype  = "pg-docker-log"
  vim.api.nvim_buf_set_name(_buf, "pg-docker://log")
  -- syntax highlights
  vim.api.nvim_buf_call(_buf, function()
    vim.cmd("syntax match PgDockerOk  /✔.*$/")
    vim.cmd("syntax match PgDockerErr /ERR:.*$/")
    vim.cmd("syntax match PgDockerCmd /^\\$.*/")
    vim.cmd("syntax match PgDockerSep /─\\+/")
    vim.cmd("hi def link PgDockerOk  DiagnosticOk")
    vim.cmd("hi def link PgDockerErr DiagnosticError")
    vim.cmd("hi def link PgDockerCmd Comment")
    vim.cmd("hi def link PgDockerSep NonText")
  end)
end

function M.write(line)
  ensure_buf()
  vim.bo[_buf].modifiable = true
  local lines = vim.split(line, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(_buf, -1, -1, false, lines)
  vim.bo[_buf].modifiable = false
  -- auto-scroll if visible
  if _win and vim.api.nvim_win_is_valid(_win) then
    local lc = vim.api.nvim_buf_line_count(_buf)
    pcall(vim.api.nvim_win_set_cursor, _win, { lc, 0 })
  end
end

function M.clear()
  ensure_buf()
  vim.bo[_buf].modifiable = true
  vim.api.nvim_buf_set_lines(_buf, 0, -1, false, {})
  vim.bo[_buf].modifiable = false
end

function M.open()
  ensure_buf()
  local cfg  = config.get()
  local ui   = vim.api.nvim_list_uis()[1]

  if cfg.output_style == "split" then
    -- open in a bottom split
    vim.cmd("botright 15split")
    _win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(_win, _buf)
  else
    -- floating window
    if _win and vim.api.nvim_win_is_valid(_win) then return end
    local w = math.floor(ui.width  * 0.65)
    local h = math.floor(ui.height * 0.45)
    _win = vim.api.nvim_open_win(_buf, true, {
      relative  = "editor",
      width     = w,
      height    = h,
      col       = math.floor((ui.width  - w) / 2),
      row       = math.floor((ui.height - h) / 2),
      style     = "minimal",
      border    = "rounded",
      title     = " 🐘 pg-docker ",
      title_pos = "center",
    })
    vim.wo[_win].winhl = "Normal:Normal,FloatBorder:Comment"
    vim.wo[_win].wrap  = true
    vim.wo[_win].number = false
  end

  -- q closes the window
  vim.keymap.set("n", "q", function()
    if _win and vim.api.nvim_win_is_valid(_win) then
      vim.api.nvim_win_close(_win, true)
      _win = nil
    end
  end, { buffer = _buf, nowait = true, silent = true })

  -- scroll to bottom
  local lc = vim.api.nvim_buf_line_count(_buf)
  if lc > 0 then pcall(vim.api.nvim_win_set_cursor, _win, { lc, 0 }) end
end

function M.buf() ensure_buf(); return _buf end

return M
