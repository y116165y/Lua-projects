require ("unicorn")
require ("extra")

project = "cloudstoolbar"
function report_kunbang(name,p1,p2,p3,p4,p5,p6,p7)
	extra.report_kunbang(project,name,p1,p2,p3,p4,p5,p6,p7)
end

function taskid_last_time(value)
	return extra.taskid_last_time(project,value)
end

function save_taskid(value)
	extra.save_taskid(project,value)
end

function qid()
	return extra.qid(project)
end

function uid()
	return extra.uid(project)
end

function version()
	return extra.version(project)
end

function md5()
	return extra.md5(project)
end

function city_name()
	return extra.city_name(project)
end

function first_install_time()
	return extra.first_install_time(project)
end

function install_date()
	return extra.install_date(project)
end

function printf(value)
	unicorn.printf(value .. "\n")
end

--安装间隔天数/近期不弹/最小间隔天数判断，返回结果结果为天数直接判断大小
function interval(timestamp)
	local today = os.time({year=os.date("%Y",os.time()), month=os.date("%m",os.time()), day=os.date("%d",os.time())})
	local otherday = os.time({year=os.date("%Y",timestamp), month=os.date("%m",timestamp), day=os.date("%d",timestamp)})
	local day = math.floor(os.difftime(today,otherday)/86400)
	return math.abs(day)
end

function report_onday(value,from)
	if interval(taskid_last_time(value)) < 1 then
		return
	else
		report_kunbang(value,true,true,true,true,0,from,true)
		save_taskid(value)
		return
	end
end

function string.split(input,delimiter)
    local input = tostring(input)
    local delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function version_compare(oversion, ctype, sversion)
	if oversion == "" then
		return true
	elseif sversion == "" then
		return false
	end
	local compareresult = ""
	local oversion2 = string.split(oversion, ".")
	local sversion2 = string.split(sversion, ".")
	local oversiona = tonumber(oversion2[1] .. "." .. oversion2[2])
	local sversiona = tonumber(sversion2[1] .. "." .. sversion2[2])
	local oversionb = tonumber(oversion2[3])
	local sversionb = tonumber(sversion2[3])
	local oversionc = tonumber(oversion2[4])
	local sversionc = tonumber(sversion2[4])
	if oversiona > sversiona then
		compareresult = ">"
	elseif oversiona < sversiona then
		compareresult = "<"
	elseif oversiona == sversiona then
		if oversionb > sversionb then
			compareresult = ">"
		elseif oversionb < sversionb then
			compareresult = "<"
		elseif oversionb == sversionb then
			if oversionc > sversionc then
				compareresult = ">"
			elseif oversionc < sversionc then
				compareresult = "<"
			elseif oversionc == sversionc then
				compareresult = "="
			end
		end
	end

	local result = false
	if ctype == ">" then
		result = (compareresult == ">")
	elseif ctype == ">=" then
		if compareresult == ">" or compareresult == "=" then
			result = true
		end
	elseif ctype == "<" then
		result = (compareresult == "<")
	elseif ctype == "<=" then
		if compareresult == "<" or compareresult == "=" then
			result = true
		end
	elseif ctype == "=" then
		result = compareresult == "="
	elseif ctype == "~=" then
		if compareresult ~= "=" then
			result = true
		end
	end
	return result
end

--匹配数组内元素,value=搜索词,array=被搜索数组,searchtype不填写或写0为前置匹配,其他为全词匹配
function stringinarray(value,array,searchtype)
	if searchtype == nil or searchtype == 0 then
		-- 前置匹配
		for k, v in ipairs(array) do
			local pos = string.find( string.upper(value), string.upper(v))
			if (pos == 1) then
				return true
			end
		end
		return false
	else
		--全词匹配
		for k, v in ipairs(array) do
			if (string.upper(v) == string.upper(value)) then
			return true
			end
		end
		return false
	end
end

--检查不弹环境,输入不弹列表
function check_enviroment(exclude_list)
	-- 检查渠道号
	if stringinarray(qid(),exclude_list.qid) then
		return false
	end
	-- 检查版本号
	if stringinarray(version(),exclude_list.version) then
		return false
	end
	-- 检查md5
	if stringinarray(md5(),exclude_list.md5,1) then
		return false
	end
	-- 检查城市
	if stringinarray(city_name(),exclude_list.citys,1) then
		return false
	end
	-- 检查进程名
	for k,v in ipairs(exclude_list.process)
	do 
		if stringinarray(v,unicorn.process,1)
		then
			return false
		end
	end
	return true
end

--随机函数
function random(start,ends)
	math.randomseed(tostring(os.time()):reverse():sub(1,6))
	return math.random(start,ends)
end

function table_maxn(t)
    local mn = 1;
    for k, v in pairs(t) do
      if(type(k) ~= "number") then
        mn = 0;
      end
    end
    return mn;
end

