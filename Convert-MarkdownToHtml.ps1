<#
.SYNOPSIS
Convert a Markdown file to an HTML file.
.DESCRIPTION
The script converts the specified Markdown file to an HTML file. It shows an overwrite prompt window when the HTML already exists. It also displays thrown error messages in a message box and exits without further operation.
.PARAMETER MarkdownPath
Specifies the path of an existing .md Markdown file.
.PARAMETER HtmlFilePath
Specifies the path of the output HTML file.
By default, the output HTML file has the same parent directory and base name as the input Markdown file.
.PARAMETER OverWrite
Specifies that the output file should be overriden.
.EXAMPLE
"Here's the link to the [team session](https://fromthetechlab.blogspot.com)." > .\Readme.md
PS> .\Convert-MarkdownToHtml .\Readme.md
PS> Get-Content .\Readme.html
<p>Here's the link to the <a href="https://fromthetechlab.blogspot.com">team session</a>.</p>
#>
#Requires -Version 6.1
using namespace System.IO
using namespace System.Windows
[CmdletBinding()]
Param (
  [Parameter(Mandatory, Position=0)]
  [ValidatePattern('\.md$')]
  [ValidateScript({Test-Path $_ -PathType Leaf})]
  [string] $MarkdownPath,
  [Parameter(Position=1)]
  [ValidatePattern('\.html?$')]
  [string] $HtmlPath = [Path]::ChangeExtension($MarkdownPath, '.html'),
  [switch] $OverWrite
)

# Show the specified text message in a WPF Message Box.
# The message type specifies the icon and buttons to display.
Function ShowMessageBox($Message, $HtmlPath, $MessageType) {
  $DefaultType = 'Error'
  Add-Type -AssemblyName PresentationFramework
  If (
    [MessageBox]::Show(
      ($Message -f $HtmlPath),
      'Convert Markdown to HTML',
      # If the message type is Error, the box shows an OK button.
      # If the message type is Exclamation, the box shows a Yes and a No button.
      ($MessageType = $MessageType ?? $DefaultType) -eq $DefaultType ? 'OK':'YesNo',
      $MessageType
    ) -in ('No','OK')
  ) {
    # Exit when the user clicks No or OK.
    Exit 1
  }
}
# Handle exceptions when the HTML file already exists or the output path is a directory.
If (Test-Path $HtmlPath -PathType Leaf) {
  If (-not $OverWrite) {
    ShowMessageBox ('The file "{0}" already exists.' + "`n`nDo you want to overwrite it?") $HtmlPath 'Exclamation'
  }
} ElseIf (Test-Path $HtmlPath) {
  ShowMessageBox '"{0}" cannot be overwritten because it is a directory.' $HtmlPath
}
Try {
  # Conversion from Markdown to HTML.
  (ConvertFrom-Markdown $MarkdownPath).Html | Out-File $HtmlPath
} Catch {
  ShowMessageBox $_.Exception.Message
}