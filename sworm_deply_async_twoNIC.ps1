#.\sworm_deply_async_twoNIC.ps1 -from vm -csv .\deploy_oper.csv -afterProc:True


Param(
    [Parameter(HelpMessage="fuckyou")]
    [switch]$Force,
    
    [Parameter(Mandatory,
    HelpMessage="이미지를 어디서 부터 복사하는지 (template/vm")]
    [ValidateSet("template", "vm")]
    [string]
    $from,

    [Parameter(Mandatory,
    HelpMessage="어떤리스트를 불러올 것인지")]
    [string]
    $csv,

    [Parameter(Mandatory,HelpMessage="vm생성후 후처리를 할 것인지")]
    [switch]$afterProc

)


Write-Output $afterProc
Write-Output $csv
Write-Output '(template/vm):'$from
Write-Output 'after proc' $afterProc


$csvString = $csv
#echo $csvString
$list = Import-Csv $csvString

if ($from -eq "template"){
    foreach($col in $list) {
        $apply = $col.apply
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

        #customization 안함
        #$spec = Get-OSCustomizationSpec -Name $win_spec
 
        ## Windows Customization & Cloen 
        ##nic는 무조건 두개 이므로 where {$_.Position -eq 1} 를 넣는다  -> oscustomization은 포기한다.
        #Get-OSCustomizationNicMapping $spec | where {$_.Position -eq 1} | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $ip1 -SubnetMask 255.255.255.0 -DefaultGateway $gw -Dns 168.126.63.1

        ## Clone VM
        #New-VM -Name $name -Template $template -OSCustomizationSpec $spec -datastore $ds -vmhost $esxi -DiskStorageFormat Thick
        if([boolean]::Parse($apply) -eq $true){
            New-VM -Name $name -Template $template -datastore $ds -vmhost $esxi -DiskStorageFormat Thick -RunAsync
        }
    }
}else{
     foreach($col in $list) {
            $apply = $col.apply
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

            #customization 안함
            #$spec = Get-OSCustomizationSpec -Name $win_spec
 
            ## Windows Customization & Cloen 
            ##nic는 무조건 두개 이므로 where {$_.Position -eq 1} 를 넣는다  -> oscustomization은 포기한다.
            #Get-OSCustomizationNicMapping $spec | where {$_.Position -eq 1} | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $ip1 -SubnetMask 255.255.255.0 -DefaultGateway $gw -Dns 168.126.63.1

            ## Clone VM
            #New-VM -Name $name -Template $template -OSCustomizationSpec $spec -datastore $ds -vmhost $esxi -DiskStorageFormat Thick
            if([boolean]::Parse($apply) -eq $true){
                Write-Output([boolean]::Parse($apply)), $name, $template, $ds, $esxi

                New-VM -Name $name -VM $template -datastore $ds -vmhost $esxi -DiskStorageFormat Thick -RunAsync
            }
        }
}

if($afterProc){
    foreach($col in $list) {
        $apply = $col.apply
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
        if([boolean]::Parse($apply) -eq $true){
            while($true){
            $Exists = get-vm -name $name -ErrorAction SilentlyContinue
                #생성되었으면 네트워크 세팅하고 on 시킴
                If ($Exists){
                    Write-Output "VM $name is there"
                    #$temp = Get-Template $template

                    ## Set Network Adapter 1
                    Get-VM -Name $name | Get-NetworkAdapter | where {$_.Name -eq "Network adapter 1"} | Set-NetworkAdapter -Portgroup $pg -Confirm:$false 
                    
                    if($secondpg){
                        ## Set Network Adapter 2
                        Get-VM -Name $name | Get-NetworkAdapter | where {$_.Name -eq "Network adapter 2"} | Set-NetworkAdapter -Portgroup $secondpg -Confirm:$false
                    }
                    

                    ## set start connected all NIC
                    Get-VM -Name $name | Get-NetworkAdapter | Set-NetworkAdapter  -StartConnected:$true -Confirm:$false

                    ## Set VM Resources
                    Get-VM $name | Set-VM -numcpu $cpu -memoryGB $mem -Confirm:$false
    
                    ## Finish & Poweron VM
                    Write-Host "$name VM Create Done..!!" -ForegroundColor DarkYellow
                    Start-VM -VM $name

            
                    $name = $col.vmname

                    $ip1 = $col.ip1
                    $ip2 = $col.ip2
                    $gw1 = $col.gw1
                    $gw2 = $col.gw2
                    $subnet1 = $col.subnet1
                    $subnet2 = $col.subnet2
    
                    $id = 'Administrator'
                    $pass = '1234'
                    if([int]$args.Count -gt 1){
                        $id = $args[1]
                        $pass = [String]$args[2]
                    }

                    ## VM별 vNIC 추가
                    #New-NetworkAdapter -vm $name -NetworkName $naspg -Type Vmxnet3 -StartConnected -Confirm:$false

                    ## Set Windows 2nd IP
                    #if($vm.GuestId -match 'windows') {
                    $win_nic1 = 'Ethernet0'
                    $win_nic2 = 'Ethernet1' 

                    if($secondpg){
                        $winScript =@"
                        netsh interface ipv4 set address $win_nic1 static $ip1 $subnet1 $gw1
                        netsh interface ipv4 set address $win_nic2 static $ip2 $subnet2 $gw2 
                        netsh interface ipv4 set dns name=$win_nic2 static 168.126.63.1 PRIMARY no
"@                    

                    }else{
                        $winScript =@"
                        netsh interface ipv4 set address $win_nic1 static $ip1 $subnet1 $gw1
                        netsh interface ipv4 set dns name=$win_nic1 static 168.126.63.1 PRIMARY no
"@                    
                    }
                    ## Invoke Script 실행
                    Invoke-VMScript -VM $name -ScriptText $winScript -ScriptType powershell -GuestUser $id -GuestPassword $pass -ToolsWaitSecs 100

                    break
                }
                Else {
                    #Write "VM $name not there"
                    Start-Sleep -Seconds 2
                }
            }
        }
    }

}else{
    return
    break
}




