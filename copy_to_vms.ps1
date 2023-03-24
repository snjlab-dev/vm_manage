#호출예시 
#copy_to_vms.ps1 csv파일 파일위치 vm내의목적지
#copy_to_vms.ps1 .\list.csv .\file\A.dat C:\UTS_v3\

#무조건 csv파일은 명시한다
$csvString = $args[0]
echo $csvString
$list = Import-Csv $csvString

$source = $args[1]
$destination = $args[2]

if ($source -eq 'null'){
    echo 'true'
}


foreach($col in $list) {
    $copy_from = $col.copy_from
    $copy_to = $col.copy_to    
    $apply = $col.apply
    if([boolean]::Parse($apply) -eq $true){
      
        $id = 'Administrator'
        $pass = '1234'
        $name = $col.vmname
        if (($copy_from -eq '') -or ($copy_to -eq '')){
            
            echo $name
            echo $source $destination
            Copy-VMGuestFile -Source $source -Destination $destination -VM $name -LocalToGuest -GuestUser Administrator -GuestPassword "1234" -Force

        }else{
            echo $name
            echo $copy_from $copy_to
            Copy-VMGuestFile -Source $copy_from -Destination $copy_to -VM $name -LocalToGuest -GuestUser Administrator -GuestPassword "1234" -Force
        }
    }
}

