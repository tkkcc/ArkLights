# 明日方舟
叉叉助手实现的全日常辅助，[视频演示](https://www.bilibili.com/video/BV1gJ411p7Ck/)。仅支持

- 国服
- 安卓7.1及以下
- 已root
- **1080p分辨率**
- **北京时间**

已测试平台：一加三手机、genymotion模拟器、mumu模拟器  
适用场景：长期挂机（有24小时亮屏手机或虚拟机，不追求最大化基建收益）、短期刷关卡  
QQ群：1009619697

## 功能
- 邮件：收邮件
- 轮次作战：代理指定作战，可选是否吃药和石头。支持1-11
- 基建点击全部：官方一键收
- 换人：按默认序换班
- 基建副手换人：换最低信赖干员
- 制造站加速：无人机加速制造
- 线索接收，信用奖励，访问好友基建：线索相关，包括交流与传递
- 信用收取，信用购买：信用交易所相关
- 公开招募聘用，公开招募刷新：公招相关，非保底四星则刷新
- 任务：收日周常任务奖励

## 安装
1. 下载[开发助手](https://github.com/tkkcc/arknights/releases/download/interpreter/com.xxscript.idehelper_1.2.13_1213.apk)，安装在手机或模拟器上
2. 下载[arknights.xsp](https://github.com/tkkcc/arknights/releases/latest/download/arknights.xsp)，放在/sdcard/xsp/
3. 在开发助手下拉刷新，运行该xsp

## 开发
1. 下载[开发环境](https://github.com/tkkcc/arknights/releases/download/interpreter/CCJCKFIJ_2.0.1.7.exe)与[开发助手](https://github.com/tkkcc/arknights/releases/download/interpreter/com.xxscript.idehelper_1.2.13_1213.apk)，分别安装于windows与android系统
2. 在开发环境中新建项目，与开发助手连通
3. 下载全部代码放在项目的src下，将ui.json链接或复制到ui目录下，在开发环境中启动

## 已知问题
1. 见习任务未完成时，"任务"功能失效，需手动将"任务"前的勾点掉
2. 模拟器通常无法连续工作超过1个月，需辅以外部工具。本人环境为archlinux+i3wm+genymotion，使用[定时任务](https://github.com/tkkcc/dot/tree/master/home/bilabila/.config/systemd/user)+[重启模拟器+截屏通知QQ](https://github.com/tkkcc/dot/blob/master/home/bilabila/bin/scripts/restart_idehelper)方案，只在关卡开放日上线抄作业。该方案能够满足单账号挂机需求，但缺少多账号支持以及快速部署能力。
