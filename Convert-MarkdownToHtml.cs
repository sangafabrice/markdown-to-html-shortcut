using System;
using System.IO;
using System.Diagnostics;

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
    PwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
    Process.Start(PwshStartInfo);
  }
}