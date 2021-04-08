
require ('unicorn')
require ('extra')


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

function execute_kztui()
	local weather = 0
	local calendar = 0
	local auto_paper = 0

	--调整单个配置项
	if isjs == true then
		weather = 1
	end

	if stringinarray(p_qid,{"hlq_","bz_","ss_","hui_","guanwang_"}) and interval(p_first_install_time) < 2 then
		weather = 1
		calendar = 1
		auto_paper = 1
	end

	local install = {
		enable_weather = weather,
		enable_calendar = calendar,
		enable_auto_paper = auto_paper
	};

	--其他环境
	--report("def.def_kztui",4)
	return table2json(install);
end


function main()
	result = execute_kztui()
	--print(result)
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
is360 = extra.safe_soft.safe360
isqq = extra.safe_soft.qqpc
isjs = extra.safe_soft.jinshan

main()

