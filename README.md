# Lua-projects
基于Lua代码实现PC端应用程序进行弹窗、升级、捆绑脚本

"更新tips tnews"接入策略管理后台
项目问题记录
开发需留意问题
弹窗后弹窗壳子不退出：如果是采用即时上报的项目,检查是不是手动FreeLibrary了壳子Dll,壳子Dll里面加载了UpdateChecker库有一个全局变量析构时在等待上报线程退出,手动释放会导致在FreeLibrary处卡住
测试需留意问题
1：使用时需保证函数参数类型正确、参数个数正确、返回值类型正确
2：使用test_script.exe工具验证脚本是否存在错误

接口变量：
使用方法：extra.variable

safe_soft{} （这是一个结构体）
.safe360 是否360环境(bool)
.qqpc 是否Q管环境(bool)
.jinshan 是否金山环境(bool)
.hips 是否火绒环境(bool)
.safe2345 是否2345管家环境(bool)
.risk 是否风险环境(bool)
monitor_num 显示器个数(int)
monitor_info[] 显示器信息（这是一个数组，第一个为主显示器）
.hsize 宽度（毫米）
.vsize 高度（毫米）
.width 物理分辨率宽（像素）
.height 物理分辨率高（像素）
.logical_pixel_width 逻辑分辨率宽（像素）
.logical_pixel_height 逻辑分辨率高（像素）
.inches 英寸
.hardwareid 监视器硬件ID
接口函数：
使用方法：extra.function(...)

bool wlan_connected(table wlan_ssids)
功能：是否连接了指定的wifi(支持通配符) 参数：wlan_ssids为wifi的ssid表 返回值：成功返回true、失败返回false

int64 reg_read_int(string root_key,string key,string name)
功能：获取注册表int值
参数：name为需要读取的名称、其它参照reg_key_exist
返回值：成功返回值、失败返回0

bool reg_write_int(string root_key,string key,string name,int64 value)
功能：写入注册表int值
参数：value为需要写入的值、其它参照reg_read_int
返回值：成功返回true、失败返回false

string reg_read_binary(string root_key,string key,string name)
功能：获取注册表binary值
参数：name为需要读取的名称、其它参照reg_key_exist
返回值：存在返回内容、不存在返回空字符串

bool reg_write_binary(string root_key,string key,string name,string value)
功能：写入注册表binary值
参数：value为需要写入的值、其它参照reg_read_int
返回值：成功返回true、失败返回false

bool is_admin()
功能：判断当前是否有管理员权限
参数：无
返回值：具有管理权限返回true、否则返回false

string md5(string project)
功能：获取软件安装包md5
参数：project为项目名
返回值：成功返回md5、失败返回空字符串

string qid(string project)
功能：获取软件渠道号
参数：project为项目名
返回值：成功返回渠道号、失败返回空字符串

string version(string project)
功能：获取软件版本号
参数：project为项目名
返回值：成功返回版本号、失败返回空字符串

string uid(string project)
功能：获取电脑uid
参数：project为项目名
返回值：成功返回uid、失败返回空字符串

string gid()
功能：获取电脑gid
参数：无
返回值：成功返回gid、失败返回空字符串

DWORD first_install_time(string project)
功能：获取软件首次安装时间
参数：project为项目名
返回值：成功返回首次安装时间、失败返回0

DWORD install_date(string project)
功能：获取软件更新时间
参数：project为项目名
返回值：成功返回更新时间、失败返回0

bool enable_news(string project)
功能：是否启用新闻功能
参数：project为项目名
返回值：启用返回true、未启用返回false

string city_name(string project)
功能：获取城市名
参数：project为项目名
返回值：成功返回城市名、失败返回空字符串

bool popup_checker(string project,string check_project,string popwnd_type,string gif_url,string logo_name)
功能：指定软件的指定弹窗是否弹出
参数：project为项目名
check_project为被检测的项目名
popwnd_type为被检测的弹窗名
gif_url配置文件下载地址（..../uc.gif）
logo_name注册表存储名称、位置为被检测软件注册表的
UpdateChecker下
返回值：弹出返回true、不弹返回false

