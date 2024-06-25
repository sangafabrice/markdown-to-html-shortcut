#Requires -Version 6.1
using namespace System
using namespace System.IO
using namespace System.Text.RegularExpressions
using namespace System.Management.Automation
using namespace System.Management.Automation.Runspaces
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
Specifies that the output file should be overridden.
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
  [ValidateScript({ [File]::Exists($_) })]
  [string] $MarkdownFilePath,
  [ValidatePattern('\.html?$')]
  [string] $HtmlFilePath = [Path]::ChangeExtension($MarkdownFilePath, 'html'),
  [switch] $OverWrite
)
Process {
  # If the HTML file exists, prompt the user to choose to overwrite or abort.
  If ([File]::Exists($HtmlFilePath)) {
    If (-not $OverWrite) {
      Do {
        [console]::Write("The file `"{0}`" already exists.`nDo you want to overwrite it?`n[Y]es [N]o: ", $HtmlFilePath)
      } While (-not [regex]::new('((Y(e(s)?)?)|(No?))$', [RegexOptions]::IgnoreCase).IsMatch(($Answer = [console]::ReadLine())))
      If ([regex]::new('No?', [RegexOptions]::IgnoreCase).IsMatch($Answer)) {
        [environment]::Exit(1)
      }
    }
  } ElseIf ([Directory]::Exists($HtmlFilePath)) {
    Throw "`"$HtmlFilePath`" cannot be overwritten because it is a directory."
  }
  # Create runspace and proxy variable of $MarkdownFilePath.
  $SessionState = [initialsessionstate]::CreateDefault2()
  $SessionState.Variables.Add([SessionStateVariableEntry]::new('MarkdownFilePath', $MarkdownFilePath, ''))
  # Conversion from Markdown to HTML.
  $runspace = [powershell]::Create($SessionState)
  [File]::WriteAllLines($HtmlFilePath, $runspace.AddScript{ (ConvertFrom-Markdown $MarkdownFilePath).Html }.Invoke())
  $runspace.Dispose()
}