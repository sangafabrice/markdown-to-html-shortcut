/**
 * Use conditional compilation to separate the windows application and the library and
 * set version Major, Minor, Build and Revision using the set directive at one place.
 * @DllBuild symbol specifying that the assembly is a library.
 * @HideConsole symbol specifying that Hidden is the window style.
 * @vMajor carries the the Major part of the version.
 * @vMinor carries the the Minor part of the version.
 * @vBuild carries the the Build part of the version.
 * @vRevision carries the the Revision part of the version.
*/
@cc_on
@set @vMajor = 0
@set @vMinor = 4
@set @vBuild = 0
@set @vRevision = 0

import System;
@if (@DllBuild)
import System.IO;
import System.Diagnostics;
@else
import MarkdownToHtml.Shortcut;
@end
import System.Reflection;
import System.Configuration.Assemblies;

// File and product attributes.
[assembly: AssemblyFileVersionAttribute(@vMajor + '.' + @vMinor + '.' + @vBuild + '.' + @vRevision)]
[assembly: AssemblyInformationalVersionAttribute(@vMajor + '.' + @vMinor + '.' + @vBuild + '.' + @vRevision)]
[assembly: AssemblyCompanyAttribute('sangafabrice')]
[assembly: AssemblyCopyrightAttribute('© 2024 sangafabrice')]
[assembly: AssemblyProductAttribute('MarkdownToHtml Shortcut')]
@if (@DllBuild)
[assembly: AssemblyTitleAttribute('MarkdownToHtml Shortcut Launcher Library')]
// Part of the assembly name.
[assembly: AssemblyVersionAttribute(@vMajor + '.' + @vMinor + '.' + @vBuild + '.' + @vRevision)]

package MarkdownToHtml.Shortcut {

  /**
   * Represents the launcher of the shortcut link.
  */
  class Launcher {
    
    /**
     * Launch a hidden Command Prompt that runs the shortcut link.
     * @param args are the command line arguments.
    */
    static function Start(args: String[]) {
      var pwshStartInfo: ProcessStartInfo = new ProcessStartInfo(
        'cmd.exe',
        String.Format(
          '/d /c """{0}"" ""{1}"""',
          // The link path the same as the process path except the extension.
          Path.ChangeExtension(args[0],'.lnk'),
          // The input markdown file path passed as argument to the link.
          args[1]
        )
      );
      @if (@HideConsole)
      pwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
      @end
      Process.Start(pwshStartInfo);
    }
  }
}
@else
[assembly: AssemblyTitleAttribute('Convert Markdown to HTML Launcher')]

Launcher.Start(Environment.GetCommandLineArgs());
@end