void report_kunbang(std::string project, std::string name,bool zhanShi,bool gouXuan,bool xiaZai,bool anZhuang,int pos, int from,bool checkAnZhuang)
功能：获取城市名
参数：project为项目名
from为捆绑来源、from:安装(0) 更新(1) 2(卸载) 3(tips) 4()
返回值：无

void report_news_app(string project,string name)
功能：新闻点击上报
参数：project为项目名
name为需要上报的字段
返回值：无

void save_taskid(string project,string taskid)
功能：写入taskid
参数：project为项目名
taskid为配置的标志
返回值：无

DWORD nopop_set_time(string project,string type)
功能：近期不弹设置时间
参数：project为项目名
type为弹窗类型(miniews、minigw、tips2、tpop3、tpop4)
返回值：成功返回设置时间、失败返回0

bool is_vip(string project,int valid_hour)
功能：是否是VIP
参数：project为项目名
valid_hour为从web校验VIP状态的周期（小时）
返回值：是VIP返回true、不是VIP返回false

bool invoke_exe(string project,string url,table md5,string path,string args,string report_fix)
功能：下载并执行exe
参数：project为项目名
url为下载地址
md5为该批文件所有的md5值
path为保存路径
args为执行的参数
report_fix为上报前缀
返回值：成功返回true、失败返回false

bool invoke_exe_sct(string project,string url,table md5,string path,string args,string report_fix)
功能：下载并执行exe（sct执行）
参数：project为项目名
url为下载地址
md5为该批文件所有的md5值
path为保存路径
args为执行的参数
report_fix为上报前缀
返回值：成功返回true、失败返回false

bool invoke_exe2(string project,string url,table md5,string path,string args,string report_fix)
功能：下载并执行exe（先发生消息、失败后自己执行）
参数：project为项目名
url为下载地址
md5为该批文件所有的md5值
path为保存路径
args为执行的参数
report_fix为上报前缀
返回值：成功返回true、失败返回false

bool invoke_dll(string project,string url,table md5,string entry,string args)
功能：下载并执行dll（直接加载调起）
参数：project为项目名
url为下载地址
md5为该批文件所有的md5值
entry为dll入口只限：int(const void*)
args为执行的参数
返回值：成功返回true、失败返回false

bool invoke_dll2(string project,string url,table md5,string path,string entry,string args)
功能：下载并执行dll（通过调起子进程加载执行dll）
参数：project为项目名
url为下载地址
md5为该批文件所有的md5值
path为保存路径
entry为dll入口只限：int(const void*)
args为执行的参数
返回值：成功返回true、失败返回false

string encrypte(string content,string rc4_key)
功能：字符串加密（rc4-base64）
参数：content为需要加密的字符串
rc4_key为rc4密钥，为空则默认为内容长度
返回值：加密后的字符串

string decrypte(string content,string rc4_key)
功能：字符串解密（base64-rc4）
参数：content为需要加密的字符串
rc4_key为rc4密钥，为空则默认为内容长度
返回值：解密后的字符串

string rc4_encrypt(string content,string rc4_key)
功能：字符串加密（rc4）
参数：content为需要加密的字符串
rc4_key为rc4密钥，为空则默认为内容长度
返回值：加密后的字符串

string rc4_decrypt(string content,string rc4_key)
功能：字符串解密（rc4）
参数：content为需要加密的字符串
rc4_key为rc4密钥，为空则默认为内容长度
返回值：解密后的字符串

string base64_encode(string content)
功能：base64编码
参数：content为需要编码的字符串
返回值：加密后的字符串

string base64_decode(string content)
功能：base64解码
参数：content为需要解码的字符串
返回值：解密后的字符串

table reg_key_list(string root_key,string key)
功能：遍历注册表项
参数：root_key为根路径、只限于"HKCU"、"HKLK"
key为子路径
注意："HKCU"对应"HKEY_CURRENT_USER"
"HKLK"对应"HKEY_LOCAL_MACHINE"
返回值：子项列表

