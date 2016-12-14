# powershell工具集

## powershell学习笔记

powershell.md是我学习powershell脚本编程时的笔记（不断更新中，欢迎交流补充）

## 网络切换检测类（当本机IP发生改变时触发）

### 1、批量远程主机文件扫描

​	功能：批量远程扫描主机指定类型的文件

​	使用方法：

​			命令：netChange.ps1 <-File> <-Type ext1,ext2,ext3....>

​			example: netChange.ps1 -File  -Type txt,doc,ppt

​			同目录下提前写好host.txt，写有需扫描的主机名（IP）及对应的账户密码。

​			每成功扫描一条会删除host.txt	中对应条目。每条格式如下：

​			hostname(ip) username password

​	结果输出：

​			会在同目录下生成以每条主机名命名的结果文件。

​			会生成ipLog文件记录ip变化情况。

​			