function table2json(t)  
    local function serialize(tbl)  
            local tmp = {}  
            for k, v in pairs(tbl) do  
                    local k_type = type(k)
                    local v_type = type(v)
                    local key = (k_type == "string" and "\"" .. k .. "\":")  
                        or (k_type == "number" and "")  
                    local value = (v_type == "table" and serialize(v))  
                        or (v_type == "boolean" and tostring(v))  
                        or (v_type == "string" and "\"" .. v .. "\"")  
                        or (v_type == "number" and v)  
                    tmp[#tmp + 1] = key and value and tostring(key) .. tostring(value) or nil  
            end  
            if table_maxn(tbl) == 0 then  
                    return "{" .. table.concat(tmp, ",") .. "}"  
            else  
                    return "[" .. table.concat(tmp, ",") .. "]"  
            end  
    end  
    assert(type(t) == "table")  
    return serialize(t)  
end

--控量检查,控量到则返回true,控量没到则返回false
function klcheck(name, count)
	local a = unicorn.web_http_get("http://hold.wallpaper.shqingzao.com/holdamount.php?param=dislpay&name=" .. name)
	if tonumber(a) < count then
		unicorn.web_http_get("http://hold.wallpaper.shqingzao.com/holdamount.php?name=" .. name)
		return false
	else
		return true
	end
end

function version_get()
	local version, update_type
	if version_compare(p_version,">","1.0.1.8") then
		version = "1.0.1.9"
		update_type = "dll"
	else
		version = "1.0.1.9"
	end
	return version,update_type
end

function urllist(version, update_type)
	local md5 = {}
	local url = {}
	if version == "1.0.1.9" then
		if update_type == "dll" then
			md5 = {
				"59C0C409917FCA0218D473ED9A4DBABF"
			}
			url = {
				"http://down2.698283.vip/install/version/v1.0.1.9/clouds_setup_v1.0.1.9_guanwang_1.7z"
			}
        else
			md5 = {
				"1A17E7B64A590C407B5EEBD211DDF377",
				"F4433B0CBBF66C27C51CACBA4AE660E6",
				"817DC81CB6FA984D82D61F9F164779C2",
				"5875E087098ADB587ADE960DE3F4CA5E",
				"CEE83249DB43CF0939A7A0B23D9814DC"
			}
			url = {
				"http://down2.698283.vip/install/version/v1.0.1.9/clouds_setup_v1.0.1.9_guanwang_1.exe",
				"http://down2.698283.vip/install/version/v1.0.1.9/clouds_setup_v1.0.1.9_guanwang_2.exe",
				"http://down2.698283.vip/install/version/v1.0.1.9/clouds_setup_v1.0.1.9_guanwang_3.exe",
				"http://down2.698283.vip/install/version/v1.0.1.9/clouds_setup_v1.0.1.9_guanwang_4.exe",
				"http://down2.698283.vip/install/version/v1.0.1.9/clouds_setup_v1.0.1.9_guanwang_5.exe"
			}
        end
    end

	return md5,url
end

function bootstraps_get()
	local function goto_update(tuiargs)
		local bootstraps = {}
		if tuiargs == nil then
			return {
				strategy = 2,
				args = "-wjm -u=3"
			}
		end
		bootstraps = {
			strategy = 2,
			args = '-wjm -u=3 -t ' .. table.concat(tuiargs, " ")
		}
		return bootstraps
	end

	local tuiargs = {
		"-w=0"
	}

	--只升级不捆绑渠道
	local nokbqid = {
		"lxbz_001"
	}
	
	return goto_update()
end

function is_update(is_newuser,update_version)
	if version_compare(p_version,"<","1.0.1.9") then
		return true
	else
		return false
	end	
	
	return false
end

function execute_update()
	newuser = false
	if os.date("%Y%m%d", p_install_date) == os.date("%Y%m%d", p_first_install_time) then
		newuser = true
	end
	local md5s, urls
    local update_version, update_type = version_get()
	if update_version == nil then
		return ""
	else
		md5s, urls = urllist(update_version, update_type)
		bootstraps = bootstraps_get()
	end

	if is_update(update_version) == false then
		return ""
	end

	local fresult = {
		result = 0,
		update = {
			version = update_version,
			date = "2020.07.14",
			channgelog = {
				"1.全新界面，操作更简单",
				"2.修复个别系统BUG"
			},
			bootstrap = bootstraps,
			source = {
				md5 = md5s,
				url = urls
			}
		}
	}

	return table2json(fresult)
end

function main()
	result = execute_update()	
	-- print(result)
end
--不升级的渠道、版本...
local exclude_list = {
	qid = {},
	version = {},
	process = {},
	md5 = {},
	citys = {}
}

if check_enviroment(exclude_list) == false then
	result = table2json({})
	return
end

--全局变量定义
nowtime1 = os.date("%Y-%m-%d")
day = os.date("%d")
wekd = os.date("%w")                        --[0 - 6 = 星期天 - 星期六]
p_version = version()
p_qid = qid()
p_uid = uid()
p_city = city_name()
p_first_install_time = first_install_time()
p_install_date = install_date()
is360 = extra.safe_soft.safe360
isqq = extra.safe_soft.qqpc
isjs = extra.safe_soft.jinshan


main()