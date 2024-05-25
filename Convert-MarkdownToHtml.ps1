#Requires -Version 6.1
<#
.SYNOPSIS
Convert a Markdown file to an HTML file.
.DESCRIPTION
The script convert the specified Markdown file to an HTML file.
.PARAMETER MarkdownFilePath
Specifies the path of an existing .md Markdown file.
.EXAMPLE
@'
**Welcome aboard**

Here's the link to the [team session](https://fromthetechlab.blogspot.com).
'@ > .\Readme.md
PS> (ConvertFrom-Markdown '.\Readme.md' -AsVT100EncodedString).VT100EncodedString
Welcome aboard
Here's the link to the "team session".

PS> (Get-ChildItem Readme.*).Name
Readme.md
PS> .\Convert-MarkdownToHtml .\Readme.md
PS> Get-Content .\Readme.html
<p><strong>Welcome aboard</strong></p>
<p>Here's the link to the <a href="https://fromthetechlab.blogspot.com">team session</a>.</p>

Convert a simple Readme.md file to HTML.
#>
[CmdletBinding()]
Param (
  [Parameter(Mandatory)]
  [ValidateScript({
    # Ensure that the path string carries
    # the information of an existing .md file.
    Test-Path $_ -PathType Leaf
    (Get-Item $_).Extension -ieq '.md'
  })]
  [string] $MarkdownFilePath    
)
# If the HTML file of the same base name and in the same folder as the input Mardown file exists,
# prompt the user to choose to overwrite or cancel the conversion with a message box dialog.
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
# Conversion from Markdown to HTML.
(ConvertFrom-Markdown $MarkdownFilePath).Html |
Out-File $HtmlFilePath