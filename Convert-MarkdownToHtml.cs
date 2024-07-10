/**
 * Use conditional compilation HIDE_CONSOLE symbol for
 * specifying that Hidden is the window style.
*/
using System;
using System.IO;
using System.Diagnostics;
using System.Reflection;

// File and product attributes.
[assembly: AssemblyFileVersion("0.4.0.0")]
[assembly: AssemblyInformationalVersion("0.4.0.0")]
[assembly: AssemblyCompany("sangafabrice")]
[assembly: AssemblyCopyright("© 2024 sangafabrice")]
[assembly: AssemblyProduct("MarkdownToHtml Shortcut")]
[assembly: AssemblyTitle("Convert Markdown to HTML Launcher")]

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
    #if HIDE_CONSOLE
    PwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
    #endif
    Process.Start(PwshStartInfo);
  }
}