<# ::
@@ setlocal disabledelayedexpansion
@@ powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Get-Content -Raw '%~f0')"
@@ if errorlevel 1 pause
@@ exit /b %errorlevel%
#>

echo test
exit 1
