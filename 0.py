import os
import re
import sys
import datetime
from time import sleep
import hashlib
import shutil
import win32gui
import win32con
import win32api
import win32com.client

# win环境下的快速开发脚本

# 配置全局路径 请确保路径存在
path = "D:\dev\Lr\ArkLightsLite\main"
pkgPath = "D:\Tools\懒人精灵3.8.3\out\main.lr"


class WindowMgr:
    """Encapsulates some calls to the winapi for window management"""

    def __init__(self):
        """Constructor"""
        self._handle = None

    def find_window(self, class_name, window_name=None):
        """基于类名来查找窗口"""
        self._handle = win32gui.FindWindow(class_name, window_name)

    def _window_enum_callback(self, hwnd, class_name_wildcard_list):
        """传递给win32gui.EnumWindows()，检查所有打开的顶级窗口"""
        class_name, wildcard = class_name_wildcard_list
        if re.match(wildcard, str(win32gui.GetWindowText(hwnd))) is not None:
            self._handle = hwnd

    def find_window_wildcard(self, class_name, wildcard):
        """根据类名，查找一个顶级窗口，确保其类名相符，且标题可以用正则表达式匹配对应的通配符"""
        self._handle = None
        win32gui.EnumWindows(self._window_enum_callback,
                             [class_name, wildcard])
        return self._handle

    def set_foreground(self):
        """put the window in the foreground"""
        win32gui.SetForegroundWindow(self._handle)

    def get_hwnd(self):
        """return hwnd for further use"""
        return self._handle


def run():
    '''自动运行调试 需提前打开任意lua文件'''
    myWindowMgr = WindowMgr()
    hwnd = myWindowMgr.find_window_wildcard(None, ".*?懒人精灵 - .*?")
    if hwnd != None:
        win32gui.BringWindowToTop(hwnd)
        # 先发送一个alt事件，否则会报错导致后面的设置无效：pywintypes.error: (0, 'SetForegroundWindow', 'No error message is available')
        shell = win32com.client.Dispatch("WScript.Shell")
        shell.SendKeys('%')
        # 设置为当前活动窗口
        win32gui.SetForegroundWindow(hwnd)
        # 最大化窗口
        win32gui.ShowWindow(hwnd, win32con.SW_MAXIMIZE)
        # F6
        win32api.keybd_event(117, win32api.MapVirtualKey(117, 0), 0, 0)
        win32api.keybd_event(117, win32api.MapVirtualKey(
            117, 0), win32con.KEYEVENTF_KEYUP, 0)
        sleep(0.1)
        # F5
        win32api.keybd_event(116, win32api.MapVirtualKey(116, 0), 0, 0)
        win32api.keybd_event(116, win32api.MapVirtualKey(
            116, 0), win32con.KEYEVENTF_KEYUP, 0)


def save(forRelease):
    '''保存到懒人精灵工程文件夹'''
    with open("main.lua", "r", encoding='utf-8') as f:
        lines = f.readlines()
        ss = ""
        for line in lines:
            if not forRelease:
                if (re.match('-- disable_hotupdate = true', line)):
                    line = 'disable_hotupdate = true\n'
            else:
                if (re.match('disable_hotupdate = true', line)):
                    line = '-- disable_hotupdate = true\n'
            if (re.match('release_date = ".*"', line)):
                line = 'release_date = "' + \
                    str(datetime.datetime.now().strftime("%m.%d %H:%M")) + '"\n'
            ss += line
    with open("main.lua", "w", encoding='utf-8') as f:
        f.write(ss)

    # 获取当前目录下所有的.lua文件
    lua_files = [f for f in os.listdir('.') if f.endswith('.lua')]
    for lua_file in lua_files:
        # 把lua_file以utf-8的格式打开，然后以GB18030的格式写入到"D:\ArkLights\main\脚本"目录下
        with open(lua_file, 'r', encoding='utf-8') as f:
            with open(os.path.join(path, '脚本', lua_file), 'w', encoding='GB18030') as f1:
                f1.write(f.read())

    # 获取当前目录下所有的.ui文件
    ui_files = [f for f in os.listdir('.') if f.endswith('.ui')]
    for ui_file in ui_files:
        # 把ui_file以utf-8的格式打开，然后以GB18030的格式写入到path+界面目录下
        with open(ui_file, 'r', encoding='utf-8') as f:
            with open(os.path.join(path, '界面', ui_file), 'w', encoding='GB18030') as f1:
                f1.write(f.read())

    print("保存完成")


def saverun():
    '''保存并运行'''
    save(False)
    run()


def release():
    save(True)
    ready = not input("已经在懒人打包了吗[Y/n]: ") == 'n' or False
    if not ready:
        exit()
    
    '''发布'''
    # 复制pkgPath到release
    shutil.copy(pkgPath, os.path.join("./release/", 'script.lr'))
    # 输出pkgPath的文件的md5
    md5 = hashlib.md5()
    with open(pkgPath, 'rb') as f:
        md5.update(f.read())
    md5Text = md5.hexdigest()
    # 将md5.hexdigest()写入到release目录下的script.lr.md5文件中
    with open(os.path.join("./release/", 'script.lr.md5'), 'w', encoding='utf-8') as f:
        f.write(md5.hexdigest())
        f.write('\n')
    # 判断输入值是否与md5Text相等
    if (input("请输入md5值: ") == md5Text):
        print("md5值正确")
        # 运行命令
        os.system("git -C release add -u")
        os.system("git -C release commit --amend --allow-empty-message --no-edit")
        os.system("git -C release push --force")
    else:
        print("md5值错误")


if __name__ == '__main__':
    try:
        arg = sys.argv[1]
        if arg == 'run':
            run()
        elif arg == 'save':
            save(False)
        elif arg == 'saverun':
            saverun()
        elif arg == 'release':
            release()
    except Exception as e:
        print(sys.argv)
        print(e)
