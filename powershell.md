# Powershell笔记

## 参数

​	读屏幕参数：Read-Host

​	写入到屏幕：Wright-Host

## 变量

所有的变量以“$”开头，用“=”来给变量赋值

系统保留字：break | continue | do | else | elseif | filter | foreach | function | if | in | return | switch | until | where | while

指定数据类型[int],[long],[char]....

全局变量：$global:var  即使脚本结束也有效

脚本变量：$script:var  在脚本内有效

私有变量：$private:var 只在当前作用域有效

默认变量在当前作用域有效，其他作用域对它有只读权限。。。（什么鬼）

## 数组

声明一个变量为数组时，需要使用符号"@"，例如：$strUsers=@(""user1","user2","user3) 

数组可以用“+”号连接

哈希表：$age=@{"MaRui"=21;"Lee"=27;"Tom"=53} 

## 逻辑

判断：   

- ​    -eq 判断是否等于(equal)
- -lt 判断时候小于(less than)
- -gt 判断是否大于(greater than)
- -ge 判断是否大于或等于(greater of equal)
- -le 判断是否小于或等于(less or equal)
- -ne 判断是否不等于(no equal)

运算：

-   -and   与
-   -or   或
-   -not   非
-   !   非

swicth语句不用“case”

## 循环

-  for (初值;表达式;赋值语句) {代码}          用变量值控制执行次数
-  foreach (成员变量 in 数组) {代码}         利用迭代执行代码
-  foreach-object          
-  while(表达式) {代码}                              表达式为真时循环执行代码
-  do {代码}  while(表达式)                        类似于while，只是先执行代码，再判断表达式真假
-  do {代码}  until(表达式)                         执行代码，表达式为假时循环

## 函数

​	function "name"("arguments") {"code"} 

​	如果参数为空，函数不会执行

## 筛选器

定义筛选器：

​	Filter(关键字) 筛选器名 (参数) {代码}

对于筛选器，管道符每传入一个数据，代码就执行一次，直至所有数据传入完毕。

内部含有"process"标记代码块的函数，同样具有筛选器的作用。

## WMI对象

在PowerShell中通过以下命令列出WMI对象：

​	get-wmiObject -list -namespace “root\CIMV2″

查看网络：

\$name="."  

\$items = get-wmiObject -class win32_NetworkAdapterConfiguration  -namespace "root\CIMV2" -ComputerName $name | where{$_.IPEnabled -eq “True”}  

 foreach($obj in $items) {  

Write-Host "DHCP Enabled:" \$obj.DHCPEnabled  

Write-Host "IP Address:" $obj.IPAddress  Write-Host "Subnet Mask:" $obj.IPSubnet  

Write-Host "Gateway:" \$obj.DefaultIPGateway  

Write-Host "MAC Address:" $ojb.MACAddress  

} 

读取远程计算机信息：

\$pass= ConvertTo-SecureString "PASSWORD" -AsPlainText -Force
\$mycreds = New-Object System.Management.Automation.PSCredential("IP\USERNAME,$pass")
Get-WmiObject -ComputerName 192.168.0.113 -Credential $mycreds -Class Win32_Bios

## 引号与转义字符

单引号任何情况下都只表示引号内自身的字符。也就是说，单引号内的内容不会进行变量的代换与字符的转义。而在双引号中，则允许进行变量代换和字符转义。在对变量进行代换和字符进行转义的判断上，是由命令最外层的引号决定的。

在单引号中，如果要打印单引号，只需要使单引号重复即可，即，两个单引号会产生一个单引号输出。

​	'I''m \$a'  输出I'm \$a

在单引号中输出双引号可以直接输出，不需要进行转换

在双引号中，如果要输出单引号，也不需要转换，直接打印即可

常用的转义字符串有：

| `'   | 单引号           |
| ---- | ------------- |
| `"   | 双引号           |
| `0   | 空值 NULL       |
| `a   | 报警            |
| `b   | 退格            |
| `f   | 跳页            |
| `n   | 新行            |
| `r   | 换行            |
| `t   | 横向Tab键（水平制表符） |
| `v   | 纵向Tab键（纵向制表符） |

当我们需要输入的命令太长，则可以在命令中合适的地方使用反引号，另起一行接着上条命令书写。

## 管道

​	在PowerShell中有一些专门为管道设计的命令如get-member、sort、measure等，也有一些命令虽然不是为管道专门设计，但却在管道中大放光彩。下面举例说明几个最常用的命令：

**select**

　　在管道中使用select命令，就像在Cmd中使用dir一样常见。不用看select命令的详细语法，你就能写出最常用的select使用方法。如下：

​	这个命令显示当前文件夹中的文件和子文件夹的名字和最后修改日期。

**where**

　　where命令使用来做筛选的，可以简写为?，使用示例如下：

​	这个命令能够只显示出当前文件夹的子文件夹，而不显示文件。

**foreach**

　　foreach可以对传递过来的每个对象进行处理，可以简写为‘%’。使用示例如下：

​	这个命令的结果是输出类似“The size of file 'myScript.ps1' is 1520”这样的信息，每个文件一行。

## 注释

单行注释：#

多行注释：<#...........................#>

## 其他

允许执行ps脚本：powershell -Command Set-ExecutionPolicy RemoteSigned



