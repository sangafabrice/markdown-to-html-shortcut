/** Launches a hidden PowerShell Core console that executes
 *  the target Convert-MarkdownToHtml.ps1 script.
*/
function Launcher() { }

/** Represents the command line argument.
 *  @param MarkdownFilePath The specified markdown file path string.
 *  @param RunLink specifies that the shortcut should be run.
*/
function CommandLineArgument() { }
CommandLineArgument.MarkdownFilePath = WSH.Arguments.Named('MarkdownFilePath');
CommandLineArgument.RunLink = WSH.Arguments.Named.Exists('RunLink');

/** Change the extension of this launcher script.
 *  @param extension the extension to replace with.
 *  @return the launcher script string path with the extension specified.
*/
function scriptChangeExtension(extension) {
  return WScript.ScriptFullName.replace(/\.js$/i,extension);
}

/** Represents the constants of the script.
 *  @param SHELL the shell COM object.
 *  @param MESSAGE_BOX_TITLE the message box title.
 *  @param ERROR_MESSAGE the error message type of the MessageBox.
 *  @param EXCLAMATION_MESSAGE the exclamation message type of the MessageBox.
 *  @param YESNO_BUTTON the Yes and No buttons are shown in the MessageBox.
 *  @param OK_BUTTON the OK button is shown in the MessageBox.
 *  @param OK_POPUPRESULT the MessageBox button clicked is OK.
 *  @param NO_POPUPRESULT the MessageBox button clicked is No.
 *  @param PROMPT_OVERWRITE the PowerShell child process output line that is the overwrite prompt message.
 *  @param ERROR_MESSAGE_DELIM the string delimiting the error message thrown by the PowerShell console.
 *  @param TARGET_SCRIPT the path to the shortcut target PowerShell script (.ps1).
*/
function CONSTANT() { }
CONSTANT.SHELL = new ActiveXObject('WScript.Shell');
CONSTANT.MESSAGE_BOX_TITLE = 'Convert to HTML';
CONSTANT.NO_MESSAGE_TIMEOUT = 0;
CONSTANT.ERROR_MESSAGE = 16;
CONSTANT.EXCLAMATION_MESSAGE = 48;
CONSTANT.YESNO_BUTTON = 4;
CONSTANT.OK_BUTTON = 0;
CONSTANT.OK_POPUPRESULT = 1;
CONSTANT.NO_POPUPRESULT = 7;
CONSTANT.PROMPT_OVERWRITE = 'Do you want to overwrite it?';
// Undesired characters are appended as prefix and suffix
// to the error messages due to the difference in Encoding.
// The string separate the polluted characters from the message.
CONSTANT.ERROR_MESSAGE_DELIM = '--';
CONSTANT.TARGET_SCRIPT = scriptChangeExtension('.ps1');

if (CommandLineArgument.RunLink) {
  CONSTANT.SHELL.Run(
    // The shortcut link to this launcher with no RunLink argument.
    '"' + scriptChangeExtension('.lnk') + '" ' +
    // The input Markdown file path.
    '"/MarkdownFilePath:' + CommandLineArgument.MarkdownFilePath + '"',
    0 // Hide the console window.
  );
  WSH.Quit();
}

/** Reprensents the PowerShell console output data from the Standard output.
 *  @param LineCount the rank of the output data line returned.
 *  @param Message the string that will store output text line by line.
*/
function OutputData() { }
OutputData.LineCount = 0;
OutputData.Message = '';

/** Show the message box through a simplified function interface.
 *  @param message the message string in the Message Box.
 *  @param type the type of message 'Exclamation'/'Error'.
 *  @return true if the user clicked on the OK\No button, false otherwise.
*/
function MessageBox(message, type) {
  // Set the default error message to Error message.
  if (type == undefined) {
      type = CONSTANT.ERROR_MESSAGE;
  }
  // If the message notifies of an Error, the message box only displays an OK button.
  // Otherwise, the message box displays an alternative: Yes/No buttons.
  type += type == CONSTANT.ERROR_MESSAGE ? CONSTANT.OK_BUTTON:CONSTANT.YESNO_BUTTON
  popupResult = CONSTANT.SHELL.Popup(message, CONSTANT.NO_MESSAGE_TIMEOUT, CONSTANT.MESSAGE_BOX_TITLE, type)
  return popupResult == CONSTANT.OK_POPUPRESULT || popupResult == CONSTANT.NO_POPUPRESULT
}

