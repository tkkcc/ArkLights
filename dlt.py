#!/usr/bin/env python
import time
import sys
import re
import base64
import hmac
import os
import random
import string
import hashlib
import json
import traceback
import subprocess
import requests
import threading
from pathlib import Path
from collections import defaultdict
from datetime import datetime, timedelta

import fire

img_path = "tmp.jpg"
serial_alias = {
    "0": "127.0.0.1:5555",
    "1": "103.36.203.159:301",
    "2": "103.36.203.53:301",
    "3": "103.36.203.80:301",
    "4": "103.36.203.199:303",
    "6": "103.36.203.90:302",
    "7": "103.36.203.104:303",
    "8": "103.36.203.208:302",
    "9": "103.36.203.132:302",
    "5": "103.36.203.105:301",
}



def mode(serial, f="help", *args, **kwargs):
    serial = str(serial)
    package = "com.bilabila.arknightsspeedrun2"
    packagehash = "3205c0ded576131ea255ad2bd38b0fb2"
    # package = "com.nx.nxproj.assist"
    # packagehash = "110625af36f2b330ccbaef8b987812df"
    path = Path("serial") / serial
    path.mkdir(exist_ok=True, parents=True)
    alias = serial
    if len(serial) < 4:
        serial = serial_alias[alias]

    def help():
        return

    def hy():
        # 华云 adb root hook
        adb("shell", "nohup sh -c 'nc -klp49876 -e sh' > /dev/null 2>&1 &")
        return adb(
            "shell",
            "sh",
            "-c",
            """'
cat /proc/$(pidof com.bilabila.arknightsspeedrun2:remote)/oom_score_adj
cat /proc/$(pidof com.bilabila.arknightsspeedrun2:acc)/oom_score_adj
cat /proc/$(pidof com.bilabila.arknightsspeedrun2)/oom_score_adj
echo -1000 > /proc/$(pidof com.bilabila.arknightsspeedrun2:remote)/oom_score_adj
echo -1000 > /proc/$(pidof com.bilabila.arknightsspeedrun2:acc)/oom_score_adj
echo -1000 > /proc/$(pidof com.bilabila.arknightsspeedrun2)/oom_score_adj
cat /proc/$(pidof com.bilabila.arknightsspeedrun2:remote)/oom_score_adj
cat /proc/$(pidof com.bilabila.arknightsspeedrun2:acc)/oom_score_adj
cat /proc/$(pidof com.bilabila.arknightsspeedrun2)/oom_score_adj
ps|grep nc
am force-stop com.android.smspush
pm disable com.iflytek.inputmethod.miui
        '""",
        )

    def adb(*args):
        subprocess.run(["adb", "connect", serial], capture_output=True)
        out = subprocess.run(["adb", "-s", serial, *args], capture_output=True)
        # print("args",args)
        # print("out",out)

        return out.stdout.decode()

    def adbpull(name):
        adb(
            "pull",
            "/data/user/0/" + package + "/assistdir/" + packagehash + "/root/" + name,
            path / name,
        )

    def adbpush(name):
        adb(
            "push",
            path / name,
            "/data/user/0/" + package + "/assistdir/" + packagehash + "/root/" + name,
        )

    def load(name):
        adbpull(name)
        return defaultdict(str, json.load(open(path / name)))

    def save(name, data):
        json.dump(data, open(path / name, "w"), ensure_ascii=False)
        adbpush(name)

    def c(data, key, value):
        if data[key] == value:
            return
        print(key, data[key], "=>", value)
        data[key] = value

    def free():
        return adb("shell", "free", "-h")

    def ps():
        return adb("shell", "ps|grep bila")

    def rmpic():
        adb(
            "shell",
            "find",
            "/sdcard/" + package,
            "-type",
            "f",
            "-iname",
            "*.jpg",
            "-delete",
        )

    def pic(name="", path=img_path):
        path = Path(path)
        name = str(name)
        x = adb(
            "shell",
            "find",
            "/sdcard/" + package,
            "-iname",
            "*" + name + "*.jpg",
        )
        x = x.split("\n")
        x = list(sorted(filter(None, x)))
        for i in range(len(x)):
            print(Path(x[i]).stem)

        if path.exists():
            path.unlink()
        if len(x) == 0:
            print("未找到", name)
            return
        adb(
            "pull",
            x[-1],
            path,
        )

        subprocess.run(["feh", "--title", "float", path])

    def users(x):
        for x in filter(None, x.split("\n")):
            subprocess.run(["./dlt.py", "mode", serial, "user", x])

    def user(
        username=None,
        password=None,
        server=None,
        fight=None,
        idx=None,
        weekday_only=None,
    ):
        x = load("config_multi_account.json")
        x = defaultdict(str, x)
        print("==> 当前账号")
        first_empty_i = 0
        for i in range(1, 31):
            if (
                not str(x["username" + str(i)]).strip()
                or not str(x["password" + str(i)]).strip()
            ):
                if first_empty_i == 0:
                    first_empty_i = i
                continue
            print(
                "0 m",alias,"user",
                x["username" + str(i)],
                x["password" + str(i)],
                "--server" if x["server" + str(i)] == 1 else "",
                ("--fight='" + x["multi_account_user" + str(i) + "fight_ui"] + "'")
                if x["multi_account_inherit_toggle" + str(i)] == "独立设置"
                else "",
                "--idx=" + str(i),
            )
        if not username and not password:
            return
        if idx:
            first_empty_i = idx
        print("==> 添加至账号" + str(first_empty_i))
        c(x, f"username{first_empty_i}", str(username))
        c(x, f"password{first_empty_i}", str(password))
        c(x, f"multi_account_inherit_spinner{first_empty_i}", "0")
        c(x, f"server{first_empty_i}", 1 if server else 0)
        if fight:
            c(x, f"multi_account_user{first_empty_i}fight_ui", fight)
            c(x, f"multi_account_inherit_toggle{first_empty_i}", "独立设置")
        else:
            c(x, f"multi_account_inherit_toggle{first_empty_i}", "继承设置")
        # c(
        #     x,
        #     "multi_account_choice",
        #     x["multi_account_choice"].split("#")[0] + "#" + str(first_empty_i),
        # )

        save("config_multi_account.json", x)
        # print("username", username)
        if weekday_only:
            x = load("config_debug.json")
            x = defaultdict(str, x)
            c(
                x,
                "multi_account_choice_weekday_only",
                x["multi_account_choice_weekday_only"] + " " + str(first_empty_i),
            )
            save("config_debug.json", x)

    def clear():
        x = load("config_multi_account.json")
        print("==> 当前账号")
        first_empty_i = 0
        for i in range(1, 31):
            c(x, "username" + str(i), "")
            c(x, "password" + str(i), "")
            # if not x["username" + str(i)] or not x["password" + str(i)]:
            #     if first_empty_i == 0:
            #         first_empty_i = i
            #     continue
            # print(
            #     i,
            #     x["username" + str(i)],
            #     x["password" + str(i)],
            #     "b" if x["server" + str(i)] == 1 else "",
            # )

        x = {}
        save("config_multi_account.json", x)

    def findNode(text="", id=""):
        import xml.etree.ElementTree as ET

        x = adb("exec-out", "uiautomator", "dump", "/dev/tty")
        x = re.search("(<.+>)", x)
        if not x:
            return
        x = x.group(1)
        tree = ET.XML(x)
        btn = None
        # ans = []
        for elem in tree.iter():
            elem = elem.attrib
            # print(elem)
            if (
                text
                and elem.get("text", None) == text
                or id
                and elem.get("resource-id", None) == id
            ):
                btn = elem.get("bounds", None)
                btn = re.search("(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+(\d+)", btn).groups()
                x = (int(btn[0]) + int(btn[2])) // 2
                y = (int(btn[1]) + int(btn[3])) // 2
                # print(text, x, y)
                return x, y
                # ans.append([x, y])
        # return ans

        # return ET.tostring(tree, encoding='unicode')

    def foreground():
        x = adb("shell", "dumpsys", "activity", "recents")
        x = re.search("Recent #0.*(com[^\s]+)", x)
        if x:
            return x.group(1)

        # | grep 'Recent #0' | cut -d= -f2 | sed 's| .*||' | cut -d '/' -f1

        # x = adb("shell", "dumpsys", "window", "windows")
        # x = re.search("mCurrentFocus=.* ([^ ]+)/(.+)", x)
        if x:
            return x.group(1)

    def stop(app=package):
        adb("shell", "input", "home")
        adb("shell", "am", "force-stop", app)

    def start():
        adb("shell", "input", "home")
        adb(
            "shell",
            "monkey",
            "-p",
            package,
            "-c",
            "android.intent.category.LAUNCHER",
            "1",
        )
        see_package = False
        for i in range(50):
            time.sleep(1)
            # print("foreground", foreground())
            # print("package",package)
            # print("see_package",see_package)
            if foreground() == package:
                ok = findNode("确定")
                cancel = findNode("取消")
                if cancel:
                    x, y = cancel
                    adb("shell", "input", "tap", str(x), str(y))
                elif ok:
                    x, y = ok
                    adb("shell", "input", "tap", str(x), str(y))
                    see_package = True
            elif see_package:
                break

    def rg1(username, password, server=None, fight=None):
        normal()

        # 切号 独立设置，任务全关
        x = load("config_multi_account.json")
        c(x, "multi_account_enable", True)
        c(x, "multi_account_choice", "1")
        c(x, "username1", str(username))
        c(x, "password1", str(password))
        c(x, "server1", 1 if server else 0)
        c(x, f"multi_account_inherit_toggle1", "独立设置")
        for i in range(13):
            c(x, f"multi_account_user1now_job_ui" + str(i), False)
        save("config_multi_account.json", x)

        # 肉鸽日常
        x = load("config_main.json")
        c(x, f"fight_ui", fight or "ce ls")
        c(x, "server", 1 if server else 0)
        save("config_main.json", x)

        # 肉鸽等级模式，未选干员，不做日常
        x = load("config_extra.json")
        c(x, "zl_best_operator", "")
        c(x, "zl_skill_times", "0")
        c(x, "zl_skill_idx", "1")
        c(x, "zl_more_repertoire", False)
        c(x, "zl_more_experience", True)
        c(x, "zl_skip_coin", True)
        c(x, "zl_accept_mg", True)
        c(x, "zl_accept_yx", True)
        c(x, "zl_accept_sc", True)
        c(x, "zl_skip_hard", False)
        c(x, "zl_no_waste", False)
        c(x, "zl_need_goods", "")
        c(x, "zl_max_level", "125")
        c(x, "zl_max_coin", "")
        save("config_extra.json", x)

        x = load("config_debug.json")
        c(x, "max_drug_times_" + str(1) + "day", "99")
        c(x, "max_drug_times_" + str(2) + "day", "0")
        c(x, "max_drug_times_" + str(3) + "day", "0")
        c(x, "max_drug_times_" + str(4) + "day", "0")
        c(x, "max_drug_times_" + str(5) + "day", "0")
        c(x, "max_drug_times_" + str(6) + "day", "0")
        c(x, "max_drug_times_" + str(7) + "day", "0")
        save("config_debug.json", x)

        # 重启
        restart()

    def rg2(operator=None, times=None, skill=None, level=None):
        # 肉鸽选干员，做日常
        x = load("config_extra.json")
        if operator:
            c(x, "zl_no_waste", True)
            c(x, "zl_best_operator", str(operator))
            c(x, "zl_skill_times", str(times))
            c(x, "zl_skill_idx", str(skill))
        if level:
            c(x, "zl_max_level", str(level))
        save("config_extra.json", x)

        # 重启
        restart(rg=True)

    def restart(account="", hide=True, rg=False, game=False):
        if account:
            x = load("config_multi_account.json")
            c(
                x,
                "multi_account_choice",
                x["multi_account_choice"].split("#")[0] + "#" + str(account),
            )
            save("config_multi_account.json", x)

        x = load("config_debug.json")
        x["after_require_hook"] = (
            "clear_hook();"
            + ("saveConfig('hideUIOnce','true')" if hide else "")
            + ("extra_mode=[[战略前瞻投资]]" if rg else "")
        )
        save("config_debug.json", x)
        oppid = "com.hypergryph.arknights"
        bppid = "com.hypergryph.arknights.bilibili"
        if game:
            stop(oppid)
            stop(bppid)
        stop()
        start()

    def show():
        subprocess.run(["adb", "connect", serial], capture_output=True)
        print("serial", serial)
        subprocess.run(["scrcpy", "-s", serial], capture_output=True)

    def normal(name=None, weekday_only=None, fight=None):
        x = load("config_main.json")
        # print("x.keys()", x.keys())
        c(x, "fight_ui", fight or "jm hd ce ls")
        save("config_main.json", x)

        x = load("config_debug.json")
        c(x, "max_jmfight_times", "1")
        c(x, "max_login_times_5min", "3")
        if name:
            c(x, "QQ", name)
        c(
            x,
            "multi_account_choice_weekday_only",
            weekday_only or x["multi_account_choice_weekday_only"],
        )
        c(x, "qqnotify_beforemail", True)
        c(x, "qqnotify_afterenter", True)
        c(x, "qqnotify_beforeleaving", True)
        c(x, "qqnotify_beforemission", True)
        c(x, "qqnotify_save", True)
        c(x, "collect_beforeleaving", True)
        # 一是完成日常任务，二是提高8小时容错
        c(x, "zero_san_after_fight", True)

        c(x, "max_drug_times_" + str(1) + "day", "99")
        c(x, "max_drug_times_" + str(2) + "day", "99")
        c(x, "max_drug_times_" + str(3) + "day", "1")
        c(x, "max_drug_times_" + str(4) + "day", "1")
        c(x, "max_drug_times_" + str(5) + "day", "1")
        c(x, "max_drug_times_" + str(6) + "day", "0")
        c(x, "max_drug_times_" + str(7) + "day", "0")
        c(x, "enable_log", False)
        c(x, "enable_disable_lmk", False)
        c(x, "disable_killacc1", False)

        save("config_debug.json", x)

        x = load("config_multi_account.json")
        c(x, "multi_account_end_closeotherapp", True)
        c(x, "multi_account_end_closeapp", True)
        c(x, "multi_account_choice", "1-30")
        save("config_multi_account.json", x)

    def soft():
        x = load("config_debug.json")
        c(x, "max_login_times_5min", "1")
        save("config_debug.json", x)

    def hard():
        x = load("config_debug.json")
        c(x, "max_login_times_5min", "3")
        save("config_debug.json", x)

    def lmk():
        return adb("shell", "cat", "/sys/module/lowmemorykiller/parameters/minfree")

    def top():
        return adb("shell", "top", "-s", "rss", "-m", "10", "-n", "1")

    return locals()[f](*args, **kwargs)


def t(x):
    return x


if __name__ == "__main__":
    fire.Fire()
