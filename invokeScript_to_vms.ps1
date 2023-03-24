
#nic를 두개 미리 만들어놓고 os customization에서 둘다 받도록 세팅
#무조건 csv파일은 명시한다


#컨펌없이 삭제 Remove-Item foldertodelete -Recurse -Force             invoke로 제어 할때 뒤에 컨펌 필요 없음 -Confirm:$false  **************
#//->폴더뿐만아니라 파일도 컨펌없이 해야할때 있음
#폴더 통채로 'Robocopy.exe c:\UTS_v3 c:\snjlab\uts_v3 /E'


$csvString = $args[0]
echo $csvString
$list = Import-Csv $csvString

$winScript = $args[1]

foreach($col in $list) {
 
    $name = $col.vmname

    ## VM별 vNIC 추가
    #New-NetworkAdapter -vm $name -NetworkName $naspg -Type Vmxnet3 -StartConnected -Confirm:$false
 
    ## Set Windows 2nd IP
    #if($vm.GuestId -match 'windows') {
    $win_nic1 = 'Ethernet0'
    $win_nic2 = 'Ethernet1' 

 
    $id = 'Administrator'
    $pass = '1234'
    echo $name
    Invoke-VMScript -VM $name -ScriptText $winScript -ScriptType powershell -GuestUser $id -GuestPassword $pass -ToolsWaitSecs 100  

}

