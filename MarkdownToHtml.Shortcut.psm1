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

  # Set the extension of the file with base name Convert-MarkdownToHtml and return full path.
  Function Private:Set-ConvertMd2HtmlExtension([string] $Extension) {
    Return "$PSScriptRoot\Convert-MarkdownToHtml$Extension"
  }
  # Store the shortcut link path string which base name is the name as the root module.
  $ShortcutLinkIcon = [Path]::ChangeExtension($PSCommandPath, '.ico')
  # Store the WScript.EXE full path string.
  $WscriptExe = 'c:\windows\system32\wscript.exe'
  # Store the path to the launcher script.
  $LauncherScript = Set-ConvertMd2HtmlExtension '.js'
  # Create the shortcut link to WSH Wscript application.
  (New-Object -ComObject WScript.Shell).CreateShortcut((Set-ConvertMd2HtmlExtension '.lnk')) |
  ForEach-Object {
    $_.TargetPath = $WscriptExe
    # The command is partial because it does not include the markdown file path string.
    # The markdown file path string will be input when calling the shortcut link.
    $_.Arguments = '//E:jscript "{0}"' -f $LauncherScript
    $_.IconLocation = $ShortcutLinkIcon
    $_.Description = 'Launch a WScript process to run the shortcut link that will set the custom icon.'
    $_.Save()
    $ShortcutLinkPath = $_.FullName
    If (-not (Test-Path $ShortcutLinkPath -PathType Leaf)) {
      Throw [FileNotFoundException]::New(('Cannot find path "{0}" because it does not exist.' -f $ShortcutLinkPath), $ShortcutLinkPath)
    }
  }
  # The arguments to Set-Item and New-Item cmdlets.
  $Arguments = @{
    # The registry key of the command executed by the shortcut.
    Path = 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\cv2html\Command'
    # %1 is the path to the selected mardown file to convert.
    # The script to hide the PowerShell console window is executed in GUI mode (WScript).
    # I keep using WScript.EXE because I cannot use the link directly in the registry.
    Value = '{1} //E:jscript "{0}" /MarkdownPath:"%1" /RunLink' -f $LauncherScript,$WscriptExe
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
  Set-ItemProperty @Arguments -Value $ShortcutLinkIcon
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

# Export the function Convert-MarkdownToHtml.
Get-Item -LiteralPath "$PSScriptRoot\Convert-MarkdownToHtml.ps1" |
ForEach-Object {
  New-Item -Path "Function:\$($_.BaseName)" -Value (Get-Content $_.FullName -Raw)
}