param(
  [string]$Root = (Join-Path $env:LOCALAPPDATA 'DiscordVoiceWidget-V2.1')
)

$ErrorActionPreference = 'Stop'
$packagePath=Join-Path $Root 'package.json'
if(-not (Test-Path -LiteralPath $packagePath)){
  throw ('CensoredFlow nao encontrado em: '+$Root)
}

$localPath=Join-Path $Root 'updater.local.json'
if(Test-Path -LiteralPath $localPath){
  $stamp=Get-Date -Format 'yyyyMMdd-HHmmss-fff'
  Copy-Item -LiteralPath $localPath -Destination (Join-Path $Root ('updater.local.backup-'+$stamp+'.json')) -Force
}

$config=[ordered]@{}
if(Test-Path -LiteralPath $localPath){
  try{
    $current=Get-Content -LiteralPath $localPath -Raw | ConvertFrom-Json
    foreach($p in $current.PSObject.Properties){$config[$p.Name]=$p.Value}
  }catch{}
}

$config.enabled=$true
$config.channel='pilot2'
$config.manifestUrl='https://raw.githubusercontent.com/vargastvonline-maker/discord-voice-widget-updates/main/pilot2/latest/manifest.json'
$config.autoDownload=$true

$json=$config | ConvertTo-Json -Depth 8
[IO.File]::WriteAllText($localPath,$json,[Text.UTF8Encoding]::new($false))

Write-Output 'OK=true'
Write-Output 'channel=pilot2'
Write-Output ('config='+$localPath)
Write-Output 'Reinicie o CensoredFlow para voltar ao canal normal.'
