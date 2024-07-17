#!/usr/bin/lua

local logging = require('logging')

local start = vim.health.start
local ok = vim.health.ok
local warn = vim.health.warn
local error = vim.health.error

local M = {}

M.check = function(opts)
  opts = opts or {}
  logging.setup(opts)

  start("logging.nvim")

  if vim.fn.has("nvim-0.9.0") ~= 1 then
    error("Noice requires Neovim >= 0.9.0")
    if not opts.checkhealth then
      return
    end
  else
    ok("**Neovim** >= 0.9.0")
    if opts.checkhealth and vim.fn.has("nvim-0.10.0") ~= 1 then
      warn("**Neovim** >= 0.10 is highly recommended, since it fixes some issues related to `vim.ui_attach`")
    end
  end

  local log = vim.log.log
  if log and type(log) == 'function' then
    ok("vim.log.log exists and it is a function")
  else
    error("vim.log.log does not exists")
  end

  local get_logger = vim.log.get_logger
  if get_logger and type(get_logger) == 'function' then
    ok("get_logger exists and it is a function")
  else
    error("get_logger does not exists")
  end

  local reqs = {
    "types", "config", "logger"
  }

  local exists = require('logging')
  if exists then
    ok("main module's ok")
  else
    error("error on main module")
  end

  for _, req in ipairs(reqs) do
    local _ok = pcall(require, 'logging' .. req)
    if _ok then
      ok(req .. ' submodule loaded')
    else
      error("error on " .. req .. " submodule")
    end
  end

  return true
end


return M
