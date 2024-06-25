import System;
import System.Text;
import System.IO;
import System.Diagnostics;
import System.Threading;
import System.ComponentModel;
import MarkdownToHtml.Shortcut;

package MarkdownToHtml.Shortcut {

  /** Represents the process launching the hidden
   *  PowerShell Console window that runs the Shortcut Target script.
  */
  class TargetScriptLauncher {

    // Represents the 0-based rank of the PowerShell console host output.
    private static var textLineCount: int = 0;
    // Represents the PowerShell console host output text.
    private static var outputText: StringBuilder  = new StringBuilder();

    /** Represents the string delimiting the error message thrown by the
     *  PowerShell child process. Undesired characters are appended as prefix
     *  and suffix to the error messages due to the difference in Encoding.
     *  The string separate the polluted characters to the desired ones.
    */
    private static var errMessageDelim: String = '--';

    /** Represents the handler of the event that occurs when the PowerShell
     *  process redirects errors to the parent Standard Error stream.
     *  Raised exceptions are terminating errors. This handler simply notifies
     *  the user that an error has occured and displays the error message.
     *  This is why the pwshExe (the child process) parameter is unused.
     *  @param errMessage the error message object thrown by the powershell process.
    */
    private static function PowerShellErrorHandler(pwshExe: Object, errMessage: DataReceivedEventArgs) {
      if (!String.IsNullOrEmpty(errMessage.Data)) {
        // Remove the polluted characters from the error message data text.
        var delimIndex: int = errMessage.Data.indexOf(errMessageDelim);
        var delimLastIndex: int = errMessage.Data.lastIndexOf(errMessageDelim);
        MessageBox.Show(errMessage.Data.Substring(delimIndex+2, delimLastIndex-delimIndex-2));
      }
    }

    /** Represents the handler of the event that occurs when the PowerShell process
     *  redirects outputs to the parent Standard Output stream. This handler observes
     *  when the PowerShell process console prompts the user to overwrite the HTML file.
     *  It then propagate the prompt to the parent process that will show a Message box
     *  with the prompted text and the prompted actions to take Yes/No.
     *  @param pwshExe the PowerShell process or child process.
     *  @param outputTextLine the line of text output on the PowerShell console host.
    */
    private static function PowerShellOutputHandler(pwshExe: Object, outputTextLine: DataReceivedEventArgs) {
      if (!String.IsNullOrEmpty(outputTextLine.Data)) {
        // Build the Message box text.
        outputText.Append((textLineCount++ > 0 ? '\n':'') + outputTextLine.Data);
        // Display the Message Box when the prompt to overwrite file happens.
        // Then send the Message Box answer to the PowerShell console to continue execution.
        if (outputTextLine.Data == 'Do you want to overwrite it?') {
          var pwshExeInput: StreamWriter = pwshExe.StandardInput;
          pwshExeInput.WriteLine(MessageBox.Show(outputText, 'Exclamation') ? 'N':'Y');
          pwshExeInput.Close();
        }
      }
    }

    /** The method starts the PowerShell console that executes the Target Script.
     *  @param commandLineArgs the command line arguments passed to the launcher process.
     *  ** @param launcherExePath the path to the launcher assembly or the PowerShell runner.
     *  ** @param markdownPath the path to the markdown file to convert that is passed to the runner.
    */
    static function Start(commandLineArgs: String[]) {
      var launcherExePath: String = commandLineArgs[0];
      var markdownPath: String = commandLineArgs[1];
      // Build the Target Script runner process: Pwsh.exe .
      var pwshExe:Process = new Process();
      var pwshStartInfo: ProcessStartInfo = new ProcessStartInfo(
        // This suggests that PowerShell Core installation directory is on the PATH.
        'pwsh.exe',
        String.Format(
          '-nop -ex ByPass -cwa ' +
          // The execution of the Target Script and its markdown file argument.
          '"try{{ Import-Module $args[0]; Convert-MarkdownToHtml -MarkdownFilePath $args[1] }}' +
          // Get uniform error messages format by handling them in a catch statement.
          'catch {{ Write-Error (""{2}"" + $_.Exception.Message + ""{2}"") }}" ' +
          '"{0}\\MarkdownToHtml.Shortcut.ConvertCmdlet.dll" "{1}"',
          // This suggests that the path string to the launcher will differ from the
          // PowerShell shortcut target script path only by the file name.
          // They must be located in the same directory.
          Path.GetDirectoryName(launcherExePath),
          markdownPath,
          errMessageDelim
        )
      );
      // Redirect streams to the launcher process.
      pwshStartInfo.RedirectStandardOutput = true;
      pwshStartInfo.RedirectStandardInput = true;
      pwshStartInfo.RedirectStandardError = true;
      pwshStartInfo.CreateNoWindow = true;
      pwshStartInfo.UseShellExecute = false;
      pwshExe.StartInfo = pwshStartInfo;
      // Register stream event handlers.
      pwshExe.EnableRaisingEvents = true;
      pwshExe.add_OutputDataReceived(PowerShellOutputHandler);
      pwshExe.add_ErrorDataReceived(PowerShellErrorHandler);
      // Start the target script.
      pwshExe.Start();
      // Asynchronously read the standard output/error of the child process.
      // This raises OutputDataReceived/ErrorDataReceived events for each line of output.
      pwshExe.BeginOutputReadLine();
      pwshExe.BeginErrorReadLine();
      pwshExe.WaitForExit();
      // End the process.
      pwshExe.Close();
    }
  }
}