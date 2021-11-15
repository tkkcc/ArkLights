# 明日方舟速通

明日方舟全日常辅助，适配16:9及以上分辨率，等待耗时极低。

![](./cover.jpg)

[老版视频演示](https://www.bilibili.com/video/BV1DL411t7n2) 
[每日任务速通最速记录35.25s](https://www.bilibili.com/video/BV1eQ4y1C7Ch)

## 特点

1. 支持明日方舟官服与B服。
1. 支持真机、云手机、模拟器及虚拟机（安卓7至11，DPI>=320，分辨率>=720x1280，长宽比>=16:9）。
1. 支持多账号、定时任务、亮屏解锁、区分赤金经验加速技能、结束后通知QQ关闭游戏等。
1. 极低等待耗时，快过手操。免root，热更新。
1. 不支持最高产率基建换班，不支持无人机加速贸易站，不支持赠送寻访，不检测代理失误。

## 安装

下载[明日方舟速通](https://wwa.lanzoui.com/b010qimmf)（密码0000）

## 开发

开发参考[节点精灵开发文档](http://www.nspirit.cn/api)。命令行用户可以使用仓库中的`./0.sh`开发，示例：

```bash
# 先在目标设备打开节点精灵
# 再在本地执行
adb connect z9:5555 # adb连接到目标设备
./0.sh init z9:5555 # 映射本地端口到目标设备
./0.sh saverun # 上传代码并运行
./0.sh stop # 停止
./0.sh release # 发布
```

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
      <td>最速，完成度高，节点精灵实现</td>
   </tr>
   <tr>
   <td><a href="https://github.com/Lancarus/a-mobile-anjian-script-for-arknight">明日再肝</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10006;</td>
      <td>1920x1080 1280x720</td>
      <td>官服B服</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>完成度高，按键精灵实现</td>
   </tr>
   <tr>
   <td><a href="https://www.aistool.com/">月明辅助</a></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10006;</td>
      <td>1280x720</td>
      <td>官服B服日服</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>完成度极高，飞天助手实现</td>
   </tr>
   <tr>
   <td><a href="https://www.bilibili.com/video/BV1ML411x7gz">星火方舟β</a></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>1280x720</td>
      <td>官服B服</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>完成度高</td>
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
   <tr>
   <td><a href="https://github.com/AgainstEntropy/PRTS">PRTS</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>autojs实现</td>
   </tr>
   <tr>
   <td><a href="https://space.bilibili.com/271091178/video">明日计划</a></td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td>官服B服</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>autojs实现</td>
   </tr>
   <tr>
   <td><a href="https://www.bilibili.com/video/BV1kA41147HA">明日方舟托管助手</a></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>节点精灵实现</td>
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
      <td>python实现</td>
   </tr>
   <tr>
   <td><a href="https://github.com/MistEO/MeoAssistance">MeoAssistance</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10006;</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>C++/C#实现</td>
   </tr>
   <tr>
   <td><a href="https://github.com/Konano/arknights-mower">arknights-mower</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>任意</td>
      <td>官服B服</td>
      <td>&#10006;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>python实现</td>
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
   <td><a href="https://github.com/closure-studio/arknights-offline-frontend">可露希尔工作室</a></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
      <td></td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td>&#10004;</td>
      <td></td>
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

### 使用

**不再维护**

按如下说明做好准备后，仅勾选"每日任务速通"后再运行。
1. 用B服新号，比用官服老号快得多。
1. 使用最快网络与设备。
1. 调整干员列表排序使右上角干员可升级。
1. 确保有20个订单。
1. 撤下全部干员。
1. 进入一次信用交易所。
1. 公开招募全部留空。
1. 展示日常任务界面。
1. 登出帐号。

### 理论

[日常任务](http://prts.wiki/w/%E4%BB%BB%E5%8A%A1%E5%88%97%E8%A1%A8)中，排除作战类任务后还剩
```txt
1 进行1次干员强化
1 从信用商店收取1次信用
1 在信用商店中购买任意商品1次
1 完成1次公开招募
2 完成3次公开招募
1 在基建内与干员进行5次增加信赖的互动
1 在基建内与干员进行10次增加信赖的互动
1 累计收取1次制造站的制造产物
1 完成1笔订单
1 完成5笔订单
1 完成10笔订单
2 完成20笔订单
1 让1名干员在宿舍中恢复心情
1 让5名干员在宿舍中恢复心情
2 让10名干员在宿舍中恢复心情
1 访问1次好友的基建
```
其中，左侧一列为印章数，总和19，而完成每日任务需要18，因此只能少做其中一个，排除有后续阶段任务的还剩下
```txt
1 进行1次干员强化
1 从信用商店收取1次信用
1 在信用商店中购买任意商品1次
1 累计收取1次制造站的制造产物
1 访问1次好友的基建
```
排除其中一个使总耗时最低。本工具排除的是访问1次好友的基建，目前第二快记录排除的是进行1次干员强化。实测排除前者快2s左右。

## 任务排序理论

1. 邮件收取：放在首位，触发数据更新，重新登录帐号。
1. 轮次作战：清理智是首要的。但其实也可以放任务收集前做。
1. 访问好友：如果从基建中跳转只能从会客厅走，但线索搜集后还有其他基建任务，所以借鉴速通流程在进入基建前做。
1. 基建收获：在访问好友后做减少加载耗时。需要在换班前做，否则换班后下了班没回宿舍的干员的信赖收不到？也能减少进设施要点两次（一次收获，一次进入）的问题。
1. 指定换班：需要在基建换班前做，否则空位无法补全。
1. 基建换班：需要在制造加速前做，因为无人制造站无法加速。
1. 线索搜集：按钮在右侧，容易被提示遮挡。因此不能在制造加速、访问好友、基建收获前做。
1. 制造加速：需要在退出基建前做。否则需要进出基建两次。但不能在信用购买前做，因为判断信用不足前需要等待制造站提示消失。
1. 副手换人：需要在退出基建前做。在制造加速后做，提供充足的时间使制造站提示消失。
1. 信用购买：唯一的从基建跳转后不需要加载的任务，再跳转时不会出现基建退出提示（但加载时间还有），可以减少一次提示时间。
1. 公招刷新：需要在任务收集前做。
1. 任务收集：需要在结束前做。

## 其他

### 防沉迷

1. [明日方舟防沉迷破解](https://github.com/tanenrumu/Arknights_Anti-addiction_Cheater)
1. [明日方舟屏蔽防沉迷](https://github.com/fhyuncai/Arknights-Anti-addiction)
1. [B站游戏防沉迷不限制](https://github.com/FuckAntiAddiction/BiligameAddictionNotLimited)

### 抓包改包

1. [Darknights](https://github.com/Darknights-dev/Darknights-server)
1. [明日方舟修改器](https://github.com/GhostStar/Arknights-Armada)
1. [明日方舟中间人攻击框架](https://github.com/LXG-Shadow/Arknights-Dolos)
1. [Rhine-DFramwork](https://github.com/Rhine-Department-0xf/Rhine-DFramwork)