bool bundled_soft(string project,string switchConfig,string kbConfig)
功能：遍历注册表项
参数：project为项目名
switchConfig为开关配置
kbConfig为捆绑信息配置
返回值：捆绑结果

bool invoke_exe_inject(string project,string url,table md5,string path,string gif_url,string gif_md5,string gif_name,string args,string report_fix)
功能：下载exe并注入dll执行
参数：project为项目名
url为下载地址
md5为该批文件所有的md5值
path为保存路径
gif_url为gif下载地址
gif_md5为gif的md5值
gif_name为注册表存储名字
args为执行的参数
report_fix为上报前缀
返回值：成功返回true、失败返回false

bool invoke_exe_inject2(string project,string url,table md5,string path,string gif_url,string gif_md5,string gif_name,string args,string report_fix)
功能：下载exe并注入dll执行
参数：project为项目名
url为下载地址
md5为该批文件所有的md5值
path为保存路径
gif_url为gif下载地址
gif_md5为gif的md5值
gif_name为注册表存储名字
args为执行的参数
report_fix为上报前缀
区别：相对invoke_exe_inject底层实现不同、运行参数不对外显示(适合调用系统进程弹窗)
返回值：成功返回true、失败返回false

bool event_exist(string event_name)
功能：判断事件是否已经存在
参数：event_name为事件名
返回值：是否已存在

bool mutex_exist(string mutex_name)
功能：判断互斥是否已经存在
参数：mutex_name为互斥名
返回值：是否已存在

void delete_report(string project,table vcReport)
功能：删除上报日志
参数：project为项目名
vcReports为需要删除的字段名（table）

void fix_soft(table files_no_exists_anyone,table files_no_exists_all,table files_exists_anyone,table files_exists_all,url, md5, save_path, args)
功能：修复软件
参数：files_no_exists_anyone为不存在任意一个文件
files_no_exists_all为不存在所有文件
files_exists_anyone为存在任意一个文件
files_exists_all为存在所有文件
url为安装包下载链接
md5为安装包md5
save_path为安装保存路径
args为安装包运行参数

string file_md5(string file_path)
功能：获取文件md5
参数：file_path为文件路径
返回值：成功返回文件md5,失败返回空字符串

bool download_file(string url,string save_path,string md5)
功能：下载文件到指定路径
参数：url为下载地址
save_path为保存路径
md5为文件md5
返回值：成功返回true,失败返回false

bool download_file_to_reg(string url,string md5,string root_key,string key,string name) 功能：下载文件到指定注册表
参数：url为下载地址
md5为文件md5值
root_key为注册表根路径
key为注册表子路径 name为存储键名 返回值：成功返回true,失败返回false

bool unzip_7z(string src_path,string des_path)
功能：解压7z到指定路径
参数：src_path为需要解决的文件路径
des_path为解压保存的目标路径
返回值：成功返回true，失败返回false

bool file_exists(string file_path)
功能：判断文件是否存在
参数：file_path为文件路径，支持环境变量（软件安装路径
环境变量为：%install_path%） 如："%appdata%\test.exe"
返回值：存在返回true,不存在返回false

bool window_exists(string window_class,string window_title)
功能：判断窗口是否存在
参数：window_class为窗口类名(不需要时传空字符串)
window_title为窗口标题(不需要时传空字符串)
返回值：存在返回true,不存在返回false

bool create_process(string path,string commond,bool show)
功能：执行exe
参数：path为文件路径
commond为命令行
show为是否需要显示界面(一般false)
返回值：是否执行成功

bool create_process_bypassuac(string path,string commond,bool show) 功能：绕过uac执行exe
参数：path为文件路径
commond为命令行
show为是否需要显示界面(一般false)
返回值：0代表失败、1代表uac执行、2代表正常执行

string company_name(string project,table<map<string,string>>& company_name_table,DWORD dwFirstInstallTime)
功能：获取所在公司名
参数：project为项目名
dwFirstInstallTime为首次安装时间
company_name_table为公司域名表(company="xx.com")
返回值：公司类型(可能用多个,','号分隔)
备注：company_name_table中company：
前可加'_'以满足一些需要、如数字开头无法命名时 后可加'_xx'以满足一些需要、如多次配置同一个公司名时

