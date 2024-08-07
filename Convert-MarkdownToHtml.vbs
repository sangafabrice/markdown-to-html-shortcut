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
''' The Shell Automation Service COM grand-child object GetLink
''' lists the properties of the intermediate shortcut link.
''' The shortcut link sets a custom icon for the PowerShell Core
''' window instead of the proprietary icon.
''' The shortcut link lists a partial list of arguments
''' completed with the markdown path string.
''' </remarks>
''' <param name="MarkdownPath">The input markdown path argument.</param>
Option Explicit

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
  Dim strLink: strLink = ChangeScriptExtension(".lnk")
  Dim strLinkDirName, strLinkFileName
  SplitPath strLink, strLinkDirName, strLinkFileName
  With CreateObject("Shell.Application")
    If Not IsLinkReady(.Namespace(strLinkDirName).ParseName(strLinkFileName).GetLink) Then
      Exit Sub
    End If
    .ShellExecute strLink, GetPathArgument(strMarkdown),,, WINDOW_STYLE_HIDDEN
  End With
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
''' Check the link target command.
''' </summary>
''' <param name="objLink">The shortcut link.</param>
''' <returns>True if the target command is as expected, false otherwise.</returns>
Function IsLinkReady(ByVal objLink)
  With objLink
    IsLinkReady = Not StrComp( _
      .Path & " " & .Arguments, _
      CreateObject("WScript.Shell").RegRead(PWSH_KEY) & _
      " -nol -ep Bypass -noni -nop -w Hidden -f " & _
      GetPathArgument(ChangeScriptExtension(".ps1")) & " -MarkdownPath", _
      vbTextCompare _
    )
  End With
End Function

''' <summary>
''' Split the file path into its directory path and name.
''' </summary>
''' <param name="strFilePath">The file full path.</param>
''' <param name="strDirName">The output directory full path string.</param>
''' <param name="strFileName">The output file name.</param>
Sub SplitPath(ByVal strFilePath, strDirName, strFileName)
  Dim intDelimLastIndex: intDelimLastIndex = InStrRev(strFilePath, "\")
  strDirName = Left(strFilePath, intDelimLastIndex - 1)
  strFileName = Right(strFilePath, Len(strFilePath) - intDelimLastIndex)
End Sub

''' <summary>
''' Double-quote the file path to make it command-ready.
''' </summary>
''' <param name="strFile">The file path.</param>
''' <returns>A double-quoted path string.</returns>
Function GetPathArgument(ByVal strFile)
  GetPathArgument = """" & strFile & """"
End Function