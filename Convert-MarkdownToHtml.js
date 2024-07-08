import System;
import System.IO;
import System.Diagnostics;

/**
 * Launch a hidden Command Prompt that runs the shortcut link.
*/

/**
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
pwshStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
Process.Start(pwshStartInfo);