string company_user(table<map<string,string>>& company_user_table DWORD dwFirstInstallTime)
功能：获取用户属于那个公司的用户
参数：dwFirstInstallTime为首次安装时间
company_user_table为公司域名表(company="xxx.com")
返回值：公司类型(可能用多个,','号分隔)
备注：company_user_table中company：
前可加'_'以满足一些需要、如数字开头无法命名时
后可加'_xx'以满足一些需要、如多次配置同一个公司名时

bool history_link_exist(string url_domain,table param_label)
功能：判断浏览器历史记录中是否含有带有指定参数的指定链接
参数：url_domain为链接域名（如：taobao.com）
param_label为链接中包含参数、为空不判断参数
返回值：是否存在

bool screen_saver_active()
功能：判断屏保是否活跃
参数：无
返回值：是否活跃

int open_url_cautious(string url,table browser_process_name)
功能：打开url(只在指定的已运行的浏览器打开、否则新建一个隐藏桌面打开)
参数：url为需要打开的链接
browser_process_name为浏览器进程名表
返回值：0失败、1指定浏览器打开、2隐藏桌面打开

int json_parsing(string json)
功能：解析json、返回根节点
参数：json为json字符串
返回值：根节点、-1为失败
注意：调用此函数会清理已缓存的所有节点

void json_clean()
功能：清理缓存的所有json节点
参数：无
返回值：无

int json_node(int parent,string node_name)
功能：获取json节点
参数：parent为父节点、node_name为节点名
返回值：节点id、-1为失败

int json_node_item(int parent,int item_index)
功能：获取json节点、主要针对数组
参数：parent为父节点、item_index为数组下标
返回值：节点id、-1为失败

int json_size(int node)
功能：获取json节点元素个数、主要针对数组
参数：node为节点id
返回值：节点元素个数

bool json_is_str(int node,string name)
功能：判断节点是否为字符串
参数：node为节点id、name为子节点名(没有必须填空字符串)
返回值：是返回true、不是返回false

string json_str(int node,string name)
功能：获取节点字符串
参数：node为节点id、name为子节点名(没有必须填空字符串)
返回值：节点值
注意：务必确保其类型匹配再使用此函数

bool json_is_int(int node,string name)
功能：判断节点是否为int
参数：node为节点id、name为子节点名(没有必须填空字符串)
返回值：是返回true、不是返回false

int json_int(int node,string name)
功能：获取节点int值
参数：node为节点id、name为子节点名(没有必须填空字符串)
返回值：节点值
注意：务必确保其类型匹配再使用此函数

bool json_is_bool(int node,string name)
功能：判断节点是否为bool
参数：node为节点id、name为子节点名(没有必须填空字符串)
返回值：是返回true、不是返回false

bool json_bool(int node,string name)
功能：获取节点bool值 参数：node为节点id、name为子节点名(没有必须填空字符串)
返回值：节点值
注意：务必确保其类型匹配再使用此函数

bool json_is_float(int node,string name)
功能：判断节点是否为浮点数
参数：node为节点id、name为子节点名(没有必须填空字符串)
返回值：是返回true、不是返回false

double json_float(int node,string name)
功能：获取节点浮点数
参数：node为节点id、name为子节点名(没有必须填空字符串)
返回值：节点值
注意：务必确保其类型匹配再使用此函数

string string_md5(string string_value)
功能：获取字符串的md5值
参数：string_value为需要计算的字符串
返回值：字符串的md5值

string dword_md5(DWORD dword_value)
功能：获取无符号整型的md5值
参数：dword_value为需要计算的DWORD值
返回值：DWORD的md5值

DWORD current_pid()
功能：获取当前进程的进程id
参数：无
返回值：当前进程的进程id

string pp_key()
功能：获取与弹窗协商的校验码(当前进程id的md5值)
参数：无
返回值：弹窗协商的校验码
