''' <summary>
''' This script is the launcher script.
''' It starts the shortcut target PowerShell script with
''' the path of the selected markdown file as an argument.
''' The script aims to eliminate the flashing console window
''' when the user clicks on the shortcut menu.
''' </summary>
''' <remarks>
''' The last argument of the Shell Automation Service COM object ShellExecute
''' method specifies that the window of the command runner is invisible.
''' The ConvertFrom-Markdown cmdlet requires PowerShell Core (pwsh.exe).
''' The Windows Script Host Shell COM object RegRead method reads the
''' PowerShell Core path string from the Registry.
''' </remarks>
''' <param name="MarkdownPath">The input markdown path argument.</param>

' The registry key stores the path to the PowerShell Core application.
Const PWSH_KEY = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\pwsh.exe\"
' Open the application with a hidden window.
Const WINDOW_STYLE_HIDDEN = 0

StartWith WScript.Arguments.Named("MarkdownPath")

''' <summary>
''' Start the shortcut target PowerShell script with
''' the path of the selected markdown file as an argument.
''' </summary>
''' <param name="strMarkdown">The input markdown path argument.</param>
Sub StartWith(ByVal strMarkdown)
  CreateObject("Shell.Application").ShellExecute _
    CreateObject("WScript.Shell").RegRead(PWSH_KEY), _
    "-nop -ep Bypass -noni -f " & _
    GetPathArgument(ChangeScriptExtension(".ps1")) & " " & _
    GetPathArgument(strMarkdown),,, WINDOW_STYLE_HIDDEN
End Sub

''' <summary>
''' Change the launcher script path extension.
''' </summary>
''' <remarks>
''' This change implies that the launcher script and the resulting
''' path file reside in the same directory and have the same name.
''' </remarks>
''' <param name="strExtension">The new extension.</param>
''' <returns>A file path with the new extension.</returns>
Function ChangeScriptExtension(ByVal strExtension)
  With New RegExp
    .Pattern = "\.vbs$"
    .IgnoreCase = True
    ChangeScriptExtension = .Replace(WScript.ScriptFullName, strExtension)
  End With
End Function

''' <summary>
''' Double-quote the file path to make it command-ready.
''' </summary>
''' <param name="strFile">The file path.</param>
''' <returns>A double-quoted path string.</returns>
Function GetPathArgument(ByVal strFile)
  GetPathArgument = """" & strFile & """"
End Function