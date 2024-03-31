$Arguments = @{
  Path = 'Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\.md\shell\Convert\Command'
  Value = 'wscript.exe //e:jscript "{0}\Convert-MdToHtml.js" /MarkdownFilePath:"%1"' -f $PSScriptRoot
}
If (Test-Path $Arguments.Path -PathType Container) {
  Set-Item @Arguments
  $CommandKey = Get-Item $Arguments.Path
}
Else {
  $CommandKey = New-Item @Arguments -Force
}
Set-Item -Path $CommandKey.PSParentPath -Value 'Convert to &HTML' -Force
Set-ItemProperty -Path $CommandKey.PSParentPath -Name 'Icon' -Value "$PSScriptRoot\identity.ico" -Force