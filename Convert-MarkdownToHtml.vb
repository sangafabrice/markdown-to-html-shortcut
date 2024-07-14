Option Explicit On

Imports System
Imports System.Reflection
#If DLL_LIBRARY Then
Imports System.Diagnostics
#Else
Imports System.IO
Imports MarkdownToHtml.Shortcut
#End If

<Assembly: AssemblyProduct("MarkdownToHtml Shortcut")>
<Assembly: AssemblyInformationalVersion("0.4.0.0")>
<Assembly: AssemblyCopyright("© 2024 sangafabrice")>
<Assembly: AssemblyCompany("sangafabrice")>
<Assembly: AssemblyVersion("0.4.0.0")>

' DLL_LIBRARY conditional compilation symbol for
' specifying that the assembly is the library.
#If DLL_LIBRARY Then
<Assembly: AssemblyTitle("MarkdownToHtml Shortcut Launcher Library")>

Namespace MarkdownToHtml.Shortcut
  ''' <summary>Represents the launcher of the shortcut link.</summary>
  Public Class Launcher
    ''' <summary>Launch a hidden Command Prompt that runs the shortcut link.</summary>
    ''' <param name="ShortcutPath">The shortcut link path to target shortcut menu script.</param>
    ''' <param name="MarkdownPath">The markdown path input as argument to the shortcut link.</param>
    Public Shared Sub Start(ByVal ShortcutPath As String, ByVal MarkdownPath As String)
      Dim PwshStartInfo As New ProcessStartInfo(
        "cmd.exe",
        String.Format("/d /c """"""{0}"""" """"{1}""""""",ShortcutPath,MarkdownPath)
      )
      ' HIDE_CONSOLE conditional compilation symbol for
      ' specifying that the window style should be Hidden.
      #If HIDE_CONSOLE Then
      PwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden
      #End if
      Process.Start(PwshStartInfo)
    End Sub
  End Class
End Namespace
#Else
<Assembly: AssemblyTitle("Convert Markdown to HTML Launcher")>

Module ConvertMarkdownToHtml
  ''' <summary>Call the Launcher.Start method.</summary>
  ''' <param name="args">The command line arguments.</param>
  Sub Main(ByVal args() As String)
    Launcher.Start(
      Path.ChangeExtension((Environment.GetCommandLineArgs())(0),".lnk"),
      args(0)
    )
  End Sub
End Module
#End If