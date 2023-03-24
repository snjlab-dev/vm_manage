

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


echo $Force
echo $from
echo $csv
echo $afterProc