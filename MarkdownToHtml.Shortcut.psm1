#Requires -Version 6.1
using namespace System.IO

If (-not $IsWindows) {
  Throw 'Windows platform required. The script can only be executed in a Windows OS.'
}

Function Set-MarkdownToHtmlShortcut {
  <#
  .SYNOPSIS
  Install the context menu shortcut to convert Markdown files to HTML files.
  .DESCRIPTION
  This function creates a context menu shortcut to convert Markdown files to HTML files by setting up the Windows Registry.
  .PARAMETER NoIcon
  Specifies that the shortcut icon should not be configured.
  #>
  [CmdletBinding()]
  Param ([switch] $NoIcon)

  # The arguments to Set-Item and New-Item cmdlets.
  $Arguments = @{
    # The registry key of the command executed by the shortcut.
    Path = 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\cv2html\Command'
    # %1 is the path to the selected mardown file to convert.
    # The script to hide the PowerShell console window is executed in GUI mode (WScript).
    Value = 'C:\Windows\System32\wscript.exe //E:jscript "{0}" /MarkdownPath:"%1"' -f "$PSScriptRoot\Convert-MarkdownToHtml.js"
  }
  # Overwrite the key value if it already exists.
  # Otherwise, create it.
  If (Test-Path $Arguments.Path -PathType Container) {
    $CommandKey = Set-Item @Arguments -PassThru
  } Else {
    $CommandKey = New-Item @Arguments -Force
  }
  # Set the text on the menu and the icon using the parent of the command key: cv2html.
  Set-Item -Path $CommandKey.PSParentPath -Value 'Convert to &HTML' -Force
  $Arguments = @{
    Path = $CommandKey.PSParentPath
    Name = 'Icon'
    Force = $True
  }
  If ($NoIcon) {
    Remove-ItemProperty @Arguments -ErrorAction SilentlyContinue
    Return
  }
  Set-ItemProperty @Arguments -Value ([Path]::ChangeExtension($PSCommandPath, '.ico'))
}

Function Remove-MarkdownToHtmlShortcut {
  <#
  .SYNOPSIS
  Remove the context menu shortcut to convert Markdown files to HTML files.
  .DESCRIPTION
  This function removes the context menu shortcut to convert Markdown files to HTML files by setting up the Windows Registry.
  #>
  [CmdletBinding()]
  Param ()

  # Remove the registry key of the shortcut verb.
  Remove-Item 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\cv2html' -Recurse
}