    param(
    [Parameter(ParameterSetName='default',Mandatory=$false)]
    [Parameter(ParameterSetName='file',Mandatory=$true)]
    $Type,
    [Parameter(ParameterSetName='file',Mandatory=$false)]
    [Switch]$File    
    )
    function getNewIp(){
        $name="." 
        $items = get-wmiObject -class win32_NetworkAdapterConfiguration -namespace "root\CIMV2" -ComputerName $name | where{$_.IPEnabled -eq “True”} 
        return $items
    }

    function queryIpChange(){
        $newIp=getNewIp
        if($script:oldIp-ne$newIp){
            Get-Date |Add-Content -Path "$PSScriptRoot\ipLog" -Force
            foreach($obj in $script:oldIp) { 
                "LocalIp:" + $obj.IPAddress + "`r`n" + `
                "LocalGeteway:" + $obj.DefaultIPGateway + "`r`n" + `
                "LocalMac:" + $obj.MACAddress + "`r`n" + `
                "************************************************************************" |Add-Content -Path "$PSScriptRoot\ipLog" -Force
            }
            $script:oldIp=$newIp
            return 1                                   
        }
        else{
            return 0
        }    
    }
    function RemoteDir($hostname,$username,$password,$query){
        try{
            $pass= ConvertTo-SecureString $password -AsPlainText -Force
            $mycreds = New-Object System.Management.Automation.PSCredential($username,$pass)
            Get-WmiObject -ComputerName $hostname -Credential $mycreds -Query $query -ea stop|select name|Set-Content -Path "$PSScriptRoot\$hostname" -Force
            return 1
        }
        catch{
            $hostname |Add-Content -Path "$PSScriptRoot\errLog" -Force
            $error |Add-Content -Path "$PSScriptRoot\errLog" -Force
            "************************************************************************" |Add-Content -Path "$PSScriptRoot\errLog" -Force
            return -1
        }
    }
    $script:oldIp=getNewIp
    $hostFile="$PSScriptRoot\host.txt"
    if($File){
        $query = "Select * from CIM_DataFile where "
        for($i=0;$i -lt $Type.Length;$i++){
            $value = $Type[$i]
            $Type[$i]="(extension = '$value')"
            }
        $query = $query + ($Type -join " OR ")
        while(1-eq1){
            $hostArray=Get-Content $hostFile
            $hostList=@()
            if(!$hostArray){
                Write-Host "over"
                break
            }
            if(queryIpChange -eq 1){
                Write-Host "ipchange,starting..."
                Start-Sleep 5
                foreach($hostComputer in $hostArray){
                    $arr=$hostComputer -split ' '    
                    if((RemoteDir $arr[0] $arr[1] $arr[2] $query) -eq 1){
                        $hostList+=$hostComputer
                        Write-Host $arr[0] + $arr[1] + $arr[2] "deleting..."     
                    }
                    if((RemoteDir $arr[0] $arr[1] $arr[2] $query) -eq -1){
                        Write-Host "error!"
                    }
                }
                $hostFilter=Compare-Object -ReferenceObject $hostArray -DifferenceObject $hostList | Select-Object -ExpandProperty InputObject
                if(!$hostFilter){
                    $hostFilter=$null
                }
                $hostFilter| Set-Content $hostFile -Force #如果成功执行的条目就删除就删除

            }
            Start-Sleep 5
        }
    }
