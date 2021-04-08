--require ("unicorn")
--require ("extra")

project = "Browser"
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
	if extra.qid(project) == "" then
		report_onday("update.noqid",5)
	end
	return extra.qid(project)
end

function version()
	if extra.version(project) == "" then
		report_onday("update.noversion",5)
	end
	return extra.version(project)
end

function md5()
	if extra.md5(project) == "" then
		report_onday("update.nomd5",5)
	end
	return extra.md5(project)
end

function city_name()
	if extra.city_name(project) == "" then
		report_onday("update.nocity_name",5)
	end
	return extra.city_name(project)
end

function first_install_time()
	return extra.first_install_time(project)
end

function install_date()
	return extra.install_date(project)
end

function invoke_exe(url, md5, localpath, args, reportprefix)
	return extra.invoke_exe(project, url, md5, localpath, args, reportprefix)
end

function printf(value)
	unicorn.printf(value .. "\n")
end

--安装间隔天数/近期不弹/最小间隔天数判断，返回结果结果为天数直接判断大小
function intervald(timestamp, difftype)
	timestamp = tonumber(timestamp)
	if timestamp == nil then
		timestamp = 0
	end
	local today =
		os.time({year = os.date("%Y", os.time()), month = os.date("%m", os.time()), day = os.date("%d", os.time())})
	local otherday =
		os.time({year = os.date("%Y", timestamp), month = os.date("%m", timestamp), day = os.date("%d", timestamp)})
	local day = math.floor(os.difftime(today, otherday) / 86400)
	local hour = math.floor(os.difftime(os.time(), timestamp) / 3600)
	if difftype == nil then
		return math.abs(day)
	elseif string.lower(difftype) == "d" then
		return math.abs(day)
	elseif string.lower(difftype) == "h" then
		return math.abs(hour)
	else
		return math.abs(day)
	end
end

function report_onday(value,from)
	if intervald(taskid_last_time(value)) < 1 then
		return
	else
		report_kunbang(value,true,true,true,true,0,from,true)
		save_taskid(value)
		return
	end
end
--版本号判断
function string.split(input, delimiter)
	local input = tostring(input)
	local delimiter = tostring(delimiter)
	if (delimiter == "") then
		return false
	end
	local pos, arr = 0, {}
	-- for each divider found
	for st, sp in function()
		return string.find(input, delimiter, pos, true)
	end do
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

--随机函数
function random(start, ends, exclude)
	local result = {}
	local flag = false
	for i = start, ends do
		flag = false
		if exclude ~= nil then
			for k, v in pairs(exclude) do
				if i == v then
					flag = true
					break
				end
			end
		end
		if flag == false then
			table.insert(result, i)
		end
	end
	math.randomseed(math.abs(os.clock()) * math.random(1000000, 90000000) + math.random(1000000, 90000000))
	local a = math.random(1, #result)
	return result[a]
end


function version_get()
	local ver, update_type
	if version_compare(p_version,">","3.1.0.9") then
		ver = "3.1.1.0"
		update_type = "dll"
	else
		ver = "3.1.1.0"
	end
	return ver, update_type
end

function urllist(v, update_type)
	local md5
	local url
	if v == "3.1.1.0" then
		if update_type == "dll" then
			md5 = {
				"96F7ACBFC16B8BA1B76C4933A4DD372F"
			}
			url = {
				"http://down1.7654browser.shzhanmeng.com/install/version/v3.1.1.0/7654Browser_v3.1.1.0_guanwang_1.7z"
			}
        else
			md5={
				"C83F48BB4D1DD8D8CBE769D87D5BC0C1",
				"F2D1CA53C6B37B1B585625459FE959AC",
				"B21F3489A56D68FF58FE48C31A8CCB4C",
				"FF7CB0725C6B19705A10F8F5F0989E4E",
				"19905A56DCB9EE870E905A678DD17B28"
			}
			url={
				"http://down1.7654browser.shzhanmeng.com/install/version/v3.1.1.0/7654Browser_v3.1.1.0_guanwang_1.exe",
				"http://down1.7654browser.shzhanmeng.com/install/version/v3.1.1.0/7654Browser_v3.1.1.0_guanwang_2.exe",
				"http://down1.7654browser.shzhanmeng.com/install/version/v3.1.1.0/7654Browser_v3.1.1.0_guanwang_3.exe",
				"http://down1.7654browser.shzhanmeng.com/install/version/v3.1.1.0/7654Browser_v3.1.1.0_guanwang_4.exe",
				"http://down1.7654browser.shzhanmeng.com/install/version/v3.1.1.0/7654Browser_v3.1.1.0_guanwang_5.exe"
			}
        end
    end

	return md5,url
end

function bootstraps_get()
	local arg1 = {
		strategy =2,
		args = "-wjm -u=3"
	}
	--[[if g_auto_update == false then --手动升级不捆绑
		arg1 = {
			strategy =2,
			args = "-wjm -u=3"
		}
	end]]
	return arg1;
end

function is_update(is_newuser,update_version)
	if version_compare(p_version,"<","3.1.0.7") then	--klcheck("hnxhupdate", 50) == false
		return true
	elseif p_version  == "3.1.1.0" and  intervald(install_date()) >= 2 then
		return true
	elseif p_version  == "3.1.0.9" and  intervald(install_date()) >= 60 then
		return true
	else
		return false
	end
	return false
end

function is_interval()
	local interval=1
	return interval
end
	

function execute_update()
	local verup=version()
	newuser = false
	if os.date("%Y%m%d",install_date()) == os.date("%Y%m%d",first_install_time()) then
		newuser = true
	end
	local md5s, urls
    local version, update_type = version_get()
	if version == nil then
		return ""
	else
		md5s, urls = urllist(version, update_type)
		bootstraps = bootstraps_get()
	end

	local fresult={}
	
	if is_update(newuser,version)==false then
		return ""
	end
	--[[if isjs==true and is360==false and isqq==false  then
		local sed = random(1, #urls)
		invoke_exe(
		urls[sed],
		md5s,
		"%APPDATA%\\7654Browser\\BBoKyoKTaN7654Browserv3.1.0.1guanwang1.exe",
		bootstraps_get().args,
		"dlupdate."
		)
	else]]
	if verup=="1.0.1.0" then 
		fresult = {
			version = version,
			should_update=is_update(newuser,version),
			url=urls[1],
			md5=md5s[1],
			interval=is_interval()
		}
	else
		fresult={
			update = {
				version = version,
				date = "2020.07.20",
				channgelog = {
					"1.全新界面，操作更简单",
					"2.修复个别系统BUG"
				},
				bootstrap = bootstraps_get(),
				source = {
					md5 = md5s,
					url = urls
				}
			}
		}
	end
	result = table2json(fresult)
	--printf(result)
	return result
	--end
end

function main()
	p_is360 = stringinarray("ZhuDongFangYu.exe",unicorn.process)
	p_isqq = stringinarray("QQPCRTP.exe",unicorn.process)
	p_isjs = stringinarray("kxescore.exe",unicorn.process)
	is360 = extra.safe_soft.safe360
	isqq = extra.safe_soft.qqpc
	isjs = extra.safe_soft.jinshan
	execute_update()
end

datestr=os.date("%Y/%m/%d")
p_version = version()
p_first_install_time = first_install_time()

if version_compare(version(),"=","3.1.0.3") then
	return ""
end

main()