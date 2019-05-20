require("util")
require("point")
running=nil

-- all department
la = {}

for i = 1,3 do table.insert(la,point.宿舍[i])end
for i = 1,5 do 	table.insert(la,point.制造站[i])end
for i = 1,3 do table.insert(la,point.发电站[i])end
table.insert(la,'贸易站')
table.insert(la,'会客厅')
table.insert(la,'加工站')
table.insert(la,'办公室')
table.insert(la,'训练室')
table.insert(la,'控制中枢')


path={}
path.base = {
	面板=true,
	start黄框="start黄框",
	进入游戏="进入游戏",
	账号登陆="账号登陆",
	登陆=function()
		local u = '...'
		local p = '...'
		input('账号',u)
		input('密码',p)
		tap('登陆')
	end,
	密码错误=function()
		tap('密码错误')
		stop()
	end,
	删除缓存返回='删除缓存返回',
	登陆认证失效="登陆认证失效",
	今日配给="今日配给",
	签到返回="签到返回",
	公告返回="公告返回",
	撤下干员确认='撤下干员确认',
	其它='返回',
	离开基建确认='离开基建确认',
	理智兑换=function()
		running='理智不足'
		tap('理智兑换')
		return true
	end,
	新手任务='右返回',
	代理失误放弃行动='代理失误放弃行动',
	提示关闭=提示关闭,
}

path.换人=update(path.base,{
		面板="面板基建",
		进驻总览=function()
			local a,b,p
			for index,i in ipairs(la) do
				p = update(path.base,{
						干员选择确认=true,
						面板="面板基建",
						进驻总览=i,
						进驻信息="进驻信息",
						宿舍进驻信息="宿舍进驻信息",
						会客厅进驻信息="会客厅进驻信息",
						控制中枢进驻信息='控制中枢进驻信息',
						清空="清空",
						清空确认="清空确认",
						清空完毕进驻="清空完毕进驻",
					})
				auto(p)
				if index<=4 then
					swip(630,500,0,1900)
					a = 1
				end
				if index==2 then
					--宿舍2
					swip(1000,500,0,-470)
					a=2
				elseif index==3 then
					--宿舍3
					swip(1000,500,0,-1200)
				end
				
				if find('进驻多干员') then b = 5
				else b = 1 end
				for i = a,a+b-1 do
					tap(point.干员选择[i])
				end
				auto(update(path.base,{
							进驻总览=true,
							干员选择确认='干员选择确认',
						}))
			end
			return true
		end
	})

path.订单=update(path.base,{
		订单无 = true,
		进驻总览='贸易站',
		订单='订单',
		订单蓝='订单蓝',
		面板="面板基建",
		进驻信息选中='进驻信息选中',
	})


path.制造站补充=update(path.base,{
		制造站进驻信息='制造站进驻信息',
		制造站设施列表=function()
			for _,i in pairs(unpack(la,4,8)) do
				tap(i)
				tap('制造站最多')
				if find('执行更改') then tap('执行更改') end
			end
			return true
		end,
		进驻总览=point.制造站[1],
		面板="面板基建",
		进驻信息选中='进驻信息选中',
	})
num = #(point.物资筹备)+#(point.芯片搜索)
tick = math.random(1,num)
bl = {true}
repeat_last(bl,num-1)
path.作战=update(path.base,{
		面板=function()
			tap("面板作战")
			
			local true_num=0
			for _,i in pairs(bl) do
				true_num=true_num+(i and 1 or 0)
			end
			if true_num==0 then return true end
			repeat
				tick = (tick%num)+1
			until bl[tick]
			
			if tick <= #(point.物资筹备) then
				tap('作战物资筹备')
				tap(point.物资筹备[tick])
			else
				tap('作战芯片搜索')
				tap(point.芯片搜索[tick-#(point.物资筹备)])
			end
			if not find('作战最后') then return end
			tap('作战最后')
			return auto(update(path.base,{
						代理指挥关='代理指挥关',
						代理指挥开='开始行动蓝',
						开始行动红='开始行动红',
						未能同步到相关战斗记录=function()
							bl[tick]=false
							return true
						end,
						接管作战=function()
							while true do
								sleep(5)
								if not find('接管作战') then
									if find('代理失误放弃行动') then
										bl[tick]=false
									end
									return true
								end
							end
						end,
					}))
		end,
	})
path.任务 = function()
	for _,i in pairs({'日常任务','周常任务'}) do
		local p = update(path.base,{
				面板='面板任务',
				见习任务=i,
				日常任务=i,
				周常任务=i,
			})
		p[i]=true
		auto(p)
		p[i]=nil
		auto(update(p,{
					任务蓝='任务蓝',
					任务黑=true,
					任务灰=true,
				}))
		
		
	end
end

path.取消进驻信息选中=update(path.base,{
		面板="面板基建",
		进驻总览=会客厅,
		进驻信息=true,
		进驻信息选中='进驻信息选中',
		宿舍进驻信息=true,
		宿舍进驻信息选中='宿舍进驻信息选中',
		会客厅进驻信息=true,
		会客厅进驻信息选中='会客厅进驻信息选中',
		控制中枢进驻信息=true,
		控制中枢进驻信息选中='控制中枢进驻信息选中',
	})
path.戳人=function()
	local o
	for _,i in pairs(la) do
		auto(update(path.取消进驻信息选中,{
					进驻总览=i,
				}))
		o= i=='控制中枢' and true or false
		scale(o)
		auto(update(path.base,{
					面板='面板基建',
					信赖圈蓝='信赖圈蓝',
					信赖圈红='信赖圈红',
					进驻总览=true,
				}))
	end
end

path.信用奖励=update(path.base,{
		线索数最大=function()
			--		保证有好友
			auto(update(path.base,{
						面板="面板基建",
						进驻总览='会客厅',
						会客厅进驻信息='线索',
						会客厅传递线索='会客厅传递线索',
						传递线索返回=function()
							sleep()
							tap(point.线索列表[1])
							sleep()
							tap(point.传递列表[2])
							sleep()
							tap('传递线索返回')
							return true
						end,
					}))
		end,
		信用奖励有='信用奖励有',
		信用奖励='信用奖励',
		会客厅进驻信息='线索',
		进驻总览='会客厅',
		信用奖励无=true,
		面板="面板基建",
		会客厅进驻信息选中='会客厅进驻信息选中',
	})
path.信用购买=update(path.base,{
		面板="面板采购中心",
		可露希尔推荐='信用交易所',
		收取信用='收取信用',
		收取信用无=function()
			for _ ,i in pairs(point.信用交易所列表) do
				tap(i)
				if find('购买物品') then tap('购买物品') end
				auto(update(path.base,{
							面板="面板采购中心",
							可露希尔推荐='信用交易所',
							信用交易所=true,
							信用不足=true,
						}))
			end
			return true
		end
	})
--path.公开招募=function()
--		auto(path.base)
--		tap('面板公开招募')
--		auto(update(path.base,{
--				聘用候选人='聘用候选人',
--				开包skip='开包skip',
--				面板=true
--		}))
--	end
path.邮件=update(path.base,{
		面板=function()
			tap('面板邮件')
			sleep()
		end,
		收取全部邮件有='收取全部邮件有',
		收取全部邮件无=true,
	})
path.干员强化=update(path.base,{
		面板='面板干员',
		等级递减='等级递增',
		等级递增=point.干员列表[1],
		EXP='EXP',
		提升等级确认=function()
			tap(point.经验书列表[1])
			tap('提升等级确认')
			return true
		end
	})