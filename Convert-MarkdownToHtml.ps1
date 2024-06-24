#Requires -Version 6.1
<#
.SYNOPSIS
Convert a Markdown file to an HTML file.
.DESCRIPTION
The script convert the specified Markdown file to an HTML file.
.PARAMETER MarkdownFilePath
Specifies the path of an existing .md Markdown file.
.PARAMETER HtmlFilePath
Specifies the path string of the output HTML file.
By default it differs to the path of the input markdown file only by the extension. The parent directory and the base name are the same.
.PARAMETER OverWrite
Specifies that the output file should be overriden.
.EXAMPLE
"Here's the link to the [team session](https://fromthetechlab.blogspot.com)." > .\Readme.md
PS> .\Convert-MarkdownToHtml .\Readme.md
PS> Get-Content .\Readme.html
<p>Here's the link to the <a href="https://fromthetechlab.blogspot.com">team session</a>.</p>
Convert a simple Readme.md file to HTML.
#>
[CmdletBinding()]
Param (
  [Parameter(Mandatory)]
  [ValidatePattern('\.md$')]
  [ValidateScript({Test-Path $_ -PathType Leaf})]
  [string] $MarkdownFilePath,
  [ValidatePattern('\.html?$')]
  [string] $HtmlFilePath = [System.IO.Path]::ChangeExtension($MarkdownFilePath, 'html'),
  [switch] $OverWrite
)
# If the HTML file exists, prompt the user to choose to overwrite or abort.
If (Test-Path $HtmlFilePath -PathType Leaf) {
  If (-not $OverWrite) {
    Do {
      Write-Host "The file `"$HtmlFilePath`" already exists.`nDo you want to overwrite it?`n[Y]es [N]o: " -NoNewline
    } Until (($Answer = Read-Host) -match '((Y(e(s)?)?)|(No?))$')
    If (([console]::InputEncoding.HeaderName -eq 'ibm437' ? ($Answer.Trim() -replace '\W'):$Answer) -in @('No','N')) {
      Exit 1
    }
  }
} ElseIf (Test-Path $HtmlFilePath) {
  Throw "`"$HtmlFilePath`" cannot be overwritten because it is a directory."
}
# Conversion from Markdown to HTML.
(ConvertFrom-Markdown $MarkdownFilePath).Html | Out-File $HtmlFilePath