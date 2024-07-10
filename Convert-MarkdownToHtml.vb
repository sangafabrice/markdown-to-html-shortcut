Option Explicit On

Imports System
Imports System.IO
Imports System.Diagnostics
Imports System.Reflection

' File and product attributes.
<Assembly: AssemblyFileVersion("0.4.0.0")>
<Assembly: AssemblyInformationalVersion("0.4.0.0")>
<Assembly: AssemblyCompany("sangafabrice")>
<Assembly: AssemblyCopyright("© 2024 sangafabrice")>
<Assembly: AssemblyProduct("MarkdownToHtml Shortcut")>
<Assembly: AssemblyTitle("Convert Markdown to HTML Launcher")>

Module MarkdownToHtmlShortcut
  ''' <summary>Launch a hidden Command Prompt that runs the shortcut link.</summary>
  ''' <param name="args"> The command line arguments.</param>
  Sub Main(ByVal args() As String)
    ' The input markdown file path passed as argument to the link.
    Dim MarkdownPath As String = args(0)
    ' The link path the same as the process path except the extension.
    Dim LinkPath As String = Path.ChangeExtension((Environment.GetCommandLineArgs())(0),".lnk")
    Dim PwshStartInfo As New ProcessStartInfo(
      "cmd.exe",
      String.Format("/d /c """"""{0}"""" """"{1}""""""",LinkPath,MarkdownPath)
    )
    #If HIDE_CONSOLE Then
    PwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden
    #End if
    Process.Start(PwshStartInfo)
  End Sub
End Module