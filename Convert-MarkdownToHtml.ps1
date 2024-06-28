#Requires -Version 6.1
<#
.SYNOPSIS
Convert a Markdown file to an HTML file.
.DESCRIPTION
The script convert the specified Markdown file to an HTML file.
.PARAMETER MarkdownFilePath
Specifies the path of an existing .md Markdown file.
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
  [string] $MarkdownFilePath    
)
# Call this function to show the WPF Message Box. 
Function ShowMessageBox($Text, $Type) {
  # Use the Job to make the added type transient.
  If (Start-Job {
    $DefaultType = 'Error'
    $Type = $Using:Type ?? $DefaultType
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show(
      $Using:Text,
      'Convert Markdown to HTML',
      $Type -eq $DefaultType ? 'OK':'YesNo',
      $Type
    ) -in ('No','OK')
  } | Receive-Job -Wait -AutoRemoveJob) {
    # Exit when the user clicks No or OK.
    Exit 1
  }
}
# If the HTML file of the same base name and in the same folder as the input Markdown file exists,
# prompt the user to choose to overwrite or cancel the conversion with a message box dialog.
If (Test-Path ($HtmlFilePath = [System.IO.Path]::ChangeExtension($MarkdownFilePath, 'html'))) {
  (Test-Path $HtmlFilePath -PathType Leaf) ? (
    ShowMessageBox "The file `"$HtmlFilePath`" already exists.`n`nDo you want to overwrite it?" 'Exclamation'
  ):(
    ShowMessageBox "`"$HtmlFilePath`" cannot be overwritten because it is a directory."
  )
}
Try {
  # Conversion from Markdown to HTML.
  (ConvertFrom-Markdown $MarkdownFilePath).Html | Out-File $HtmlFilePath 
} Catch {
  ShowMessageBox $_.Exception.Message
}
