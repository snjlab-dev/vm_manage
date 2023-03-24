#nic를 두개 미리 만들어놓고 os customization에서 둘다 받도록 세팅
#무조건 csv파일은 명시한다
$csvString = $args[0]
echo $csvString
$list = Import-Csv $csvString

foreach($col in $list) {
 
    $name = $col.vmname
    $ip1 = $col.ip1
    $ds = $col.datastore
    $template = $col.template
    $esxi = $col.esxi
    $pg = $col.pg
    $gw = $col.gw
    $cpu = $col.cpu
    $mem = $col.mem
    $secondpg = $col.secondpg
 
    #$temp = Get-Template $template


    $name = $col.vmname
    $ip1 = $col.ip1
    $ip2 = $col.ip2
    $gw1 = $col.gw1
    $gw2 = $col.gw2
    $pg1 = $col.pg
    $pg2 = $col.secondpg
    $subnet2 = $col.subnet2
    $name

    get-vm $name | Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -NetworkName $pg1 -Connected:$true -Confirm:$false


    get-vm $name | Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -NetworkName $pg2 -Connected:$true -Confirm:$false
 

    ## VM별 vNIC 추가
    #New-NetworkAdapter -vm $name -NetworkName $naspg -Type Vmxnet3 -StartConnected -Confirm:$false
 
    ## Set Windows 2nd IP
    #if($vm.GuestId -match 'windows') {
    $win_nic1 = 'Ethernet0'
    $win_nic2 = 'Ethernet1' 

$winScript =@"
netsh interface ipv4 set address $win_nic1 static $ip1 255.255.255.0 $gw1
netsh interface ipv4 set address $win_nic2 static $ip2 $subnet2 $gw2 
netsh interface ipv4 set dns name=$win_nic2 static 168.126.63.1 PRIMARY no
"@
 
     $id = 'Administrator'
     $pass = '1234'
    if([int]$args.Count -gt 1){
        $id = $args[1]
        $pass = [String]$args[2]
    }
    ## Invoke Script 실행
    Get-VM $name | Set-VM -numcpu $cpu -memoryGB $mem -Confirm:$false
    Invoke-VMScript -VM $name -ScriptText $winScript -ScriptType powershell -GuestUser $id -GuestPassword $pass -ToolsWaitSecs 100

}

