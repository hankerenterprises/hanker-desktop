$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$DownloadURL = 'https://raw.githubusercontent.com/hankerenterprises/hanker-desktop/main/App/HE_AIO.bat?token=GHSAT0AAAAAACOBZSYOOVYGXH4SWKXQ6IA2ZOIDZZQ'
$DownloadURL2 = 'https://raw.githubusercontent.com/hankerenterprises/hanker-desktop/main/App/HE_AIO.bat?token=GHSAT0AAAAAACOBZSYOOVYGXH4SWKXQ6IA2ZOIDZZQ'

$rand = Get-Random -Maximum 99999999
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\Hanker_$rand.cmd" } else { "$env:TEMP\Hanker_$rand.cmd" }

try {
    $response = Invoke-WebRequest -Uri $DownloadURL -UseBasicParsing
}
catch {
    $response = Invoke-WebRequest -Uri $DownloadURL2 -UseBasicParsing
}

$ScriptArgs = "$args "
$prefix = "@REM $rand `r`n"
$content = $prefix + $response
Set-Content -Path $FilePath -Value $content

Start-Process $FilePath $ScriptArgs -Wait

$FilePaths = @("$env:TEMP\Hanker*.cmd", "$env:SystemRoot\Temp\Hanker*.cmd")
foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }
