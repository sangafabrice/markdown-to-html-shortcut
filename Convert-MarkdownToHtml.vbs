Option Explicit
' Launches a hidden PowerShell Core console that executes
' the target Convert-MarkdownToHtml.ps1 script. The Markdown file path
' string is passed to that script as its argument.
' @param MarkdownFilePath The specified markdown file path string.
Dim strCommand, regEx
' The regex that matches the extension of VBScript file.
Set regEx = New RegExp
regEx.Pattern = "\.vbs$"
regEx.IgnoreCase = True
' pwsh.exe is used because the ConvertFrom-Markdown
' is available by default with PowerShell Core.
' Set execution policy to Bypass.
strCommand = "pwsh.exe -nop -ex Bypass -noni -f """
' We change the extension of the current VBScript script
' to the extension of the PowerShell script because
' they have the same base name.
strCommand = strCommand & regEx.Replace(WScript.ScriptFullName, ".ps1") & """ """
' The input Markdown file path.
strCommand = strCommand & WScript.Arguments.Named("MarkdownFilePath") & """"
' Execute the command in a hidden console window.
CreateObject("WScript.Shell").Run strCommand, 0
Set regEx = Nothing