<#
.SYNOPSIS
Install the context menu shortcut to convert Markdown files to HTML files.
#>

# The arguments to Set-Item and New-Item cmdlets.
$Arguments = @{
  # The registry key of the command executed by the shortcut.
  Path = 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\ConvertToHtml\Command'
  # The JScript script to hide the PowerShell console window is executed in GUI mode (WScript).
  # %1 is the path to the selected mardown file to convert.
  Value = 'wscript.exe //e:jscript "{0}\Convert-MdToHtml.js" /MarkdownFilePath:"%1"' -f $PSScriptRoot
}
# Overwrite the key value if it already exists.
# Otherwise, create it.
If (Test-Path $Arguments.Path -PathType Container) {
  Set-Item @Arguments
  $CommandKey = Get-Item $Arguments.Path
}
Else {
  $CommandKey = New-Item @Arguments -Force
}
# Set the text on the menu and the icon using the parent of the command key: ConvertToHtml.
Set-Item -Path $CommandKey.PSParentPath -Value 'Convert to &HTML' -Force
Set-ItemProperty -Path $CommandKey.PSParentPath -Name 'Icon' -Value "$PSScriptRoot\shortcut-icon.ico" -Force