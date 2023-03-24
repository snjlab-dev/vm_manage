$ScriptFile = "Yourfullpathandrandomfilename.ps1"

$lines = ''

$lines += '$CodeBlock=@'+"'`r`n"

$lines += "insert enc64 content here"+"`r`n"

$lines += "'" + '@'+"`r`n"

set-content -path $ScriptFile -value $lines -encoding ASCII
#여기 까지 $ScriptFile 명으로 ps1 파일이 생성됨 ps1이 이미 있다면 의미없음

$hzpassword="password"
$hzuser="username"
$begintime="00:00"  #//-> 생성된 스케쥴러가 바로 시작될수 있게

$TaskName="Your random task name"

$PowershellFilePath="$PsHome\powershell.exe"

$Argument = "\"""+$PowershellFilePath +"\"" -WindowStyle Normal -NoLogo -NoProfile -Executionpolicy unrestricted -command \"""+$ScriptFile+"\"""
echo ${hzpassword} | schtasks.exe /create /f /tn "$Taskname" /tr $Argument /SC ONCE /SD "12/17/2019" /ST $begintime /RU ${hzuser} /RL HIGHEST

schtasks /Run /TN "$Taskname" /I

#schtasks /create 로 ONCE 실행 생성뒤  /Run 으로 실행