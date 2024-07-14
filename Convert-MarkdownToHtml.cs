using System;
using System.Reflection;
#if DLL_LIBRARY
using System.Diagnostics;
#else
using System.IO;
using MarkdownToHtml.Shortcut;
#endif

[assembly: AssemblyProduct("MarkdownToHtml Shortcut")]
[assembly: AssemblyInformationalVersion("0.4.0.0")]
[assembly: AssemblyCopyright("© 2024 sangafabrice")]
[assembly: AssemblyCompany("sangafabrice")]
[assembly: AssemblyVersion("0.4.0.0")]

// DLL_LIBRARY conditional compilation symbol for
// specifying that the assembly is the library.
#if DLL_LIBRARY
[assembly: AssemblyTitle("MarkdownToHtml Shortcut Launcher Library")]

namespace MarkdownToHtml.Shortcut
{  
  /**
   * Represents the launcher of the shortcut link.
  */
  public class Launcher
  {
    /// <summary>Launch a hidden Command Prompt that runs the shortcut link.</summary>
    /// <param name="ShortcutPath">The shortcut link path to target shortcut menu script.</param>
    /// <param name="MarkdownPath">The markdown path input as argument to the shortcut link.</param>
    public static void Start(string ShortcutPath, string MarkdownPath)
    {
      var PwshStartInfo = new ProcessStartInfo(
        "cmd.exe",
        String.Format("/d /c \"\"\"{0}\"\" \"\"{1}\"\"\"",ShortcutPath,MarkdownPath)
      );
      // HIDE_CONSOLE conditional compilation symbol for
      // specifying that the window style should be Hidden.
      #if HIDE_CONSOLE
      PwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
      #endif
      Process.Start(PwshStartInfo);
    }
  }
}
#else
[assembly: AssemblyTitle("Convert Markdown to HTML Launcher")]

class ConvertMarkdownToHtml
{
  /// <summary>Call the Launcher.Start method.</summary>
  /// <param name="args">The command line arguments.</param>
  static void Main(string[] args)
  {
    Launcher.Start(
      Path.ChangeExtension((Environment.GetCommandLineArgs())[0],".lnk"),
      args[0]
    );
  }
}
#endif