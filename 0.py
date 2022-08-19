import os
import re
import sys
import datetime
import win32gui, win32con, win32api

# win环境下的快速开发脚本

class WindowMgr:
    """Encapsulates some calls to the winapi for window management"""

    def __init__ (self):
        """Constructor"""
        self._handle = None

    def find_window(self, class_name, window_name=None):
        """基于类名来查找窗口"""
        self._handle = win32gui.FindWindow(class_name, window_name)

    def _window_enum_callback(self, hwnd, class_name_wildcard_list):
        """传递给win32gui.EnumWindows()，检查所有打开的顶级窗口"""
        class_name,wildcard=class_name_wildcard_list
        if re.match(wildcard, str(win32gui.GetWindowText(hwnd))) is not None:
            self._handle = hwnd

    def find_window_wildcard(self, class_name,wildcard):
        """根据类名，查找一个顶级窗口，确保其类名相符，且标题可以用正则表达式匹配对应的通配符"""
        self._handle = None
        win32gui.EnumWindows(self._window_enum_callback,[class_name, wildcard])
        return self._handle

    def set_foreground(self):
        """put the window in the foreground"""
        win32gui.SetForegroundWindow(self._handle)

    def get_hwnd(self):
        """return hwnd for further use"""
        return self._handle



def run():
    '''自动运行 但是好像有点BUG'''
    myWindowMgr=WindowMgr()
    hwnd = myWindowMgr.find_window_wildcard(None,".*?懒人精灵.*?")
    if hwnd != None:
        print("找到了懒人精灵")
    # 若最小化，则将其显示，反之则最小化
        if win32gui.IsIconic(hwnd):
            win32gui.ShowWindow(hwnd, win32con.SW_SHOWMAXIMIZED)
        win32gui.SetForegroundWindow(hwnd)  # 设置前置窗口
        win32gui.SetFocus(hwnd)
        win32api.keybd_event(116,0,0,0)     # F5
        win32api.keybd_event(116,0,win32con.KEYEVENTF_KEYUP,0)  #释放按键

    


def save():
    with open("main.lua","r", encoding='utf-8') as f:
        lines = f.readlines()
        ss = ""
        for line in lines:
            if (re.match('release_date = ".*"', line)):
                print("line:     " + str(line))
                line = 'release_date = "' + str(datetime.datetime.now().strftime("%m.%d %H:%M")) + '"\n'
            ss += line
    with open("main.lua", "w", encoding='utf-8') as f:
        f.write(ss) 
    
    # 获取当前目录下所有的.lua文件
    lua_files = [f for f in os.listdir('.') if f.endswith('.lua')]
    for lua_file in lua_files:
        # 把lua_file以utf-8的格式打开，然后以GB18030的格式写入到"D:\ArkLights\main\脚本"目录下
        with open(lua_file, 'r', encoding='utf-8') as f:
            with open(os.path.join('D:\ArkLights\main\脚本', lua_file), 'w', encoding='GB18030') as f1:
                f1.write(f.read())

    # 获取当前目录下所有的.ui文件
    ui_files = [f for f in os.listdir('.') if f.endswith('.ui')]
    for ui_file in ui_files:
        # 把ui_file以utf-8的格式打开，然后以GB18030的格式写入到"D:\ArkLights\main\界面"目录下
        with open(ui_file, 'r', encoding='utf-8') as f:
            with open(os.path.join('D:\ArkLights\main\界面', ui_file), 'w', encoding='GB18030') as f1:
                f1.write(f.read())

    print("保存完成")

    

def saverun():
    save()
    run()

if __name__ == '__main__':
    try:
        arg = sys.argv[1]
        if arg == 'run':
            run()
        elif arg == 'save':
            save()
        elif arg == 'saverun':
            saverun()
    except Exception as e:
        print(sys.argv)
        print(e)