unicorn = {}
--
unicorn.process = {
    --'ZhuDongFangYu.exe',
    --'QQPCRTP.exe',
    --'kxescore.exe'
}

--读取时间戳
function unicorn.read_timestamp(rootkey,subkey,name)
    return 0;
end
--写时间戳
function unicorn.write_timestamp(rootkey,subkey,name,timestamp)
    return;
end
--判断文件是否存在，CSIDL路径，桌面为0
function unicorn.file_exists(CSIDL,filename)
    return;
end


unicorn.system_info= {}
unicorn.system_info.v1 = '5'
unicorn.system_info.v2 = '3'
unicorn.system_info.v3 = '17134'
unicorn.system_info.v4 = '1'
unicorn.system_info.is64bit = 'true'


--[[
    开机截至到现在的秒数
]]
--
unicorn.boot_time = 1800001;

--[[
    判断当前桌面是否为全屏
]]
function unicorn.full_screen()
    return false
end

--注册表项是否存在
--
function unicorn.reg_key_exist(rootkey,subkey)
    return false;
end
--
function unicorn.reg_read_string(rootkey,subkey,name)
    return "11.228.17134.0";
end
--
function unicorn.reg_write_string(rootkey,subkey,name,value)

end
--
function unicorn.reg_read_dword(rootkey,subkey,name)
    return 123456;
end
--
function unicorn.reg_write_dword(rootkey,subkey,name,value)

end
--
function unicorn.printf(value)
    return print(value);
end

function unicorn.web_http_get(url)
    return "50";
end


return unicorn




