    param(
    [Parameter(ParameterSetName='default',Mandatory=$false)]
    [Parameter(ParameterSetName='file',Mandatory=$true)]
    $Type,
    [Parameter(ParameterSetName='file',Mandatory=$false)]
    [Switch]$File    
    )

    function ConvertTo-Base64($string) {
        $bytes  = [System.Text.Encoding]::UTF8.GetBytes($string)
        $encoded = [System.Convert]::ToBase64String($bytes)
        return $encoded
    }
 
    function ConvertFrom-Base64($string) {
       $bytes  = [System.Convert]::FromBase64String($string)
       $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
       return $decoded
    }

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

    function wmiQuery($hostname,$username,$password,$query){
        try{
            $pass= ConvertTo-SecureString $password -AsPlainText -Force
            $mycreds = New-Object System.Management.Automation.PSCredential($username,$pass)
            $fileName=ConvertTo-Base64 $hostname
            Get-WmiObject -ComputerName $hostname -Credential $mycreds -Query $query -ea stop|select name|Set-Content -Path "$PSScriptRoot\$fileName" -Force
            return 1
        }
        catch{
            $hostname |Add-Content -Path "$PSScriptRoot\errLog" -Force
            $error |Add-Content -Path "$PSScriptRoot\errLog" -Force
            "************************************************************************" |Add-Content -Path "$PSScriptRoot\errLog" -Force
            return -1
        }
    }

    function dirDataFile(){
        $query = "Select * from CIM_DataFile where "
        #######check param "Type" is arr to get $query#######
        $testArray=@()
        if($Type.GetType() -eq $testArray.GetType()){
            for($i=0;$i -lt $Type.Length;$i++){
                $value = $Type[$i]
                $Type[$i]="(extension = '$value')"
            }
            $query = $query + ($Type -join " OR ") 
        }
        else{
            $query= $query +"extension = '$Type'"
        }
        return $query
    
    }

    function main(){
        if($PSCmdlet.ParameterSetName -eq "default"){
            Write-Host "param error"
            return
        }
        $script:oldIp=getNewIp
        $hostFile="$PSScriptRoot\host.txt"
        #######get param to run different func#######
        if($File){
            $query = dirDataFile
        }
        #######start main loop#######
        while(1-eq1){
            $hostArray=Get-Content $hostFile
            $hostList=@()
            if(!$hostArray){
                Write-Host "over"
                break
            }
            if(queryIpChange -eq 1){
                Write-Host "ipchange,starting..."
                Start-Sleep 7
                foreach($hostComputer in $hostArray){
                    $arr=$hostComputer -split ' '    
                    if((wmiQuery $arr[0] $arr[1] $arr[2] $query) -eq 1){
                        $hostList+=$hostComputer
                        Write-Host $arr[0] "deleting..."     
                    }
                    else{
                        Write-Host "error!"
                    }
                }
                #######if item success than delete it#######
                $hostFilter=Compare-Object -ReferenceObject $hostArray -DifferenceObject $hostList | Select-Object -ExpandProperty InputObject
                if(!$hostFilter){
                    $hostFilter=$null
                }
                $hostFilter| Set-Content $hostFile -Force
            }
            Start-Sleep 5
        }
    }

    main


