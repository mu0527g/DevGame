
local skynet = require "skynet"

--- 日志模块
local log = {}

--- 日志级别
local LOG_LEVEL = {
    DEBUG   = 1,    -- 调试级别
    INFO    = 2,    -- 信息级别
    WARN    = 3,    -- 警告级别
    ERROR   = 4,    -- 错误级别
    FATAL   = 5     -- 致命级别
}

--- 输出级别
local OUT_PUT_LEVEL = LOG_LEVEL.DEBUG

--- 日志级别描述
local LOG_LEVEL_DESC = {
    [1] = "DEBUG",
    [2] = "INFO",
    [3] = "WARN",
    [4] = "ERROR",
    [5] = "FATAL",
}

--- 格式化字符串
---@param fmt string 格式化字符串
---@vararg any 格式化参数
---@return string 格式化后的字符串
local function format(fmt, ...)
    local ok, str = pcall(string.format, fmt, ...)
    if ok then
        return str
    else
        return "error format : " .. fmt
    end
end

--- 发送日志
---@param level number 日志级别
---@vararg any 日志内容
local function send_log(level, ...)
    if level < OUT_PUT_LEVEL then
        return
    end

    local str
    if select("#", ...) == 1 then
        str = tostring(...)
    else
        str = format(...)
    end

    local info = debug.getinfo(3)
	if info then
		local filename = string.match(info.short_src, "[^/.]+.lua$")
		str = string.format("[%s:%d] %s", filename, info.currentline, str)
    end
    
    skynet.send(".logger", "lua", "logging", LOG_LEVEL_DESC[level], str)
end

--- 调试级别日志
---@param fmt string 格式化字符串
---@vararg any 格式化参数
function log.debug(fmt, ...)
    send_log(LOG_LEVEL.DEBUG, fmt, ...)
end

--- 信息级别日志
---@param fmt string 格式化字符串
---@vararg any 格式化参数
function log.info(fmt, ...)
    send_log(LOG_LEVEL.INFO, fmt, ...)
end

--- 警告级别日志
---@param fmt string 格式化字符串
---@vararg any 格式化参数
function log.warn(fmt, ...)
    send_log(LOG_LEVEL.WARN, fmt, ...)
end

--- 错误级别日志
---@param fmt string 格式化字符串
---@vararg any 格式化参数
function log.error(fmt, ...)
    send_log(LOG_LEVEL.ERROR, fmt, ...)
end

--- 致命级别日志
---@param fmt string 格式化字符串
---@vararg any 格式化参数
function log.fatal(fmt, ...)
    send_log(LOG_LEVEL.FATAL, fmt, ...)
end

return log