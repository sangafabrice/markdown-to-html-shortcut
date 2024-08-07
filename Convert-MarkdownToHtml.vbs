''' <summary>
''' This script is the launcher and watcher script.
''' As a launcher, it starts the shortcut target PowerShell script
''' with the path of the selected markdown file as an argument.
''' As a watcher, it observes the PowerShell Core output and error
''' text on the hidden console host and displays them in a message box.
''' </summary>
''' <remarks>
''' The Windows Script Host Shell COM object Exec method runs the shortcut
''' target script runner in an intermediate child command prompt process.
''' There is no option to hide that command shell window. However, the Exec
''' method provides an API to interact with the started PowerShell Core process
''' in a way similar to a file. The parent WSH watcher process reads from the
''' PowerShell Core console host the overwrite prompt or the error text and displays
''' them in a message box. In case of the overwrite prompt, the watcher writes back
''' to the console host the user's choice. This method separates the window (handled
''' by the watcher) and the console (implemented in the target script) UI.
''' The second argument of the Windows Script Host Shell COM object Run 
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
''' <param name="RunLink">It specifies to run the shortcut link.</param>
Option Explicit

' The registry key stores the path to the PowerShell Core application.
Const PWSH_KEY = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\pwsh.exe\"

' Read the script execution arguments.
With WScript.Arguments.Named
  Dim strMarkdownPath : strMarkdownPath = .Item("MarkdownPath")
  Dim blnRunLink : blnRunLink = .Exists("RunLink")
End With

If blnRunLink Then
  StartWith strMarkdownPath
  WScript.Quit
End If

' Separate the polluted characters from the informative message.
Const ERROR_MESSAGE_DELIM = "--"
Const MESSAGE_BOX_TITLE = "Convert to HTML"

With New ConversionWatcher
  .StartWith strMarkdownPath
End With

''' <summary>
''' Represents the shortcut target script runner watcher.
''' </summary>
Class ConversionWatcher

  ' The specified Markdown path argument.
  Private strMarkdownPath

  ' The overwrite prompt text as read from the powershell core console host.
  Private strOverwritePromptText

  ' The StartWith method locker to avoid unwanted repetition.
  Private blnStartMethodLocked

  ' <summary>Initialize method locker to false</summary>
  Private Sub Class_Initialize()
    blnStartMethodLocked = False
  End Sub

  ''' <summary>
  ''' Execute the shortcut target script runner and wait for its exit.
  ''' </summary>
  ''' <param name="strMarkdown">The input markdown path argument.</param>
  Sub StartWith(ByVal strMarkdown)
    If blnStartMethodLocked Then
      Exit Sub
    End If
    blnStartMethodLocked = True
    strMarkdownPath = strMarkdown
    strOverwritePromptText = ""
    WaitForExit StartPwshExeWithMarkdown
  End Sub

  ''' <summary>
  ''' Start a PowerShell Core process that runs the shortcut menu target
  ''' script with the markdown path as the argument.
  ''' </summary>
  ''' <remarks>
  ''' The Try-Catch handles the errors thrown by the process. The Standard Error
  ''' Stream encoding is not utf-8. For this reason, it surrounds the message with
  ''' unwanted characters. The error message delimiter constant string separates
  ''' the informative message from noisy characters.
  ''' </remarks>
  ''' <returns>The started process object.</returns>
  Private Function StartPwshExeWithMarkdown()
    With CreateObject("WScript.Shell")
      Set StartPwshExeWithMarkdown = .Exec( _
        GetPathArgument(.RegRead(PWSH_KEY)) & _
        " -nop -ep Bypass -w Hidden -cwa " & _
        """try{ & $args[0] -MarkdownPath $args[1] }" & _
        "catch { Write-Error (""""" & ERROR_MESSAGE_DELIM & _
        """"" + $_.Exception.Message + """"" & ERROR_MESSAGE_DELIM & """"") }"" " & _
        GetPathArgument(ChangeScriptExtension(".ps1")) & " " & _
        GetPathArgument(strMarkdownPath) _
      )
    End With
  End Function

  ''' <summary>
  ''' Observe when the child process exits with or without an error.
  ''' Call the appropriate handler for each outcome.
  ''' </summary>
  ''' <param name="objPwshExe">The PowerShell Core process or child process.</param>
  Private Sub WaitForExit(ByVal objPwshExe)
    ' Wait for the process to complete.
    While objPwshExe.Status = 0 And objPwshExe.ExitCode = 0
      objPwshExe_OutputDataReceived objPwshExe, objPwshExe.StdOut.ReadLine
    Wend
    ' When the process terminated with an error.
    If objPwshExe.ExitCode Then
      objPwshExe_ErrorDataReceived objPwshExe.StdErr.ReadAll
    End If
  End Sub

  ''' <summary>
  ''' Show the overwrite prompt that the child process sends.
  ''' Subsequently, wait for the user's response.
  ''' </summary>
  ''' <remarks>
  ''' It handles the event when the PowerShell Core (child) process
  ''' redirects output to the parent Standard Output stream.
  ''' </remarks>
  ''' <param name="objPwshExe">The sender child process.</param>
  ''' <param name="strOutData">The output text line sent.</param>
  Private Sub objPwshExe_OutputDataReceived(ByVal objPwshExe, ByVal strOutData)
    If Len(strOutData) > 0 Then
      ' Show the message box when the text line is a question.
      ' Otherwise, append the text line to the overall message text variable.
      If Right(RTrim(strOutData), 1) = "?" Then
        strOverwritePromptText = strOverwritePromptText + vbCrLf + strOutData
        ' Write the user's choice to the child process console host.
        objPwshExe.StdIn.Write ShowMessageBox(strOverwritePromptText, vbExclamation)
        ' Optional.
        strOverwritePromptText = ""
      Else
        strOverwritePromptText = strOverwritePromptText + strOutData + vbCrLf
      End If
    End If
  End Sub
