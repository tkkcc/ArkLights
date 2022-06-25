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
from collections import Counter
from collections import deque
from datetime import datetime, timedelta

import fire

img_path = "tmp.jpg"
log_path = "log"
log_path = Path(log_path)
log_path.mkdir(exist_ok=True, parents=True)
serial_alias = {
    "21": "103.36.203.215:301",
    "23": "103.36.203.125:301",
    "24": "103.36.203.81:301",
    "0": "127.0.0.1:5555",
    "1": "103.36.203.159:301",
    "2": "103.36.203.53:301",
    "3": "103.36.203.80:301",
    "4": "103.36.203.199:303",
    "6": "103.36.201.74:301",
    "7": "103.36.203.104:303",
    "8": "103.36.203.208:302",
    "9": "103.36.203.132:302",
    "10": "103.36.203.125:301",
    "5": "103.36.203.105:301",
}
daily_device = ["1", "4", "5", "9", "3"]
rg_device = ["1", "2", "0"]
oppid = "com.hypergryph.arknights"
bppid = "com.hypergryph.arknights.bilibili"



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

    def hyi():
        # 华云 系统精简
        adb(
            "shell",
            """
pm uninstall -k --user 0 com.android.nfc
pm uninstall -k --user 0 com.android.appstore
pm uninstall -k --user 0 com.android.location
pm uninstall -k --user 0 com.android.printspooler
pm uninstall -k --user 0 com.android.cellbroadcastreceiver
pm uninstall -k --user 0 com.android.keychain
pm uninstall -k --user 0 com.android.providers.calendar
pm uninstall -k --user 0 com.android.dialer
pm uninstall -k --user 0 com.android.managedprovisioning
pm uninstall -k --user 0 com.android.messaging
pm uninstall com.android.location
pm uninstall android.process.acore
pm uninstall -k --user 0 android.process.acore
pm uninstall com.android.phone
pm uninstall -k --user 0 com.android.phone
pm uninstall -k --user 0 com.iflytek.inputmethod.miui
pm uninstall -k --user 0 com.cxinventor.file.explorer
reboot
""",
        )

    def hy2():
        # 华云 系统精简 v2 64位开机剩余1.3G 32位开机剩余1.6G
        # 安装应用后需要重启几次，内存才会释放，不知道为什么
        # 启动过速通 64位开机剩余1.0G 32位开机剩余1.1G
        adb(
            "shell",
            """
# pm list packages -f|sed -r 's|[^/]+(/.+)=(.+)|rm \1 # \2|'


# ok
rm /system/app/PicoTts/PicoTts.apk # com.svox.pico
rm /system/app/PrintRecommendationService/PrintRecommendationService.apk # com.android.printservice.recommendation
rm /system/app/PrintSpooler/PrintSpooler.apk # com.android.printspooler
rm /system/app/Protips/Protips.apk # com.android.protips
rm /system/app/UserDictionaryProvider/UserDictionaryProvider.apk # com.android.providers.userdictionary
rm /system/app/WallpaperBackup/WallpaperBackup.apk # com.android.wallpaperbackup
rm /data/app/SoftKeyboard/SoftKeyboard.apk # com.example.android.softkeyboard
rm /data/app/com.android.appstore-1/base.apk # com.android.appstore
rm /data/app/com.android.camera-1/base.apk # com.android.camera
rm /data/app/com.android.chrome-1/base.apk # com.android.chrome
rm /data/app/com.android.location-1/base.apk # com.android.location
rm /data/app/com.android.nfc-1/base.apk # com.android.nfc
rm /data/app/com.cxinventor.file.explorer-1/base.apk # com.cxinventor.file.explorer
rm /data/app/com.iflytek.inputmethod.miui-1/base.apk # com.iflytek.inputmethod.miui
rm /data/app/com.mmbox.xbrowser-1/base.apk # com.mmbox.xbrowser
rm /data/app/jackpal.androidterm-1/base.apk # jackpal.androidterm
rm /system/app/BasicDreams/BasicDreams.apk # com.android.dreams.basic
rm /system/app/BookmarkProvider/BookmarkProvider.apk # com.android.bookmarkprovider
rm /system/app/Camera2/Camera2.apk # com.android.camera2
rm /system/app/CaptivePortalLogin/CaptivePortalLogin.apk # com.android.captiveportallogin
rm /system/app/EasterEgg/EasterEgg.apk # com.android.egg
rm /system/app/KeyChain/KeyChain.apk # com.android.keychain
rm /system/app/Gallery/Gallery.apk # com.android.gallery
rm /system/app/LiveWallpapersPicker/LiveWallpapersPicker.apk # com.android.wallpaper.livepicker
rm /system/app/PacProcessor/PacProcessor.apk # com.android.pacprocessor
rm /system/priv-app/BackupRestoreConfirmation/BackupRestoreConfirmation.apk # com.android.backupconfirm
rm /system/priv-app/BlockedNumberProvider/BlockedNumberProvider.apk # com.android.providers.blockednumber
rm /system/priv-app/CalendarProvider/CalendarProvider.apk # com.android.providers.calendar
rm /system/priv-app/CallLogBackup/CallLogBackup.apk # com.android.calllogbackup
rm /system/priv-app/CarrierConfig/CarrierConfig.apk # com.android.carrierconfig
rm /system/priv-app/CellBroadcastReceiver/CellBroadcastReceiver.apk # com.android.cellbroadcastreceiver
rm /system/priv-app/Contacts/Contacts.apk # com.android.contacts
rm /system/priv-app/ContactsProvider/ContactsProvider.apk # com.android.providers.contacts
rm /system/priv-app/EmergencyInfo/EmergencyInfo.apk # com.android.emergency
rm /system/priv-app/FusedLocation/FusedLocation.apk # com.android.location.fused
rm /system/priv-app/TeleService/TeleService.apk # com.android.phone
rm /system/priv-app/Telecom/Telecom.apk # com.android.server.telecom
rm /system/priv-app/TelephonyProvider/TelephonyProvider.apk # com.android.providers.telephony
rm /system/priv-app/VpnDialogs/VpnDialogs.apk # com.android.vpndialogs
rm /system/priv-app/InputDevices/InputDevices.apk # com.android.inputdevices
rm /system/priv-app/MmsService/MmsService.apk # com.android.mms.service
rm /system/app/OpenWnn/OpenWnn.apk # jp.co.omronsoft.openwnn
rm /system/priv-app/MtpDocumentsProvider/MtpDocumentsProvider.apk # com.android.mtp
rm /system/priv-app/ProxyHandler/ProxyHandler.apk # com.android.proxyhandler
rm /system/app/messaging/messaging.apk # com.android.messaging
rm /system/app/Fallback/Fallback.apk # com.android.fallback
rm /system/app/DownloadProviderUi/DownloadProviderUi.apk # com.android.providers.downloads.ui
rm /system/priv-app/DownloadProvider/DownloadProvider.apk # com.android.providers.downloads

rm /system/priv-app/Shell/Shell.apk # com.android.shell
rm /system/app/CertInstaller/CertInstaller.apk # com.android.certinstaller

rm /system/priv-app/ManagedProvisioning/ManagedProvisioning.apk # com.android.managedprovisioning
rm /system/app/CtsShimPrebuilt/CtsShimPrebuilt.apk # com.android.cts.ctsshim
rm /system/priv-app/MediaProvider/MediaProvider.apk # com.android.providers.media
rm /system/priv-app/SharedStorageBackup/SharedStorageBackup.apk # com.android.sharedstoragebackup

rm /system/priv-app/SdkSetup/SdkSetup.apk # com.android.sdksetup
rm /system/priv-app/CtsShimPrivPrebuilt/CtsShimPrivPrebuilt.apk # com.android.cts.priv.ctsshim

rm /system/priv-app/StorageManager/StorageManager.apk # com.android.storagemanager
rm /system/priv-app/DocumentsUI/DocumentsUI.apk # com.android.documentsui
rm /system/priv-app/Dialer/Dialer.apk # com.android.dialer
rm /system/priv-app/ExternalStorageProvider/ExternalStorageProvider.apk # com.android.externalstorage

# not for install apk
# rm /system/priv-app/DefaultContainerService/DefaultContainerService.apk # com.android.defcontainer

# no
# rm /data/app/com.android.setting-1/base.apk # com.android.setting
# rm /system/app/HTMLViewer/HTMLViewer.apk # com.android.htmlviewer
# rm /system/app/LatinIME/LatinIME.apk # com.android.inputmethod.latin
# rm /system/app/webview/webview.apk # com.google.android.webview
# rm /system/framework/framework-res.apk # android
# rm /system/priv-app/SystemUI/SystemUI.apk # com.android.systemui
# rm /system/priv-app/Launcher/Launcher.apk # com.android.launcher2
# rm /system/priv-app/PackageInstaller/PackageInstaller.apk # com.android.packageinstaller
# rm /system/priv-app/Settings/Settings.apk # com.android.settings
# rm /system/priv-app/SettingsProvider/SettingsProvider.apk # com.android.providers.settings
# rm /system/app/Remote/Remote.apk # com.android.smspush
# rm /system/priv-app/StatementService/StatementService.apk # com.android.statementservice
# rm /system/priv-app/ExtServices/ExtServices.apk # android.ext.services
# rm /system/app/ExtShared/ExtShared.apk # android.ext.shared
reboot
""",
        )

    def hy(dry=False):
        # 华云 adb root hook
        print(
            adb(
                "shell",
                "sh",
                "-c",
                """'
ps|grep nc
cat /proc/$(pidof com.bilabila.arknightsspeedrun2:remote)/oom_score;
cat /proc/$(pidof com.bilabila.arknightsspeedrun2)/oom_score
cat /proc/$(pidof com.bilabila.arknightsspeedrun2:acc)/oom_score
'""",
            )
        )
        if dry:
            return

        adb("shell", "nohup sh -c 'nc -klp49876 -e sh' > /dev/null 2>&1 &")
        print(
            adb(
                "shell",
                "sh",
                "-c",
                """'
ps|grep nc
echo -1000 > /proc/$(pidof com.bilabila.arknightsspeedrun2:remote)/oom_score_adj
echo -1000 > /proc/$(pidof com.bilabila.arknightsspeedrun2:acc)/oom_score_adj
echo -1000 > /proc/$(pidof com.bilabila.arknightsspeedrun2)/oom_score_adj
sleep 1
cat /proc/$(pidof com.bilabila.arknightsspeedrun2:remote)/oom_score
cat /proc/$(pidof com.bilabila.arknightsspeedrun2)/oom_score
cat /proc/$(pidof com.bilabila.arknightsspeedrun2:acc)/oom_score
        '""",
            )
        )

    def adb(*args):
        subprocess.run(["adb", "connect", serial], capture_output=True)
        out = subprocess.run(["adb", "-s", serial, *args], capture_output=True)
        # print("args",args)
        # print("out",out)

        return out.stdout.decode()

    def adbserial(*args):
        return serial

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
        p = path / name
        if not p.exists():
            open(p, "w").write("{}")
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

    def df():
        return adb("shell", "df -h")

    def rmpic(x=""):
        adb(
            "shell",
            "find",
            "/sdcard/" + package,
            "-type",
            "f",
            "-iname",
            "*" + str(x) + "*.jpg",
            "-delete",
        )

    def pic(name="", path=img_path, show=True, wait=False):
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
            if wait:
                return pic(name, path, show, wait)
            return
        adb(
            "pull",
            x[-1],
            path,
        )

        logfile = log_path / "pic.txt"
        logfile = open(logfile, "w")
        logfile.write(x[-1] + "\n")
        logfile.close()

        if show:
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
        drug=None,
        recruit=None,
    ):
        weekday_only_list = load("config_debug.json")[
            "multi_account_choice_weekday_only"
        ].split()

        x = load("config_multi_account.json")
        ans = ""
        ans += "==> 当前账号\n"
        first_empty_i = 0
        for i in range(1, 31):
            if (
                not str(x["username" + str(i)]).strip()
                or not str(x["password" + str(i)]).strip()
            ):
                if first_empty_i == 0:
                    first_empty_i = i
                continue
            usernamei = x["username" + str(i)].replace("\s", "")
            passwordi = x["password" + str(i)].replace("\s", "")
            # print(x["multi_account_user" + str(i) + "max_drug_times"])
            # exit()
            ans += (
                f"0 m {alias} user {usernamei} {passwordi}"
                + (" --server" if x["server" + str(i)] == 1 else "")
                + (
                    (" --fight='" + x["multi_account_user" + str(i) + "fight_ui"] + "'")
                    if x["multi_account_inherit_toggle" + str(i)] == "独立设置"
                    else ""
                )
                + (
                    (" --drug")
                    if x["multi_account_inherit_toggle" + str(i)] == "独立设置"
                    and int(x["multi_account_user" + str(i) + "max_drug_times"]) > 0
                    else ""
                )
                # + (
                #     (
                #         " --recruit"
                #     )
                #     if x["multi_account_inherit_toggle" + str(i)] == "独立设置"
                #     and x["multi_account_user" + str(i) + "auto_recruit0"]
                #     else ""
                # )
                + (" --weekday-only" if str(i) in weekday_only_list else "")
                + " --idx="
                + str(i)
                + "\n"
            )
        ans = ans.strip()
        logfile = open(log_path / "user.txt", "a")
        logfile.write(ans + "\n")
        logfile.close()
        print(ans)

        if not username or not password:
            username = ""
            password = ""

        if not username and not password and not idx:
            return
        if idx:
            first_empty_i = idx

        print("==> 添加至账号" + str(first_empty_i))
        c(x, f"username{first_empty_i}", str(username))
        c(x, f"password{first_empty_i}", str(password))
        c(x, f"multi_account_inherit_spinner{first_empty_i}", 0)
        c(x, f"server{first_empty_i}", 1 if server else 0)
        c(x, f"multi_account_user{first_empty_i}auto_recruit0", True)
        c(x, f"multi_account_user{first_empty_i}auto_recruit1", True)
        c(x, f"multi_account_user{first_empty_i}auto_recruit4", True)
        c(x, f"multi_account_user{first_empty_i}auto_recruit5", True)
        for i in range(1, 13):
            c(x, f"multi_account_user{i}now_job_ui" + str(i), True)
        c(x, f"multi_account_user{i}now_job_ui8", False)
        if fight or drug:
            c(x, f"multi_account_inherit_toggle{first_empty_i}", "独立设置")
        else:
            c(x, f"multi_account_inherit_toggle{first_empty_i}", "继承设置")
        c(x, f"multi_account_user{first_empty_i}fight_ui", fight or "jm hd ce ls ap pr")
        c(x, f"multi_account_user{first_empty_i}max_drug_times", str(2 if drug else 0))
        save("config_multi_account.json", x)

        x = load("config_debug.json")
        l = x["multi_account_choice_weekday_only"].split()
        l = [x for x in l if x != str(first_empty_i)]
        if weekday_only:
            l.append(str(first_empty_i))
        l = " ".join(l)
        c(x, "multi_account_choice_weekday_only", l)
        save("config_debug.json", x)

    def clear():
        x = load("config_multi_account.json")
        print("==> 当前账号")
        first_empty_i = 0
        for i in range(1, 31):
            c(x, "username" + str(i), "")
            c(x, "password" + str(i), "")
        x = {}
        save("config_multi_account.json", x)

    findNodeCache = None

    def findNode(text="", id="", cache=False):
        import xml.etree.ElementTree as ET

        nonlocal findNodeCache
        if cache:
            x = findNodeCache
        else:
            x = adb("exec-out", "uiautomator", "dump", "/dev/tty")
            x = re.search("(<.+>)", x)
        findNodeCache = x

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
        adb("shell", "input", "keyevent", "KEYCODE_HOME")
        adb("shell", "am", "force-stop", app)

    def start():
        adb("shell", "input", "keyevent", "KEYCODE_HOME")
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
                findNode()
                ok = findNode("确定", cache=True)
                cancel = findNode("取消", cache=True)
                if cancel:
                    x, y = cancel
                    adb("shell", "input", "tap", str(x), str(y))
                elif ok:
                    x, y = ok
                    adb("shell", "input", "tap", str(x), str(y))
                    see_package = True
            snap = findNode(
                id="com.bilabila.arknightsspeedrun2:id/switch_snap", cache=True
            )
            if snap:
                x, y = snap
                adb("shell", "input", "tap", str(x), str(y))
            if foreground() == oppid or foreground() == bppid and see_package:
                break
            # elif see_package:
            #     break

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
        # c(x, f"fight_ui", fight or "jm hd ce ls")
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

        # x = load("config_debug.json")
        # c(x, "max_drug_times_" + str(1) + "day", "99")
        # c(x, "max_drug_times_" + str(2) + "day", "99")
        # c(x, "max_drug_times_" + str(3) + "day", "1")
        # c(x, "max_drug_times_" + str(4) + "day", "1")
        # c(x, "max_drug_times_" + str(5) + "day", "1")
        # c(x, "max_drug_times_" + str(6) + "day", "1")
        # c(x, "max_drug_times_" + str(7) + "day", "1")
        # save("config_debug.json", x)

        # 重启
        restart()

    def rg2(
        operator=None,
        times=None,
        skill=None,
        level=None,
        waste=None,
        skip_hard=None,
        fight=None,
    ):
        # 肉鸽选干员，做日常
        if fight:
            x = load("config_main.json")
            x["fight_ui"] = fight
            save("config_main.json", x)

        x = load("config_extra.json")
        if operator:
            c(x, "zl_no_waste", True if not waste else False)
            c(x, "zl_best_operator", str(operator))
            c(x, "zl_skill_times", str(times))
            c(x, "zl_skill_idx", str(skill))

        if level:
            c(x, "zl_max_level", str(level))
        if skip_hard:
            c(x, "zl_skip_hard", True)
        save("config_extra.json", x)

        # 重启
        restart(rg=True)

    def restart(account="", hide=True, rg=False, crontab=False, game=False):
        if account:
            x = load("config_multi_account.json")
            c(
                x,
                "multi_account_choice",
                x["multi_account_choice"].split("#")[0] + "#" + str(account),
            )
            save("config_multi_account.json", x)

        x = load("config_debug.json")
        c(
            x,
            "after_require_hook",
            "clear_hook();"
            + ("saveConfig('hideUIOnce','true');" if hide else "")
            + ("extra_mode=[[战略前瞻投资]];" if rg else "")
            + ("crontab_enable_only=1;" if crontab else ""),
        )

        save("config_debug.json", x)
        if game:
            stop(oppid)
            stop(bppid)
        stop()
        start()

    def show():
        subprocess.run(["adb", "connect", serial], capture_output=True)
        print("serial", serial)
        subprocess.run(["scrcpy", "-s", serial], capture_output=True)

    def qq(qq=""):
        if not qq:
            return
        x = load("config_debug.json")
        c(x, "QQ", qq)
        save("config_debug.json", x)

    def normal(qq=None, weekday_only=None, fight=None):
        x = load("config_main.json")
        c(x, "fight_ui", fight or "jm hd ce ls ap pr")
        for i in range(1, 13):
            c(x, f"now_job_ui" + str(i), True)
        c(x, f"now_job_ui8", False)
        c(x, f"crontab_text", "4:00 12:00 20:00")
        c(x, f"auto_recruit0", True)
        c(x, f"auto_recruit4", True)
        c(x, f"auto_recruit5", True)
        c(x, f"auto_recruit6", False)
        save("config_main.json", x)

        x = load("config_debug.json")
        c(x, "max_jmfight_times", "1")
        c(x, "max_login_times_5min", "3")

        if qq:
            c(x, "QQ", f"{qq}#{alias}")
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
        # 一是完成日常任务，二是间隔时间最长可以11小时，提高容错
        c(x, "zero_san_after_fight", True)
        c(x, "max_drug_times_" + str(1) + "day", "99")
        c(x, "max_drug_times_" + str(2) + "day", "99")
        c(x, "max_drug_times_" + str(3) + "day", "1")
        c(x, "max_drug_times_" + str(4) + "day", "1")
        c(x, "max_drug_times_" + str(5) + "day", "1")
        c(x, "max_drug_times_" + str(6) + "day", "1")
        c(x, "max_drug_times_" + str(7) + "day", "1")
        c(x, "enable_log", False)
        # c(x, "enable_disable_lmk", False)
        # c(x, "disable_killacc", False)
        c(x, "enable_restart_package", True)
        c(x, "keepalive_interval", "900")
        c(x, "tap_wait", "")
        save("config_debug.json", x)

        x = load("config_multi_account.json")
        c(x, "multi_account_end_closeotherapp", True)
        c(x, "multi_account_end_closeapp", True)
        c(x, "multi_account_choice", "1-30")
        c(x, "multi_account_enable", True)
        save("config_multi_account.json", x)

    def soft():
        x = load("config_debug.json")
        c(x, "max_login_times_5min", "1")
        save("config_debug.json", x)

    def hard():
        x = load("config_debug.json")
        c(x, "max_login_times_5min", "3")
        save("config_debug.json", x)

    def lmk(value=""):
        print(adb("shell", "cat", "/sys/module/lowmemorykiller/parameters/minfree"))
        if value:
            adb(
                "shell",
                "echo",
                value,
                ">",
                "/sys/module/lowmemorykiller/parameters/minfree",
            )
        return adb("shell", "cat", "/sys/module/lowmemorykiller/parameters/minfree")

    def top():
        return adb("shell", "top", "-s", "rss", "-m", "10", "-n", "1")

    return locals()[f](*args, **kwargs)


