#Requires -Version 6.1

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
  .PARAMETER HideConsole
  Specifies that the PowerShell Core console window should be hidden when clicking the shortcut.
  #>
  [CmdletBinding()]
  Param (
    [switch] $NoIcon,
    [switch] $HideConsole
  )

  # The arguments to Set-Item and New-Item cmdlets.
  $Arguments = @{
    # The registry key of the command executed by the shortcut.
    Path = 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\ConvertToHtml\Command'
    # %1 is the path to the selected mardown file to convert.
    Value = $(
        If ($HideConsole) {
          # The JScript script to hide the PowerShell console window is executed in GUI mode (WScript).
          'wscript.exe //e:jscript "{0}\Convert-MarkdownToHtml.js" /MarkdownFilePath:"%1"'
        } Else {
          'pwsh.exe -nol -ep Bypass -noni -nop -w Hidden -f "{0}\Convert-MarkdownToHtml.ps1" -MarkdownFilePath "%1"'
        }
      ) -f $PSScriptRoot
  }
  # Overwrite the key value if it already exists.
  # Otherwise, create it.
  If (Test-Path $Arguments.Path -PathType Container) {
    Set-Item @Arguments
    $CommandKey = Get-Item $Arguments.Path
  } Else {
    $CommandKey = New-Item @Arguments -Force
  }
  # Set the text on the menu and the icon using the parent of the command key: ConvertToHtml.
  Set-Item -Path $CommandKey.PSParentPath -Value 'Convert to &HTML' -Force
  If ($NoIcon) {
    Remove-ItemProperty -Path $CommandKey.PSParentPath -Name 'Icon' -Force -ErrorAction SilentlyContinue
    Return
  }
  Set-ItemProperty -Path $CommandKey.PSParentPath -Name 'Icon' -Value "$PSScriptRoot\shortcut-icon.ico" -Force
}

Set-Alias Install-MarkdownToHtmlShortcut Set-MarkdownToHtmlShortcut

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
  Remove-Item 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\ConvertToHtml' -Recurse
}