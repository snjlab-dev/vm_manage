#무조건 csv파일은 명시한다


$bOnOff = $args[0]


$csvString = 'D:\snjlab\UTS관련자료\다회선로컬화및 sworm프로젝트\powerCli\async\hostlist.csv'
echo $csvString
$list = Import-Csv $csvString

#on은 wol.exe를 이용해서 host리스트를 순회하면서 킨다
Connect-VIServer -Server 192.168.0.8 -User Administrator@vsphere.local -Password Digtjns123!!

#gracefully setting 을 하지 않는다면 host종료시 vm os 종료를 안시키고 그냥 내려버린다
function set-graceful( [String]$hostname){
    
    $esx = Get-VMHost -Name $hostname
    $auto = Get-View -Id $esx.ExtensionData.ConfigManager.AutoStartManager
    $spec = New-Object VMware.Vim.HostAutoStartManagerConfig
    $spec.Defaults = New-O bject VMware.Vim.AutoStartDefaults
    $spec.Defaults.Enabled = $true
    $spec.Defaults.StopAction = [VMware.Vim.AutoStartAction]::guestShutdown
    $auto.ReconfigureAutostart
}
 

if($bOnOff -eq 'on'){   #//-> 그냥 안쓴다고 보면됨
    echo shuttingOn 
    foreach($col in $list) {
        $hostname = $col.hostname
        $mac = $col.mac
        echo $hostname $mac
        .\wol.exe  $mac
    }
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}elseif ($bOnOff -eq 'off'){
#off는 stop-vmhost를 이용한다
    echo shuttingOff 
    foreach($col in $list) {
        $hostname = $col.hostname
        echo $hostname 
        #set-graceful $hostname
        Stop-VMHost -VMHost $hostname -Force -Confirm:$false
    }
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    
}else{
    echo "please specify  on  or   off"
}
