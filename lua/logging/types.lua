#!/usr/bin/lua

---@alias ObjectTable table<string, string>
---@alias Payload string|ObjectTable|ObjectTable[]
---@alias LevelInt integer
---@alias LevelStr string
---@alias Levels {[LevelStr]: LevelInt}
---@alias PayloadStr string
---@alias Content LevelStr|PayloadStr
---@alias ContentPickable fun(): Content
---@alias ContentGiver fun(PayloadStr,LevelInt):table<string|table<string,ContentPickable>, ContentPickable>
---@alias ContentPicker fun(ContentGiver): ContentPickable
---@alias CompositionPiece string|ContentPicker
---@alias Composition CompositionPiece[]

---@class SepConf
---@field enabled boolean
---@field str string
---@field before boolean
---@field after boolean

---@class GlobalConfig
---@field public composition Composition
---@field public ext string
---@field public min_level LevelInt
---@field public path string
---@field public register table|false
---@field public sep SepConf

---@class LoggerConfig
---@field public composition Composition
---@field public default_level LevelInt
---@field public min_level LevelInt
---@field public sep SepConf

---@class Logger
---@field public logger string
---@field public handler file*
---@field public config LoggerConfig
