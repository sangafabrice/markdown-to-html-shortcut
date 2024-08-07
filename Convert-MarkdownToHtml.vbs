''' <summary>
''' This script is the launcher script.
''' It starts the shortcut target PowerShell script with
''' the path of the selected markdown file as an argument.
''' The script aims to eliminate the flashing console window
''' when the user clicks on the shortcut menu.
''' </summary>
''' <remarks>
''' The Win32_ProcessStartup WIM instance
''' specifies that the window of the command runner is invisible.
''' The Win32_Process WIM Create method executes the target command.
''' The ConvertFrom-Markdown cmdlet requires PowerShell Core (pwsh.exe).
''' The StdRegProv WIM GetStringValue method reads the
''' PowerShell Core path string from the Registry.
''' </remarks>
''' <param name="MarkdownPath">The input markdown path argument.</param>

' The registry key stores the path to the PowerShell Core application.
const HKLM = &H80000002
Const PWSH_KEY = "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\pwsh.exe\"
' Open the application with a hidden window.
Const WINDOW_STYLE_HIDDEN = &Hc

StartWith WScript.Arguments.Named("MarkdownPath")

''' <summary>
''' Start the shortcut target PowerShell script with
''' the path of the selected markdown file as an argument.
''' </summary>
''' <param name="strMarkdown">The input markdown path argument.</param>
Sub StartWith(ByVal strMarkdown)
  Dim objStartInfo: Set objStartInfo = GetObject("winmgmts:Win32_ProcessStartup").SpawnInstance_
  objStartInfo.ShowWindow = WINDOW_STYLE_HIDDEN
  On Error Resume Next
  With GetObject("winmgmts:Win32_Process")
    .Create _
        GetPathArgument(GetPwshPath()) & _
        " -nop -ep Bypass -noni -f " & _
        GetPathArgument(ChangeScriptExtension(".ps1")) & " " & _
        GetPathArgument(strMarkdown),, objStartInfo _
  End With
  Set objStartInfo = Nothing
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
''' Get the PowerShell Core application path from the registry.
''' </summary>
''' <returns>The pwsh.exe full path.</returns>
Function GetPwshPath()
  On Error Resume Next
  GetObject("winmgmts:StdRegProv").GetStringValue HKLM, PWSH_KEY,, GetPwshPath
End Function

''' <summary>
''' Double-quote the file path to make it command-ready.
''' </summary>
''' <param name="strFile">The file path.</param>
''' <returns>A double-quoted path string.</returns>
Function GetPathArgument(ByVal strFile)
  GetPathArgument = """" & strFile & """"
End Function