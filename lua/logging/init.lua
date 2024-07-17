#!/usr/bin/env lua

local Logger = require('logging.logger')
local Config = require('logging.config')

local function warn(msg)
   vim.notify(msg, vim.log.levels.WARN, {})
end

local M = {}

---@type Logger[]
M.loggers = {}

--- One use method to log
---@param logger_name string
---@param payload Payload
---@param level LevelInt
---@param opts GlobalConfig
function M.log(logger_name, payload, level, opts)
   if not logger_name then
      warn("[Logger] No logger providad")
      return
   end
   if not payload then
      warn("[Logger] No payload provided")
      return
   end

   local logger = M.get_logger(logger_name, opts)
   if logger then
      return logger:_put(payload, level)
   else
      error("shouldnt happen")
   end
end

--- Get logger with logger_name
---@param logger_name string
---@param opts GlobalConfig
---@return Logger
function M.get_logger(logger_name, opts)
   ---@type Logger
   local logger = M.loggers[logger_name]
   if not logger then
      Config.update_config(opts)
      logger = Logger:_new(logger_name, Config.get_config())
      M.loggers[logger_name] = logger
   else
      logger:_update(opts)
   end

   return logger
end

M.get_config = Config.get_config
M.setup = Config.setup

return M
