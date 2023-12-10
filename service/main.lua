local skynet = require "skynet"
local log    = require "log"

skynet.start(function()
    log.info("main start !");
    -- TODO: Add your code here
    
    skynet.exit()
end)
