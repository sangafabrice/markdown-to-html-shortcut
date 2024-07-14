@cc_on
@set @MAJOR = 0
@set @MINOR = 4
@set @BUILD = 0
@set @REVISION = 0

import System;
import System.IO;
import System.Diagnostics;
import System.Reflection;

[assembly: AssemblyTitle('Convert Markdown to HTML Launcher')]
[assembly: AssemblyProduct('MarkdownToHtml Shortcut')]
[assembly: AssemblyInformationalVersion(@MAJOR + '.' + @MINOR + '.' + @BUILD + '.' + @REVISION)]
[assembly: AssemblyCopyright('\u00A9 2024 sangafabrice')]
[assembly: AssemblyCompany('sangafabrice')]
[assembly: AssemblyVersion(@MAJOR + '.' + @MINOR + '.' + @BUILD + '.' + @REVISION)]

/**
 * Launch a hidden Command Prompt that runs the shortcut link.
 * @param args are the command line arguments.
*/
var args: String[] = Environment.GetCommandLineArgs();

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
// HIDE_CONSOLE conditional compilation symbol for
// specifying that the window style should be Hidden.
@if (@HIDE_CONSOLE)
pwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
@end
Process.Start(pwshStartInfo);