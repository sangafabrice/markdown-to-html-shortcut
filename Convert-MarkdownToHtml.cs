using System;
using System.IO;
using System.Diagnostics;
using System.Reflection;

[assembly: AssemblyTitle("Convert Markdown to HTML Launcher")]
[assembly: AssemblyProduct("MarkdownToHtml Shortcut")]
[assembly: AssemblyInformationalVersion("0.4.0.0")]
[assembly: AssemblyCopyright("© 2024 sangafabrice")]
[assembly: AssemblyCompany("sangafabrice")]
[assembly: AssemblyVersion("0.4.0.0")]

class ConvertMarkdownToHtml
{
  /// <summary>Launch a hidden Command Prompt that runs the shortcut link.</summary>
  /// <param name="args"> The command line arguments.</param>
  static void Main(string[] args)
  {
    var PwshStartInfo = new ProcessStartInfo(
      "cmd.exe",
      String.Format(
        "/d /c \"\"\"{0}\"\" \"\"{1}\"\"\"",
        // The link path the same as the process path except the extension.
        Path.ChangeExtension((Environment.GetCommandLineArgs())[0],".lnk"),
        // The input markdown file path passed as argument to the link.
        args[0]
      )
    );
    // HIDE_CONSOLE conditional compilation symbol for
    // specifying that the window style should be Hidden.
    #if HIDE_CONSOLE
    PwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
    #endif
    Process.Start(PwshStartInfo);
  }
}