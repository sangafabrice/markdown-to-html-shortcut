@cc_on
@set @MAJOR = 0
@set @MINOR = 4
@set @BUILD = 0
@set @REVISION = 0

import System;
import System.Reflection;
@if (@DLL_LIBRARY)
  import System.Diagnostics;
@else
import System.IO;
import MarkdownToHtml.Shortcut;
@end

[assembly: AssemblyTitle('Convert Markdown to HTML Launcher')]
[assembly: AssemblyProduct('MarkdownToHtml Shortcut')]
[assembly: AssemblyInformationalVersion(@MAJOR + '.' + @MINOR + '.' + @BUILD + '.' + @REVISION)]
[assembly: AssemblyCopyright('\u00A9 2024 sangafabrice')]
[assembly: AssemblyCompany('sangafabrice')]
[assembly: AssemblyVersion(@MAJOR + '.' + @MINOR + '.' + @BUILD + '.' + @REVISION)]

// DLL_LIBRARY conditional compilation symbol for
// specifying that the assembly is the library.
@if (@DLL_LIBRARY)
[assembly: AssemblyTitle('MarkdownToHtml Shortcut Launcher Library')]

package MarkdownToHtml.Shortcut {
  /**
   * Represents the launcher of the shortcut link.
  */
  public class Launcher {
    /**
     * Launch a hidden Command Prompt that runs the shortcut link.
     * @param ShortcutPath is the shortcut link path to target shortcut menu script.
     * @param MarkdownPath is the markdown path input as argument to the shortcut link.
    */
    public static function Start(ShortcutPath: String, MarkdownPath: String) {
      var pwshStartInfo: ProcessStartInfo = new ProcessStartInfo(
        'cmd.exe',
        String.Format('/d /c """{0}"" ""{1}"""',ShortcutPath,MarkdownPath)
      );
      // HIDE_CONSOLE conditional compilation symbol for
      // specifying that the window style should be Hidden.
      @if (@HIDE_CONSOLE)
      pwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
      @end
      Process.Start(pwshStartInfo);
    }
  }
}
@else
[assembly: AssemblyTitle('Convert Markdown to HTML Launcher')]

// The command line arguments.
var args: String[] = Environment.GetCommandLineArgs();
// Call the Launcher.Start method.
Launcher.Start(
  Path.ChangeExtension(args[0],'.lnk'),
  args[1]
);
@end