m = mode
o = lambda *args, **kwargs: DLT().order(*args, **kwargs)
d = lambda *args, **kwargs: DLT().detail(*args, **kwargs)


def daily(*args, **kwargs):
    for device in daily_device:
        # print("args",args)
        # print("device",deice)
        # mode(device, *args, **kwargs)
        print("==>", device, *args)
        print(mode(device, *args, **kwargs))


def check(key=""):
    user = []
    user2device = {}
    user2idx = {}
    serial2user = {}
    device_account = []
    dlt = DLT()
    for device in daily_device:
        y = mode(device, "load", "config_multi_account.json")
        for i in range(1, 31):
            if (
                not str(y["username" + str(i)]).strip()
                or not str(y["password" + str(i)]).strip()
            ):
                continue
            username = y["username" + str(i)].split("#")[0].strip()
            password = y["password" + str(i)].split("#")[0].strip()[:-1]
            if username in my_account:
                user2device[username] = device
                continue
            serial = dlt.all2serial(" " + password, quiet=True)
            if not serial:
                print("all2serial not found", password)
                continue
            user.append(username)
            user2device[username] = device
            user2idx[username] = i
            serial2user[serial] = username
            device_account.append(serial)
    if key:
        serial = dlt.all2serial(key)
        user = serial2user[serial]
        device = user2device[user]
        # print("serial", serial)
        # print("user", user)
        # exit()
        mode(device, "pic", user + "*分钟")

        return

    dlt_account = []
    dlt_wait_account = []
    for m in dlt.my(raw=True):
        dlt_account.append(m["SerialNo"])
    for m in dlt.my(raw=True, status=13):
        dlt_account.append(m["SerialNo"])
        dlt_wait_account.append(m["SerialNo"])
    for m in dlt.my(raw=True, status=14):
        dlt_account.append(m["SerialNo"])
        dlt_wait_account.append(m["SerialNo"])

    dev_set = set(device_account)
    if len(dev_set) != len(device_account):
        dup = [item for item, count in Counter(device_account).items() if count > 1]
        for serial in dup:
            print(
                user2device[serial2user[serial]],
                serial2user[serial],
                user2idx[serial2user[serial]],
            )

        return

    dlt_set = set(dlt_account)
    assert len(dlt_set) == len(dlt_account)

    waste_set = dev_set - dlt_set
    print("==> total", len(dev_set))

    # print("user2device", user2device)
    # print(
    #     "Counter(user2device.values()).most_common()",
    #     Counter(user2device.values()).most_common(),
    # )
    next_device = Counter(user2device.values()).most_common()[-1][0]

    print("==> waste_set", waste_set)
    for serial in waste_set:
        print(dlt.detail(serial, quiet=True))
    for serial in waste_set:
        user = serial2user[serial]
        print(f"0 m {user2device[user]} user {user} '' --idx={user2idx[user]}")

    insane_set = dlt_set - dev_set
    print("==> insane_set", insane_set)
    for serial in insane_set:
        if serial in dlt_wait_account:
            continue
        print(f"0 m {next_device} user", end=" ")
        print(dlt.detail(serial, quiet=True))

    print("==> over_set")
    over_set = []
    for m in dlt.my(raw=True):
        leave_time = float(m["LeaveTime"][:-2])
        if leave_time < 16:
            serial = m["SerialNo"]
            print(dlt.detail(serial, quiet=True))
            print("0 check " + serial)
            print("0 last --over " + serial)


