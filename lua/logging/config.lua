#!/usr/bin/lua

-- ---@param provider FuncPath
-- ---@return string
-- local function normalize_path(provider)
--    local p = provider
--    if type(provider) == 'function' then
--       p = provider()
--    end
--
--    if type(p) == "table" then
--       return p[1]
--    elseif type(p) == "string" then
--       return p
--    end
--
--    return default_config.path()[1]
-- end

local M = {}

---@type Levels
M.levels = vim.log.levels

---@type ContentGiver
function ContentGiver(payload_str, level_int)
   local self = { level = level_int, payload = payload_str }
   local F = {}
   F.level = {}

   ---@return LevelStr
   local function find_level_str()
      ---@type Levels
      for k, v in ipairs(M.levels) do
         if k == self.level then
            return v
         end
      end

      return ""
   end

   function F.payload()
      return self.payload
   end

   ---@type ContentPickable
   function F.level.number()
      return self.level
   end

   ---@type ContentPickable
   function F.level.lower()
      return find_level_str():lower()
   end

   ---@type ContentPickable
   function F.level.upper()
      return find_level_str():upper()
   end

   return F
end

---@type GlobalConfig
local global_config = {
   composition = {
      function() return vim.fn.strftime("%d/%m %X") end,
      " [",
      function(picker) return picker.level.upper() end,
      "]: ",
      function(picker) return picker.payload() end
   },
   ext = "log",
   min_level = M.levels.WARN,
   path = vim.fn.stdpath("state") .. "",
   register = vim.lop,
   sep = {
      enabled = false,
      str = "------------",
      before = true,
      after = false
   }
}

---@param opts GlobalConfig?
function M.update_config(opts)
   global_config = vim.tbl_deep_extend('force', global_config, opts or {})
end

function M.get_config()
   return global_config
end

---@param opts GlobalConfig?
function M.setup(opts)
   M.update_config(opts)

   if global_config.register and type(global_config.register) == "table" then
      table.insert(global_config.register, M.log)
      table.insert(global_config.register, M.get_logger)
   end
end

return M
