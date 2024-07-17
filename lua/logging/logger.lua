#!/usr/bin/lua


---@param value any
---@param name (integer|string)?
---@return string
local function format_content(value, name)
   local str = ""
   if name then str = name .. " -> " end
   return str .. tostring(value)
end

---@param obj Payload
---@return string
local function parse(obj)
   local output
   if type(obj) == "table" then
      for name, value in pairs(obj) do
         local t = type(obj[1])
         if t == "table" then
            output = format_content(value, name)
         elseif t == "string" then
            output = format_content(obj)
         end
      end
   else
      output = obj
   end

   return output
end

---@param path string
---@param logger_name string
---@param ext string
---@return file*
local function create_handler(path, logger_name, ext)
   local filepath = path .. "/" .. logger_name .. "." .. ext
   os.execute("touch " .. filepath)
   local handler = io.open(filepath, "a+")
   if not handler or type(handler) == "string" then
      error("couldnt create handler " .. logger_name)
   end
   return handler
end

---@param composition Composition
---@param payload_str string
---@param level LevelInt
---@return string
local function process_composition(composition, payload_str, level)
   local str_pieces = {}
   for _, piece in ipairs(composition) do
      if type(piece) == "string" then
         table.insert(str_pieces, piece)
      elseif type(piece) == "function" then
         local str_piece = piece(ContentGiver(payload_str, level))
         table.insert(str_pieces, str_piece)
      else
         error("Type " .. type(piece) .. " not supported")
      end
   end

   return table.concat(str_pieces)
end

---@class Logger
local Logger = {}

--- Create a new logger
---@param logger_name string
---@param opts GlobalConfig
---@return Logger
function Logger:_new(logger_name, opts)
   self.logger = logger_name
   self.handler = create_handler(opts.path, logger_name, opts.ext)
   self:_update(opts)

   return self
end

---@param opts GlobalConfig
function Logger:_update(opts)
   opts = opts or {}
   ---@type LoggerConfig
   self.config = {
      composition = opts.composition or self.config.composition,
      default_level = opts.default_level or self.config.default_level,
      min_level = opts.min_level or self.config_min_level,
      sep = opts.sep == false and opts.sep or self.config.sep,
   }

   local sep = self.config.sep
   if sep.enabled then
      if not sep.str or type(sep.str) ~= "string" then
         warn("[Logger]: Wanted separator but it was not provided")
      end
   end
end

---Writes to logger handler
---@param payload Payload
---@param level LevelInt
function Logger:_put(payload, level)
   level = level or self.config.default_level
   if level > self.config.min_level then return end

   if self.config.sep.before then self:_put_sep(self.config.sep.str) end

   local payload_str = parse(payload)
   local output = process_composition(self.config.composition, payload_str, level)
   self.handler:write(output, "\n")

   if self.config.sep.after then self:_put_sep(self.config.sep.str) end

   self.handler:flush()
end

Logger.log = Logger._put

--- Writes separator to logger handler
---@param sep string
function Logger:_put_sep(sep)
   if sep then
      self.handler:write(sep, "\n")
   end
end

return Logger
