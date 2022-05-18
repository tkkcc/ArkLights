<h1 align="center"> ArkLights</h1>

<p align="center">
ArkLights is the <b> lightning fast</b> and <b> fully managed</b> Arknights game helper</a>
</p>

<!-- <p align="center">明日方舟速通：明日方舟最速全托管脚本</a> </p> -->
<p align="center">明日方舟速通 —— 最快的明日方舟全托管脚本</a> </p>
<p align="center" >
<a href=https://arklights.vercel.app>使用文档</a>
<!-- <a href=https://www.bilibili.com/read/cv16183975>特色功能介绍</a> -->
<!-- <a href=https://www.bilibili.com/video/BV1LM4y1F7kA>老版日常演示</a> -->
<a href=https://www.bilibili.com/video/BV11T4y1S7cj>999源石锭速刷记录7时21分</a>
<a href=https://www.bilibili.com/video/BV1eQ4y1C7Ch>每日任务速通记录35.25s</a>
</p>
<!-- 本项目使用GPL协议，请遵循[修改开源](https://www.gnu.org/licenses/gpl-faq.zh-cn.html#GPLRequireSourcePostedPublic)与[商用开源](https://www.gnu.org/licenses/gpl-faq.zh-cn.html#GPLCommercially)要求。 -->

![](cover.jpg)

## 特点

1. 支持明日方舟官服与B服。
1. 支持真机、云手机、模拟器及虚拟机（安卓7至12，DPI>=320，分辨率>=720x1280，长宽比>=16:9）。
1. 支持多账号管理、定时启动、亮屏解锁、自适应高产基建换班、QQ通知等。
1. 极低等待耗时，快过手操。全托管，高鲁棒。免root，热更新，免费开源。
1. 支持集成战略刷投资，最速记录7时21分刷999源石锭，平均每小时135个。
1. 不统计掉落，不支持无人机加速贸易站。
1. 不限商用，修改代码后商用必须开源。

## 安装

<!-- ： -->
<!-- [123pan](https://www.123pan.com/s/6MR9-zIv7d) / -->
<!-- [蓝奏云(密码0000)](https://wwa.lanzoui.com/b010qimmf) / -->
<!-- [github release](https://github.com/tkkcc/ArkLights/releases/download/v0.0.18/arknightsspeedrun2.apk)   -->

[下载明日方舟速通](https://arklights.vercel.app/guide.html)

[设备兼容](https://arklights.vercel.app/guide.html#%E8%AE%BE%E5%A4%87%E5%85%BC%E5%AE%B9)

## 开发

1. 参考[懒人精灵3.6.0无障碍模式IDE](http://bbs.lrappsoft.com:8002/forum.php?mod=forumdisplay&fid=2)内文档

1. 数据提取
    ```sh
    # 解包
    ./0.sh extract arknights-hg-1801.apk
    # 提取基建图标数据
    ./0.sh buildingskill
    # 提取公招保底组合
    ./0.sh recruit
    ```

1. 发布
    ```sh
    ./0.sh release
    ```

1. [自建QQ通知服务](https://arklights.vercel.app/guide.html#qq%E9%80%9A%E7%9F%A5%E6%9C%8D%E5%8A%A1%E6%80%8E%E4%B9%88%E8%87%AA%E5%BB%BA)

## 对比

### 板载

<table>
   <tr>
      <td nowrap><b>名称&#12288;&#12288;&#12288;&#12288;&#12288;&#12288;<b></td>
      <td nowrap><b>开源<b></td>
      <td nowrap><b>免费<b></td>
      <td nowrap><b>免root<b></td>
      <td nowrap><b>分辨率<b></td>
      <td nowrap><b>服务器&#12288;<b></td>
      <td nowrap><b>多账号<b></td>
      <td nowrap><b>指定作战<b></td>
      <td nowrap><b>基建换班<b></td>
      <td nowrap><b>备注&#12288;&#12288;&#12288;&#12288;&#12288;&#12288;<b></td>
   </tr>
   <tr>
      <td><a href="https://github.com/tkkcc/arknights">明日方舟速通</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>>=16:9且 >=1280x720</td>
      <td>官服B服</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>完成度高，懒人精灵实现，速度远超其他脚本，自适应换班，群号1009619697</td>
   </tr>
   <tr>
   <td><a href="https://github.com/Lancarus/Liver-Arknights-Tomorrow">明日再肝(还鸽)</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10006;</td>
      <td>1920x1080 1280x720</td>
      <td>官服B服</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>完成度高，按键精灵实现，支持迷迭香等跨站换班体系，自动推图/抄作业，自动打肉鸽，群号684479866、909610797</td>
   </tr>
   <tr>
   <td><a href="https://www.aistool.com/">秋秋辅助</a></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>1280x720</td>
      <td>官服B服日服</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>原月明辅助，完成度高，细节设置多，懒人精灵实现，群号912397682</td>
   </tr>


   <tr>
   <td><a href="https://space.bilibili.com/271091178/video">明日计划</a></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>多种</td>
      <td>多种</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>用户量大，兼容性高，autojs实现，群号852749806、1087079756、942502024</td>
   </tr>
   <tr>


   <tr>
   <td><a href="https://github.com/AgainstEntropy/PRTS">PRTS</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>多种</td>
      <td>多种</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>持续更新，autojs实现，群号741061612</td>
   </tr>

   <td><a href="https://www.bilibili.com/video/BV1ML411x7gz">星火方舟</a></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>1280x720</td>
      <td>官服B服</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>完成度高，autojs实现，群号940133257</td>
   </tr>

   <tr>
   <td><a href="https://www.bilibili.com/video/BV1kA41147HA">明日方舟托管助手</a></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>多种</td>
      <td>多种</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>触动精灵实现</td>
   </tr>

   <tr>
   <td><a href="https://github.com/mslxl/arkayo">arkayo</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td>官服</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10006;</td>
      <td>autojs实现</td>
   </tr>
</table>

### 非板载（需PC算力）

<table>
   <tr>
      <td nowrap ><b>名称&#12288;&#12288;&#12288;&#12288;&#12288;&#12288;<b></td>
      <td nowrap ><b>开源<b></td>
      <td nowrap ><b>免费<b></td>
      <td nowrap ><b>免root<b></td>
      <td nowrap ><b>分辨率<b></td>
      <td nowrap ><b>服务器&#12288;<b></td>
      <td nowrap ><b>多账号<b></td>
      <td nowrap ><b>指定作战<b></td>
      <td nowrap ><b>基建换班<b></td>
      <td nowrap colspan=2><b>备注&#12288;&#12288;&#12288;&#12288;&#12288;&#12288;<b></td>
   </tr>
   <tr>
   <td><a href="https://github.com/ninthDevilHAUNSTER/ArknightsAutoHelper">ArknightsAutoHelper</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10006;</td>
      <td>python实现，战利品统计，自动找最少材料或按材料需求刷，群号757689154</td>
   </tr>
   <tr>
   <td><a href="https://github.com/MistEO/MeoAssistantArknights">MeoAssistantArknights</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>C++实现，完成度高，战利品统计，自适应换班，自动推图/抄作业，自动打肉鸽，群号684479866、672372860</td>
   </tr>
   <tr>
   <td><a href="https://github.com/Konano/arknights-mower">arknights-mower</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>python实现，自定义换班，命令行交互，群号239200680</td>
   </tr>
   <tr>
   <td><a href="https://github.com/MangetsuC/arkHelper">arkHelper</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>python实现，自定义换班，群号648836471</td>
   </tr>
   <tr>
   <td><a href="https://github.com/FlandiaYingman/auto-ark">auto-ark</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>java实现，游戏大更新时自动下载安装</td>
   </tr>
   <tr>
   <td><a href="https://github.com/zqh531500317/arknight-script">arknight-script</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>python实现</td>
   </tr>
   <tr>
   <td><a href="https://github.com/zsppp/Arknights-Sora">Arknights-Sora</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>python实现</td>
   </tr>
   <tr>
   <td><a href="https://github.com/DargonXuan/AutoArknights">AutoArknights</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>python实现</td>
   </tr>
   <tr>
   <td><a href="https://github.com/leng-yue/ai-arkhelper">完全基于深度学习的 明日方舟小助手</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>开发中</td>
   </tr>
</table>

### 云端

<table>
   <tr>
      <td nowrap ><b>名称&#12288;&#12288;&#12288;&#12288;&#12288;&#12288;<b></td>
      <td nowrap ><b>开源<b></td>
      <td nowrap ><b>免费<b></td>
      <td nowrap ><b>免root<b></td>
      <td nowrap ><b>分辨率<b></td>
      <td nowrap ><b>服务器&#12288;<b></td>
      <td nowrap ><b>多账号<b></td>
      <td nowrap ><b>指定作战<b></td>
      <td nowrap ><b>基建换班<b></td>
      <td nowrap colspan=2><b>备注&#12288;&#12288;&#12288;&#12288;&#12288;&#12288;<b></td>
   </tr>
   <tr>
   <td><a href="https://github.com/closure-studio">可露希尔工作室</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>arknights.host已上线，群号450555868</td>
   </tr>
</table>

### 其他辅助平台（2021年7月测试）：

1. 游戏蜂窝（按键精灵）：最新的2个脚本在2021年7月更新，收费，在红手指上试用时等待耗时极高。
1. 触动精灵：最新的2个脚本在2021年5月更新，收费，在红手指720p设备上试用时未正常工作。
1. 自动精灵：脚本较多，免费，完成度普遍较低。

## 每日任务速通

### 记录

- [35.25s](https://www.bilibili.com/video/BV1eQ4y1C7Ch)
- [39.75s！明日方舟每日任务速刷突破40s](https://www.bilibili.com/video/BV1Ky4y1572P)
- [【明日方舟】【TAS】每日任务速通40.48秒](https://www.bilibili.com/video/BV1i44y1k7Nx)
- [44.12秒！再次突破记录！明日方舟每日任务速通再次突破【any%】](https://www.bilibili.com/video/BV1zh411i7ea)
- [1分57秒！【明日方舟】每日任务速通极限再突破！](https://www.bilibili.com/video/BV1P341167fe)

## 其他

### 防沉迷

1. [Arkf](https://github.com/jxr2006/Arkf)
1. [明日方舟屏蔽防沉迷](https://github.com/fhyuncai/Arknights-Anti-addiction)
1. [B站游戏防沉迷不限制](https://github.com/FuckAntiAddiction/BiligameAddictionNotLimited)
1. [明日方舟防沉迷破解](https://github.com/tanenrumu/Arknights_Anti-addiction_Cheater)

### 抓包改包

1. [LocalArknights](https://github.com/zhuzhuxd/LocalArknights)
1. [Darknights](https://github.com/Darknights-dev/Darknights-server)
1. [明日方舟修改器](https://github.com/GhostStar/Arknights-Armada)
1. [明日方舟中间人攻击框架](https://github.com/LXG-Shadow/Arknights-Dolos)
1. [Rhine-DFramwork](https://github.com/Rhine-Department-0xf/Rhine-DFramwork)