# every day upload
def edu():
    for username in everyday_upload:
        check(username)
        DLT().submit()


def users():
    daily("user")


def newsession():
    resp = requests.get(
        "http://api.vc.bilibili.com/session_svr/v1/session_svr/new_sessions",
        cookies={"SESSDATA": bilibili_sessdata},
    )
    r = json.loads(resp.text)
    # r = r['data']['session_list']
    r = r["data"]["session_list"]
    ans = []
    for s in r:
        x = {
            "talker_id": s["talker_id"],
            "session_type": s["session_type"],
        }
        content = s["last_msg"]["content"]
        content = json.loads(content)
        content = content["content"]
        server = 0
        p = "(B|b)[^ ]*服"
        if re.search(p, content):
            content = re.sub(p, "", content)
            server = 1
        content = re.sub("账号[:：]*", "", content)
        content = re.sub("密码[:：]*", "", content)
        user = re.search("([^ ]+)\s+([^ ]+)", content)
        if not user:
            continue
        username = user.group(1)
        password = user.group(2)
        x["username"] = username
        x["password"] = password
        x["server"] = server
        ans.append(x)

    return ans


def session():
    cur = deque()
    new = newsession()
    for n in reversed(new):
        for c in cur:
            if c["username"] == n["username"]:
                c["password"] = n["password"]
                c["server"] = n["server"]
                break
        else:
            cur.push(n)


if __name__ == "__main__":
    fire.Fire()
