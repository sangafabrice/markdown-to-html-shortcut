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
  .PARAMETER HideConsole
  Specifies that the PowerShell Core console window should be hidden when clicking the shortcut.
  #>
  [CmdletBinding()]
  Param (
    [switch] $NoIcon,
    [switch] $HideConsole
  )

  # Set the extension of the file with base name Convert-MarkdownToHtml and return full path.
  Function Private:Set-ConvertMd2HtmlExtension([string] $Extension) {
    Return "$PSScriptRoot\Convert-MarkdownToHtml$Extension"
  }
  # Store the shortcut link path string which base name is the name as the root module.
  $ShortcutLinkIcon = [Path]::ChangeExtension($PSCommandPath, '.ico')
  # Create the shortcut link to PowerShell Core assembly.
  If (-not (Test-Path ($PwshLink = Set-ConvertMd2HtmlExtension '.lnk') -PathType Leaf)) {
    (New-Object -ComObject WScript.Shell).CreateShortcut($PwshLink) |
    ForEach-Object {
      # pwsh.exe is used because the ConvertFrom-Markdown is available by default with PowerShell Core.
      # Using the file name suggests that the PowerShell Core directory should be on the PATH.
      $_.TargetPath = 'pwsh.exe'
      # The command is partial because it does not include the markdown file path string.
      # The markdown file path string will be input when calling the shortcut link.
      $_.Arguments = '-nop -ep Bypass -noni -nop -w Hidden -f "{0}" -MarkdownFilePath' -f (Set-ConvertMd2HtmlExtension '.ps1')
      $_.IconLocation = $ShortcutLinkIcon
      $_.Description = 'Launch a hidden PowerShell Core console with a custom window icon that executes the MarkdownToHtmlShortcut menu target script Convert-MarkdownToHtml.ps1.'
      $_.Save()
    }
    If (-not (Test-Path $PwshLink -PathType Leaf)) {
      Throw [FileNotFoundException]::New($Null, $PwshLink)
    }
  }
  # Compile the launcher source code to a windows application.
  $Env:Path = "$Env:windir\Microsoft.NET\Framework$(If ([Environment]::Is64BitOperatingSystem) { '64' })\v4.0.30319\;$(($EnvPath = $Env:Path))"
  vbc.exe /nologo /target:winexe $(If ($HideConsole) { '/define:HIDE_CONSOLE' }) /out:$(($ConvertExe = Set-ConvertMd2HtmlExtension '.exe')) $(Set-ConvertMd2HtmlExtension '.vb')
  $Env:Path = $EnvPath
  If (-not (Test-Path $ConvertExe -PathType Leaf)) {
    Throw [FileNotFoundException]::New($Null, $ConvertExe)
  }
  # The arguments to Set-Item and New-Item cmdlets.
  $Arguments = @{
    # The registry key of the command executed by the shortcut.
    Path = 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\ConvertToHtml\Command'
    # %1 is the path to the selected mardown file to convert.
    Value = '"{0}" "%1"' -f $ConvertExe
  }
  # Overwrite the key value if it already exists. Otherwise, create it.
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
  Set-ItemProperty -Path $CommandKey.PSParentPath -Name 'Icon' -Value $ShortcutLinkIcon -Force
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
  Remove-Item 'HKCU:\SOFTWARE\Classes\SystemFileAssociations\.md\shell\ConvertToHtml' -Recurse
}