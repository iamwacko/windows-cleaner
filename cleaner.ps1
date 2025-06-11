$TargetPath  = 'C:\MyTestFolder'

$AdminGroups = @(
  'BUILTIN\Administrators'
)

Write-Host "Scanning $TargetPath ..." -ForegroundColor Cyan

Get-ChildItem -Path $TargetPath -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {
  $filePath = $_.FullName

  try {
    $acl   = Get-Acl -Path $filePath -ErrorAction Stop
    $owner = $acl.Owner
  }
  catch {
    return
  }

  if ($AdminGroups -notcontains $owner) {
    try {
      Remove-Item -LiteralPath $filePath -Force -ErrorAction Stop
      Write-Host "Deleted: $filePath" -ForegroundColor Yellow
    }
    catch {
    }
  }
}

Write-Host "Done." -ForegroundColor Green
