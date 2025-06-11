<#
.SYNOPSIS
  Delete all files under $TargetPath whose owner is not in $AdminGroups,
  without requiring elevation. Files you can’t touch are skipped.
#>

# ---- CONFIGURATION ----
# Set to the folder you actually want to scan:
$TargetPath  = 'C:\MyTestFolder'

# Owners to preserve. Any other owner == delete attempt:
$AdminGroups = @(
  'BUILTIN\Administrators'
  # Add more if needed, e.g. 'MYDOMAIN\Domain Admins'
)

# ---- SCRIPT LOGIC ----
Write-Host "Scanning $TargetPath ..." -ForegroundColor Cyan

# Enumerate files; skip folders.
Get-ChildItem -Path $TargetPath -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {
  $filePath = $_.FullName

  # 1) Can we read its ACL?
  try {
    $acl   = Get-Acl -Path $filePath -ErrorAction Stop
    $owner = $acl.Owner
  }
  catch {
    # No access to read ACL? skip.
    return
  }

  # 2) If the owner is *not* in our AdminGroups, try delete:
  if ($AdminGroups -notcontains $owner) {
    try {
      Remove-Item -LiteralPath $filePath -Force -ErrorAction Stop
      Write-Host "Deleted: $filePath" -ForegroundColor Yellow
    }
    catch {
      # Cannot delete (locked, no ACL rights, etc.)? skip.
    }
  }
}

Write-Host "Done." -ForegroundColor Green