/** Represents the handler of the event that occurs when the PowerShell process
 *  redirects outputs to the parent Standard Output stream. This handler observes
 *  when the PowerShell process console prompts the user to overwrite the HTML file.
 *  It then propagate the prompt to the parent process that will show a Message box
 *  with the prompted text and the prompted actions to take Yes/No.
 *  @param pwshExe the PowerShell process or child process.
 *  @param outData the line of text output on the PowerShell console host.
*/
Launcher.StdOutHandler = function(pwshExe, outData) {
  // If the console host output a line, append it to the message text.
  if (outData.length > 0) {
    // Add a new line to the message text when it is not empty.
    if (OutputData.LineCount++ > 0)
      OutputData.Message += '\n';
    // Append the data line to the message text.
    OutputData.Message += outData;
    // Show the Message box to prompt for overwrite when the
    // data line output the overwrite prompt message.
    if (outData == CONSTANT.PROMPT_OVERWRITE) {
      // Get the answer of the user and write it to the process console host.
      var promptAnswer = MessageBox(OutputData.Message, CONSTANT.EXCLAMATION_MESSAGE) ? 'N':'Y';
      pwshExe.StdIn.WriteLine(promptAnswer);
    }
  }
}

/** Represents the handler of the event that occurs when the PowerShell
 *  process redirects errors to the parent Standard Error stream.
 *  Raised exceptions are terminating errors. This handler simply notifies
 *  the user that an error has occurred and displays the error message.
 *  This is why the pwshExe (the child process) parameter is unused.
 *  @param errData the error message object thrown by the powershell process.
*/
Launcher.StdErrHandler = function(errData) {
  if (errData.length > 0) {
    // Remove the polluted characters from the error message data text.
    var delimIndex = errData.indexOf(CONSTANT.ERROR_MESSAGE_DELIM);
    var delimLastIndex = errData.lastIndexOf(CONSTANT.ERROR_MESSAGE_DELIM);
    MessageBox(errData.substring(delimIndex+2, delimLastIndex));
  }
}

/** The method starts the PowerShell console that executes the Target Script.
 *  @param pwshExe the PowerShell process or child process.
*/
Launcher.Start = function(pwshExe) {
  // Wait for the process to complete or throw an error.
  while (!pwshExe.Status && !pwshExe.ExitCode) {
    Launcher.StdOutHandler(pwshExe, pwshExe.StdOut.ReadLine());
  }
  // If the process throws an error.
  if (pwshExe.ExitCode) {
    Launcher.StdErrHandler(pwshExe.StdErr.ReadAll());
  }
}

Launcher.Start(CONSTANT.SHELL.Exec(
  // The runner command. pwsh.exe is used because the
  // ConvertFrom-Markdown is available by default with PowerShell Core.
  // Using the file name only suggests that PowerShell Core
  // installation directory is on the PATH.
  'pwsh.exe -nop -ex ByPass -w Hidden -cwa ' +
  // The execution of the Target Script and its markdown file argument.
  '"try{ & $args[0] -MarkdownFilePath $args[1] }' +
  // Get uniform error messages format by handling them in a catch statement.
  'catch { Write-Error (""' + CONSTANT.ERROR_MESSAGE_DELIM +
  '"" + $_.Exception.Message + ""' + CONSTANT.ERROR_MESSAGE_DELIM + '"") }" ' +
  '"' + CONSTANT.TARGET_SCRIPT + '" ' +
  '"' + CommandLineArgument.MarkdownFilePath + '"'
));

// Release COM object.
CONSTANT.SHELL = null;
delete CONSTANT.SHELL;