End Class

''' <summary>
''' Show the error message that the child process writes on the console host.
''' </summary>
''' <remarks>
''' It handles the event when the child process redirects errors to the parent Standard
''' Error stream. Raised exceptions are terminating errors. Thus, this handler only notifies
''' the user of an error and displays the error message. For this reason, this subroutine
''' does not define the sender objPwshExe object parameter in its signature.
''' </remarks>
''' <param name="strErrData">The error message text.</param>
Sub objPwshExe_ErrorDataReceived(ByVal strErrData)
  If Len(strErrData) > 0 Then
    ' Remove the polluted characters from the error message data text.
    Dim intDelimIndex : intDelimIndex = InStr(strErrData, ERROR_MESSAGE_DELIM)
    Dim intDelimLastIndex : intDelimLastIndex = InStrRev(strErrData, ERROR_MESSAGE_DELIM)
    ShowMessageBox Mid(strErrData, intDelimIndex+2, intDelimLastIndex-intDelimIndex-2), vbCritical
  End If
End Sub

''' <summary>
''' Show a warning message or an error message box.
''' </summary>
''' <remarks>
''' The function does not return anything when the message box is an error.  Thus, when
''' the message is an error, it is recommended to call this function like a subroutine.
''' </remarks>
''' <param name="strMessage">The message text.</param>
''' <param name="varMessageType">The message box type (Warning/Error).</param>
''' <returns>"Yes" or "No" depending on the user's click when the message box is a warning.</returns>
Function ShowMessageBox(ByVal strMessage, ByVal varMessageType)
  ' The default message box type is vbCritical for the error message.
  If varMessageType <> vbExclamation  And varMessageType <> vbCritical Then
  	varMessageType = vbCritical
  End If
  ' The error message box shows the OK button alone.
  Dim varButton : varButton = vbOKOnly
  ' The warning message box shows the alternative Yes or No buttons.
  If varMessageType = vbExclamation Then
    varButton = vbYesNo
  End If
  ' Match the button clicked with its name string.
  Select Case MsgBox(strMessage, varMessageType + varButton, MESSAGE_BOX_TITLE)
    Case vbYes
      ShowMessageBox = "Yes"
    Case vbNo
      ShowMessageBox = "No"
  End Select
End Function

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
    .ShellExecute strLink, " /MarkdownPath:" & GetPathArgument(strMarkdown)
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
      WScript.FullName & " " & GetPathArgument(WScript.ScriptFullName), _
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