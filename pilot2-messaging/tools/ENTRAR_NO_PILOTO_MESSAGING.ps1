param(
  [string]$Root = (Join-Path $env:LOCALAPPDATA 'DiscordVoiceWidget-V2.1')
)

$ErrorActionPreference = 'Stop'

function Compare-Version {
  param([string]$A,[string]$B)
  $pa=@($A.Split('.') | ForEach-Object {[int]$_})
  $pb=@($B.Split('.') | ForEach-Object {[int]$_})
  $n=[Math]::Max($pa.Count,$pb.Count)
  for($i=0;$i -lt $n;$i++){
    $va=if($i -lt $pa.Count){$pa[$i]}else{0}
    $vb=if($i -lt $pb.Count){$pb[$i]}else{0}
    if($va -lt $vb){return -1}
    if($va -gt $vb){return 1}
  }
  return 0
}

$packagePath=Join-Path $Root 'package.json'
if(-not (Test-Path -LiteralPath $packagePath)){
  throw ('CensoredFlow nao encontrado em: '+$Root)
}

$pkg=Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
$version=[string]$pkg.version
if((Compare-Version -A $version -B '2.3.1') -lt 0){
  throw ('Este PC esta em '+$version+'. Atualize primeiro para 2.3.1 no canal pilot2 normal.')
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
$config.channel='pilot2-messaging'
$config.manifestUrl='https://raw.githubusercontent.com/vargastvonline-maker/discord-voice-widget-updates/main/pilot2-messaging/latest/manifest.json'
$config.autoDownload=$true

$json=$config | ConvertTo-Json -Depth 8
[IO.File]::WriteAllText($localPath,$json,[Text.UTF8Encoding]::new($false))

Write-Output ('OK=true')
Write-Output ('version='+$version)
Write-Output ('channel=pilot2-messaging')
Write-Output ('config='+$localPath)
Write-Output 'Reinicie o CensoredFlow para buscar o 2.4.0.'
