#Requires -Version 6.1
[CmdletBinding()]
Param (
  [Parameter(Mandatory)]
  [ValidateScript({
    Test-Path $_ -PathType Leaf
    (Get-Item $_).Extension -ieq '.md'
  })]
  [string] $MarkdownFilePath    
)
If (Test-Path ($HtmlFilePath = [System.IO.Path]::ChangeExtension($MarkdownFilePath, 'html'))) {
  Add-Type -AssemblyName PresentationFramework
  If (([System.Windows.MessageBox]::Show(
    "The file `"$HtmlFilePath`" already exists.`n`nDo you want to overwrite it?",
    'Convert Markdown to HTML',
    4,
    48
  )) -ieq 'No') {
      Return
  }
}
(ConvertFrom-Markdown $MarkdownFilePath).Html |
Out-File $HtmlFilePath