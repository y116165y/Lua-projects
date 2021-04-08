require("unicorn")
require("extra")

project = "Browser"

--首次安装时间
function first_install_time()
  return extra.first_install_time(project)
end
--最近安装式
function install_date()
  return extra.install_date(project)
end


function reg_key_exist()
  return unicorn.reg_key_exist("HKCU", "Software\\7654Browser\\Update")
end
--判断是否升级
function isup()
  if os.date("%Y%m%d", install_date()) == os.date("%Y%m%d", first_install_time()) and reg_key_exist() == false then
    return false
  end
  return true
end

--获取渠道号
function qid()
  return extra.qid(project)
end

--获取版本号
function version()
  return extra.version(project)
end

--table转json
function table_maxn(t)
  local mn = 1
  for k, v in pairs(t) do
    if (type(k) ~= "number") then
      mn = 0
    end
  end
  return mn
end

function pairsByKeys(t)
  local a = {}
  for n in pairs(t) do
      a[#a + 1] = n
  end
  table.sort(a)
  local i = 0
  return function()
      i = i + 1
      return a[i], t[a[i]]
  end
end

function table2json(t)
  local function serialize(tbl)
    local tmp = {}
    for k, v in pairsByKeys(tbl) do
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

--字符串分割
function lua_string_split(str, split_char)
  local sub_str_tab = {};
  while (true) do
      local pos = string.find(str, split_char);
      if (not pos) then
          sub_str_tab[#sub_str_tab + 1] = str;
          break;
      end
      local sub_str = string.sub(str, 1, pos - 1);
      sub_str_tab[#sub_str_tab + 1] = sub_str;
      str = string.sub(str, pos + 1, #str);
  end

  return sub_str_tab;
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

--时间间隔
function intervald(timestamp, difftype)
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

-- 配置文件版本，更改配置时只要当前字符串和之前的不一致，就会更新,GUID
ver = "v134c"

function searchEngine()
  local se={}
  se["baidu.com"] = "tn=78040160_63_pg&ch=1"
  se["so.com"] = "src=lm&ls=sm2253809&lm_extend=ctype:31"
  se["sogou.com"] = "pid=sogou-site-b02d46e8a3d8d9fd"
  --上次lua修改默认搜索时间（秒string）
  --last_set_default_search_engine
  --当前搜索引擎（0/1/2 string）
  --default_search_engine
  --搜索引擎渠道号、是否修改默认搜索引擎、搜索引擎种类（0：百度，1：搜狗，2：360）
  local search={se,true,0}
  return search
end

--跳转链接
origin_url_host = {
  "hao.360.cn",
  "a.wnplayer.net",
  "nav.7654.com",
  "sanliu.naruto.red",
  "js.naruto.red",
  "qq.naruto.red",
  "cnzz.naruto.red",
  "xinban.naruto.red?chno=xb",
  "daohang.naruto.red?chno=zmtb",
  "taot.naruto.red?chno=taot",
  "daohang2.naruto.red?chno=noinside",
  "cnzz.naruto.red?chno=114"
}

--监控访问的url
redirect_url = {
  "https://nav.7654.com/",
  "http://nav.7654.com/",
  "https://nav.7654.com",
  "http://nav.7654.com",
  "http://hao.360.cn/?src=lm&ls=n2d4c32ca99",
  "https://hao.360.cn/?src=lm&ls=n2d4c32ca99",
  "http://browsertab.7654.com/001",
  "http://browsertab.7654.com/002",
  "http://browsertab.7654.com/003",
  "http://browsertab.7654.com/001?search_engine=baidu",
  "http://browsertab.7654.com/001?search_engine=sogou",
  "http://browsertab.7654.com/001?search_engine=360",
  "http://browsertab.7654.com/001?search_engine=google",
  "http://browsertab.7654.com/002?search_engine=baidu",
  "http://browsertab.7654.com/002?search_engine=sogou",
  "http://browsertab.7654.com/002?search_engine=360",
  "http://browsertab.7654.com/002?search_engine=google",
  "http://hao.7654.com/s.html?chno=sy_bgsc",
  "http://browsertab.7654.com/",
  "http://hao.7654.com/s.html?chno=sy_jiansunhao",
  "http://a.wnplayer.net?chno=kuaiya003",
  "http://hao.7654.com/s.html?chno=sy_bgsc",
  "http://a.wnplayer.net?chno=kuaiya003",
  "http://js.naruto.red?chno=jinshan",
  "http://qq.naruto.red?chno=qqhj",
  "http://sanliu.naruto.red?chno=360",
  "https://www.2345.com/?37698-0033",
  "https://www.2345.com/?37698-0039",
  "https://www.2345.com/?37698-0038",
  "https://www.2345.com/?37698-0037",
  "https://123.sogou.com/?211005",
  "http://www.114la.cn/qd1901.html",
  "https://hao.7654.com/?chno=zy_zmtb",
  "https://hao.7654.com/?chno=7654llq_03",
  "https://hao.7654.com/?chno=7654llq_04"
}
-- 书签栏配置,
-- no_exist_max_days:收藏夹不存在时隔多久添加回来
-- 禁止更改no_exit_date

function isbm()
  local delete_urls={
    "https://s.click.taobao.com/1f4bqtv",
    "https://s.click.taobao.com/H4A30sv",
    "https://s.click.taobao.com/mMDwVrv",
    "https://s.click.taobao.com/n5GZ1rv",
    "https://s.click.taobao.com/Cv70ruv",
    "https://s.click.taobao.com/RtCiXov",
    "https://s.click.taobao.com/mAVD9ov",
    "https://s.click.taobao.com/LKexdhv",
    "http://a.wnplayer.net?chno=baidu2",
    "https://www.baidu.com/?tn=88093251_42_hao_pg",
    "https://www.baidu.com/?tn=99493963_hao_pg",
    "https://s.click.taobao.com/nrmhazu",
    "https://s.click.taobao.com/Rqgxquv",
    "https://s.click.taobao.com/kI7zquv",
    "https://mos.m.taobao.com/union/jhsjx2020?pid=mm_32554190_988850239_109797100351",
    "https://s.click.taobao.com/057QHvu",
    "https://s.click.taobao.com/TRYnCvu"
  }
  local data1 = {
    {
      title="百度搜索",
      url="http://a.wnplayer.net?chno=baidu2",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/bd.ico"
    },
    {
      title="天猫",
      url="https://s.click.taobao.com/bqGWZ9w",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/tm.ico"
    },
    {
      title="淘宝",
      url="https://ai.taobao.com?pid=mm_111978447_41172862_175328754",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/tb.png"

    },
    {
      title="聚划算",
      url="https://s.click.taobao.com/ikEOmVw",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/jhs.ico"
    },
    {
      title="京东",
      url="http://a.wnplayer.net?chno=jd2",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/jd2.ico"
    },
    {
      title="头条新闻",
      url="http://mini.eastday.com/?qid=01679",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/tt.ico"
    }
  }
  local data2 = {
    {
      title="百度搜索",
      url="http://qw.naruto.red?chno=7654",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/bd.ico"
    },
    {
      title="天猫",
      url="https://s.click.taobao.com/tJZnCvu",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/tm.ico"
    },
    {
      title="淘宝",
      url="https://s.click.taobao.com/canWJuu",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/tb.png"

    },
    {
      title="京东",
      url="http://a.wnplayer.net?chno=jd2",
      icon="http://configuration.7654browser.shzhanmeng.com/url-config/img/jd2.ico"
    },
    {
      title="拼多多",
      url="https://c.duomai.com/track.php?site_id=243469&euid=llq01-pdd-1&t=https://youhui.pinduoduo.com",
      icon="http://down1.7654browser.shzhanmeng.com/url-config/img/pdd.png"
    },
    {
      title="唯品会",
      url="https://c.duomai.com/track.php?site_id=243469&euid=llq01-vip-1&t=http://www.vip.com/",
      icon="http://down1.7654browser.shzhanmeng.com/url-config/img/vph.png"
    },
    {
      title="头条新闻",
      url="http://news.hoteastday.com/?qid=7654re",
      icon="http://down1.7654browser.shzhanmeng.com/url-config/img/rtt.png"
    },
    {
      title="2345导航",
      url="http://lux.naruto.red?chno=lux",
      icon="http://down1.7654browser.shzhanmeng.com/url-config/img/2345dh.ico"
    }
  }
  local bookmark={"000039",0,0,true,delete_urls,data1}
  if version_compare(version(),">=","1.0.1.5")==true then
    bookmark[6]=data2
    return bookmark
  else
    return bookmark
  end
end





--配置主页
function iswash()
  --主页链接、主页更换间隔天数、是否修改主页、是否修改打开浏览器显示的页面、浏览器打开显示页面（6: 打开默认主页5: 打开新标签1: 从上次停下的地方继续4: 打开特定网页或一组网页）
  local homePage={"http://a.wnplayer.net?chno=qwllq",0,true,false,6}
  --是否替换本地数据、是否使用根据不同次数打开不同主页、主页链接、默认主页
  local homePageList={true,false,{"http://wzdh.naruto.red?chno=zmtb","http://lux.naruto.red?chno=lux"},0}
  
  if set_homepage_from_command_line == "1" then
    homePage[3] = false
    homePageList[2]=false
  end

  if version_compare(version(),">=","1.0.2.4") ==true then
    homePageList[2]=true
    if stringinarray(qid(),{"kz_","xiaohei_"},0) == true then
      homePageList[3][1]="http://a.wnplayer.net?chno=qwllq"
    end
  end

  --[[if version_compare(version(),">=","1.0.1.8") == true and stringinarray(qid(),{"kz_"},0) == true then
    homePage[1]="sona.naruto.red?chno=7654"
    homePageList[2]=false
  end]]

  --[[if browser_startup_type~="" and lua_string_split~="" and replace_startup_type_time~="" then
    if browser_startup_type=="3" and stringinarray("www.baidu.com", lua_string_split(specified_url_list," "), 1)==true then
      homePage[4]=true
      homePage[5]=6
    end
  end]]
  return homePage,homePageList
end



--判断是否使用风铃标签页
function fl(url)
  local flurl="chrome://newtab"
  if version_compare(version(),">=","1.0.1.7")==true and version_compare(version(),"<","1.0.2.3") then
    if fengling_is_installed == "true" and fengling_is_enabled == "true" then 
      return flurl
    else
      return url
    end
  else
    return url
  end
end

--用户主动打开浏览器的拉起页
function user_startup_page(arg)
  local user_startup_page = {"http://browsertab.7654.com/001",true}
  if arg == 1 then
    user_startup_page[1]=fl(user_startup_page[1])
    return user_startup_page
  end
  return user_startup_page
end
               

-- 被动拉起页配置
function start_page(arg)
  local start_page = {"https://s.click.taobao.com/FuDuRuv",0,true}
  if arg == 1 then
    start_page[1]=fl(start_page[1])
    return start_page
  end
  if os.time() >= os.time({day=13, month=12, year=2019, hour=0, minute=0, second=0}) then
    start_page[1]="http://browsertab.7654.com/003"
  end
  return start_page
end

--主动打开标签页
function newtab_page(arg)
  local newtab_page={"http://browsertab.7654.com/001",true}
  if arg == 1 then
    newtab_page[1]=fl(newtab_page[1])
    return newtab_page
  end
  return newtab_page
end




--将链接写入ruhl
function readRuhl()
  local ruhl = {}
  local whitel ={}
  --配置白名单
  whitel["www.baidu.com"]={
    {
      tn="78040160_63_pg",
      ch="1"
    }
  }
  --配置洗渠道的url
  local url={
        {
          domain="www.baidu.com",
          key= {"tn","ch"},
          value= {"78040160_63_pg","1"}
        }
        --[[{
          domain="www.sogou.com",
          key= {"pid"},
          value= {"sogou-site-b02d46e8a3d8d9fd"}
        },
        {
          domain="hao.360.cn",
          key= {"src","ls"},
          value= {"lm","n2d4c32ca99"}
        },
        {
          domain="www.jd.com",
          key= {"cu","utm_source","utm_medium","utm_campaign","utm_term"},
          value= {"true","c.duomai.com","tuiguang","t_16282_46652796","2abb203c5a0247238a9ff4e52e071dd8"}
        },
        {
          domain="ai.taobao.com",
          key= {"pid"},
          value= {"mm_111978447_41172862_175328754"}
        },
        {
          domain="www.hao123.com",
          key= {"tn"},
          value= {"96862230_hao_pg"}
        }]]
      }
    for i,v in ipairs(url) do
        local d=v.domain
        local k=v.key
        local v=v.value
        ruhl[d]={
            key=k,
            value=v
        }
    end
    return ruhl,whitel
end
--判断是否劫持
function ishijacked()
  local should_replace_url=true
  return should_replace_url
end



--左侧任务栏配置
function isLeftBar()
  local left_bar={
          should_replace= true,
          data= {
            {
              name="收藏夹",
              tooltip="快速打开收藏夹",
              type=1,
              exe_name="",
              url="chrome://bookmarks/",
              normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/qzone_normal.png",
              hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/qzone_hover.png",
              pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/qzone_press.png",
              normal_image_name="qzone_normal.png",
              hovered_image_name="qzone_hover.png",
              pressed_image_name="qzone_press.png"
            },
          {
            name="历史记录",
            tooltip="快速打开历史记录",
            type=1,
            exe_name="",
            url="chrome://history/",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/history_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/history_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/history_press.png",
            normal_image_name="history_normal.png",
            hovered_image_name="history_hover.png",
            pressed_image_name="history_press.png"
          },
          {
            name="微信",
            tooltip="快速打开微信",
            type=1,
            exe_name="",
            url="https://wx.qq.com/",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/weixin_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/weixin_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/weixin_press.png",
            normal_image_name="weixin_normal.png",
            hovered_image_name="weixin_hover.png",
            pressed_image_name="weixin_press.png"
          },
          {
            name="百度搜索",
            tooltip="快速打开百度搜索",
            type=1,
            exe_name="",
            url="https://www.baidu.com/?tn=78040160_63_pg&ch=1",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/search_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/search_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/search_press.png",
            normal_image_name="search_normal.png",
            hovered_image_name="search_hover.png",
            pressed_image_name="search_press.png"
          },
          {
            name="热头条",
            tooltip="快速打开热头条",
            type=1,
            exe_name="",
            url="http://news.hoteastday.com/?qid=7654re",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/news_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/news_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/news_press.png",
            normal_image_name="news_normal.png",
            hovered_image_name="news_hover.png",
            pressed_image_name="news_press.png"
          },
          {
            name="爱淘宝",
            tooltip="快捷访问爱淘宝",
            type=1,
            exe_name="",
            url="https://s.click.taobao.com/tJZnCvu",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/shop_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/shop_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/shop_press.png",
            normal_image_name="shop_normal.png",
            hovered_image_name="shop_hover.png",
            pressed_image_name="shop_press.png"
          },
          {
            name="聚划算",
            tooltip="快捷访问聚划算",
            type=1,
            exe_name="",
            url="https://s.click.taobao.com/tJZnCvu",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/shop1_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/shop1_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/shop1_press.png",
            normal_image_name="shop1_normal.png",
            hovered_image_name="shop1_hover.png",
            pressed_image_name="shop1_press.png"
          },
          {
            name="头条视频",
            tooltip="快速打开头条视频",
            type=1,
            exe_name="",
            url="http://video.eastday.com/?qid=01675",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/video_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/video_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/video_press.png",
            normal_image_name="video_normal.png",
            hovered_image_name="video_hover.png",
            pressed_image_name="video_press.png"
          },
          --[[{
            name="记事本",
            tooltip="快速打开记事本",
            type=0,
            exe_name="notepad.exe",
            url="",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/notepad_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/notepad_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/notepad_press.png",
            normal_image_name="notepad_normal.png",
            hovered_image_name="notepad_hover.png",
            pressed_image_name="notepad_press.png"
          },]]
          {
            name="计算器",
            tooltip="快速打开计算器",
            type=0,
            exe_name="calc.exe",
            url="",
            normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/cal_normal.png",
            hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/cal_hover.png",
            pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/cal_press.png",
            normal_image_name="cal_normal.png",
            hovered_image_name="cal_hover.png",
            pressed_image_name="cal_press.png"
          }
        }
      }
    


    if version_compare(version(),">=","1.0.1.6") then
      local rzx={
        name="热资讯",
        tooltip="快速打开热资讯",
        type=2,
        exe_name="",
        url="",
        normal_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/news1_normal.png",
        hovered_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/news1_hover.png",
        pressed_image_url="http://configuration.7654browser.shzhanmeng.com/url-config/img/leftimgs/news1_press.png",
        normal_image_name="news1_normal.png",
        hovered_image_name="news1_hover.png",
        pressed_image_name="news1_press.png"
      }
      table.insert( left_bar.data, 3, rzx )
    end
    if version_compare(version(),">=","3.1.0.5") then
      local gamebox={
        name="7654互娱",
        tooltip="快速打开7654互娱",
        type=1,
        exe_name="",
        url="http://game.shzhanmeng.com/?source=7654",
        normal_image_url="http://down1.7654browser.shzhanmeng.com/url-config/img/leftimgs/gamebox_normal.png",
        hovered_image_url="http://down1.7654browser.shzhanmeng.com/url-config/img/leftimgs/gamebox_hover.png",
        pressed_image_url="http://down1.7654browser.shzhanmeng.com/url-config/img/leftimgs/gamebox_press.png",
        normal_image_name="gamebox_normal.png",
        hovered_image_name="gamebox_hover.png",
        pressed_image_name="gamebox_press.png"
      }
      table.insert( left_bar.data, 10, gamebox )
    end
    return left_bar
end

--关键词跳转
function omnibox()
  local omnibox={false,"http://down1.7654browser.shzhanmeng.com/search/A3.dat"}
  return omnibox
end


function main()
  local url_list,white_list = readRuhl()
  local hp,hplist=iswash()
  local bookmarks=isbm()
  local hijacked=ishijacked()
  local leftbar=isLeftBar()
  local tsqid1={"syry_"}
  local tsqid2={"guanwang_1","gw_001"}
  local tsqid4={"ccbb_001"}

  if stringinarray(qid(),tsqid1,0)==true then
    if intervald(first_install_time())<=1 then
      hp[1]="yiyi.naruto.red?chno=swry1"
    else
      hp[1]="jayce.naruto.red?chno=7654"
    end
    hplist[2]=false
    bookmarks[6]={}
  elseif stringinarray(qid(),tsqid2,1)==true then
    hijacked=false
  elseif stringinarray(qid(),tsqid4,1)==true then
    bookmarks[6]={}
  end

  union = {
    version = ver,
    home_page = {
      url=hp[1],
      no_exist_max_days=hp[2],
      should_replace=hp[3],
      should_change_startup_type=hp[4],
      startup_type=hp[5]
    },
    start_page = {
      url = start_page()[1],
      no_exist_max_days = start_page()[2],
      should_replace = start_page()[3]
    },
    bookmark = {
      replace_version=bookmarks[1],
      no_exist_max_days=bookmarks[2],
      no_exist_date=bookmarks[3],
      should_delete=bookmarks[4],
      delete_urls=bookmarks[5],
      data=bookmarks[6]
    },
    searchs_channels = searchEngine()[1],
    default_search_engine={
      should_replace=searchEngine()[2],
      search_engine=searchEngine()[3]
    },
    user_startup_page ={
      url = user_startup_page()[1],
      should_replace = user_startup_page()[2]
      },
    urls = {
      origin_url_host = origin_url_host,
      redirect_url = redirect_url
    },
    should_replace_url=hijacked,
    replace_url_host_list = {
      should_replace_url=hijacked,
      url_list=url_list,
      white_list=white_list
    },
    newtab_page={
      url=newtab_page()[1],
      should_replace=newtab_page()[2]
    },
    omnibox={
      should_redirect=omnibox()[1],
      url=omnibox()[2]
    },
    left_bar=leftbar,
    homepage_list={
      should_replace=hplist[1],
      should_use=hplist[2],
      data=hplist[3],
      default=hplist[4]
    }
  }
  result = table2json(union)
  print(result)
end


main()
