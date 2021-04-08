extra = {}

function extra.is_vip()
	return false;
end

extra.monitor_info = {}
extra.safe_soft = {safe360=false,
					qqpc=false,
					jinshan=false}
--
function extra.qid(project)
	return 'test_001';
end
--
function extra.uid(project)
	return '9D4038F1D9B5125C78A4950841C0887D';
end
--
function extra.md5(project)
	return 'AD1F1FE444CC22CEA769CCA510E9AA7F';
end
--
function extra.version(project)
	return '1.0.0.5';
end

function extra.uid(project)
	return 'AD1F1FW333CC22CAER32CCA510E9AA7F';
end

--[[
    如果注册表中 FirstInstallTime 值为空或者不存在，
    取 InstallDate, 时间格式为 timestamp
]]
--
function extra.first_install_time(project)
	return 1589953580;
end
--
function extra.install_date(string_project)
	return 1612677841;
end

--
function extra.enable_news(project)
	return true;
end
--
function extra.city_name(project)
	return "无锡";
end

-- 写入taskid
--
function extra.save_taskid(project,task_id)
	return 1531809540;
end


-- taskid上次运行时间
--
function extra.taskid_last_time(project,task_id)
    return 1535027946;
end


function extra.popup_checker(porject1,project,popwnd_type,gif_url,logo_name)
	if project == "xxbz"
	then
		return true;  -- true 代表弹
	end
	return false;
end

--('',1,1,1,1,0,4,1)
function extra.report_kunbang(porject1,name, zhanShi, gouXuan,xiaZai,anZhuang, pos, from, checkAnZhuang)

end

--('',1,1,1,1,0,3,1)
--
function extra.report_news_app(porject1,name)

end

-- 返回近期不弹出的设置时间
--根据项目匹配，可能返回空值
--
function extra.nopop_set_time(porject1,type)
	return 1531185770;
end

--[[
    args 形式为数组 
]]
function extra.invoke_exe(porject1,url, md5, name, args)
    return true
end


function extra.invoke_dll(porject1,url, md5, name, args)
    return true
end


return extra