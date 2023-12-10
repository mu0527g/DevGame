-- 日志记录器模块
-- 该模块用于记录日志，并支持按小时切割日志文件

local skynet = require "skynet"
require "skynet.manager"

local last_hour	= -1
local log_path  = skynet.getenv("logpath") -- 日志文件路径
local log_file  = nil -- 当前日志文件对象
local log_group = skynet.getenv("loggroup") -- 日志文件组名
local is_daemon = skynet.getenv("daemon") ~= nil -- 是否以守护进程方式运行

-- 检查路径是否存在，如果不存在则创建
local function check_exists(path)
    if not os.rename(path, path) then
        os.execute("mkdir " .. path)
    end
end

-- 根据日期生成日志文件路径
local function file_path(date)
    return string.format("%s%s_%04d-%02d-%02d-%02d.log", log_path, log_group, 
        date.year, date.month, date.day, date.hour)
end

-- 打开日志文件
local function open_file(date)
    check_exists(log_path)

    if log_file then
        log_file:close()
        log_file = nil
    end

    local f, e = io.open(file_path(date), "a")
    if not f then
        print("logger error:", tostring(e))
        return
    end

    log_file = f
    last_hour = date.hour
end

-- 格式化时间字符串
local function log_time(date)
    return string.format("%02d:%02d:%02d.%02d", date.hour, date.min, date.sec, 
        math.floor(skynet.time()*100%100))
end

local CMD = {}

-- 日志记录函数
function CMD.logging(source, type, str)
    local date = os.date("*t")
    str = string.format("[:%08x][%s][%s]%s", source, type, log_time(date), str)
    
    if not log_file or date.hour ~= last_hour then
        open_file(date)
    end

    log_file:write(str .. '\n')
    log_file:flush()
    
    if not is_daemon then
        print(str)
    end
end

-- 注册文本协议，用于接收日志消息
skynet.register_protocol {
    name = "text",
    id = skynet.PTYPE_TEXT,
    unpack = skynet.tostring,
    dispatch = function(_, source, msg)
        CMD.logging(source, "DEBUG", msg)
    end
}

-- 注册系统协议，用于接收重新打开日志文件的信号
skynet.register_protocol {
    name = "SYSTEM",
    id = skynet.PTYPE_SYSTEM,
    unpack = function(...) return ... end,
    dispatch = function(_, source)
        -- reopen signal
        print("SIGHUP")
        CMD.logging(source, "FATAL", "SIGHUP")
    end
}

-- 启动函数
skynet.start(function()
    skynet.register(".logger")
    skynet.error("Logger start !!!");
    
    skynet.dispatch("lua", function(_, source, cmd, ...)
        local f = assert(CMD[cmd], cmd .. " not found")
        f(source, ...)
    end)
end)