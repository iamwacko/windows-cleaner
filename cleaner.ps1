<#
.SYNOPSIS
  Attempts to delete all files under a given path whose owner is not an Administrators group,
  without requiring elevation. Files you cannot delete (no permission) are silently skipped.

.PARAMETER TargetPath
  The root folder to scan for files.

.NOTES
  - You do NOT need to run “as Administrator.”
  - You will only delete files you already have permission to delete.
  - Any files you lack permission on are skipped without error.
#>

#region Configuration

# CHANGE THIS to the folder you want to sweep.
$TargetPath = "C:\MyTestFolder"

# List of admin‐type groups whose files we want to preserve.
$AdminGroups = @(
  "BUILTIN\Administrators",
  # add domain or localized names if needed, e.g.
  # "MYDOMAIN\Domain Admins"
)

#endregion

Write-Host "Scanning: $TargetPath" -ForegroundColor Cyan

Get-ChildItem -Path $TargetPath -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {
    $file = $_.FullName

    try {
        # Try to read the ACL and owner. If we have no right, this will throw and skip.
        $acl   = Get-Acl -Path $file -ErrorAction Stop
        $owner = $acl.Owner
    }
    catch {
        # Couldn’t read ACL → skip
        return
    }

    # If owner is NOT in our AdminGroups list, attempt deletion
    if ($AdminGroups -notcontains $owner) {
        try {
            # Attempt to delete. If no permission, this catch will swallow the error.
            Remove-Item -LiteralPath $file -Force -ErrorAction Stop
            Write-Host "Deleted: $file" -ForegroundColor Yellow
        }
        catch {
            # Couldn’t delete (no permission, in use, etc.) → skip
        }
    }
}

Write-Host "Done." -ForegroundColor Green
