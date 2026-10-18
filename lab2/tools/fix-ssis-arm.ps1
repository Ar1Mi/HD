# Naprawa SSIS (VS 2019 + SSIS Projects 3.15) na Windows 11 ARM w Parallels.
# Problem: DtsDebugHost nie ładuje zadań Control Flow (Execute SQL Task, Script Task):
#   "The task has failed to load" (0xC0010026). Przyczyna (fusion log): zadania wymagają
#   zestawów w wersji 15.0.0.0, przekierowanie na 15.100.0.0 jest, ale CLR szuka plików
#   tylko w SSIS\150\Binn, a leżą one w SSIS\150\Tasks, ...\SQLCommon\150 itd.
# Rozwiązanie: dopisać <codeBase> do generowanego per-użytkownik pliku
#   %LOCALAPPDATA%\Microsoft\Microsoft SQL Server\150\SSIS\ApplocalConfigs\*\DtsDebugHost.exe.config
# Uruchamiać jako zwykły użytkownik (nie administrator), po pierwszym uruchomieniu pakietu w VS.
$ssis = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\CommonExtensions\Microsoft\SSIS\150'
$sc = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\Extensions\Microsoft\SQLCommon\150'
$dir = Join-Path $env:LOCALAPPDATA 'Microsoft\Microsoft SQL Server\150\SSIS\ApplocalConfigs'
$paths = @{}
$dlls = @(Get-ChildItem $ssis -Recurse -Filter *.dll | Where-Object { $_.DirectoryName -notmatch '\\(de|es|fr|it|ja|ko|pt|ru|zh-Hans|zh-Hant|en|pl)$' }) + @(Get-ChildItem $sc -Filter *.dll)
foreach ($f in $dlls) {
  try { $an = [Reflection.AssemblyName]::GetAssemblyName($f.FullName) } catch { continue }
  if ($an.Version.Major -eq 15 -and -not $paths.ContainsKey($an.Name)) { $paths[$an.Name] = @($an.Version.ToString(), $f.FullName) }
}
$ns = 'urn:schemas-microsoft-com:asm.v1'
foreach ($cfg in Get-ChildItem $dir -Recurse -Filter 'DtsDebugHost.exe.config') {
  [xml]$x = Get-Content $cfg.FullName -Raw
  $n = 0
  foreach ($ab in $x.configuration.runtime.assemblyBinding) {
    foreach ($da in $ab.dependentAssembly) {
      $name = $da.assemblyIdentity.name
      if ($paths.ContainsKey($name) -and -not $da.codeBase) {
        $cb = $x.CreateElement('codeBase', $ns)
        $cb.SetAttribute('version', $paths[$name][0])
        $cb.SetAttribute('href', 'file:///' + $paths[$name][1].Replace('\', '/'))
        [void]$da.AppendChild($cb); $n++
      }
    }
  }
  $x.Save($cfg.FullName)
  "{0}: dodano codeBase: {1}" -f $cfg.FullName, $n
}
