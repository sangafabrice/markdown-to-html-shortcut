/** Launches a hidden PowerShell Core console that executes
 *  the target Convert-MarkdownToHtml.ps1 script. The Markdown file path
 *  string is passed to that script as its argument.
 *  @param MarkdownFilePath The specified markdown file path string.
*/

// @param MarkdownFilePath.
var markdownPath = WScript.Arguments.Named('MarkdownFilePath');
// The path to the shortcut target PowerShell script (.ps1).
// We change the extension of the current JScript script to the extension
// of the PowerShell script because they have the same name except the extension.
var targetPwshScript = WScript.ScriptFullName.replace(/\.js$/,'.ps1');
// Constant variables.
var ERROR_MESSAGE = 16;
var EXCLAMATION_MESSAGE = 48;
var YESNO_BUTTON = 4;
var OK_BUTTON = 0;
var OK_POPUPRESULT = 1;
var NO_POPUPRESULT = 7;
var PROMPT_OVERWRITE = 'Do you want to overwrite it?';
// The shell COM object.
var shell = new ActiveXObject('WScript.Shell');
// Represents the string delimiting the error message thrown by
// the PowerShell child process. Undesired characters are appended as prefix
// and suffix to the error messages due to the difference in Encoding.
// The string separate the polluted characters to the desired ones.
var errMessageDelim = '--';
// The rank of the output data line returned.
var lineCount = 0;
// The string that will store output text.
var outMessage = '';
// The runner command. pwsh.exe is used because the
// ConvertFrom-Markdown is available by default with PowerShell Core.
// Using the file name only suggests that PowerShell Core
//  installation directory is on the PATH.
var pwshCommand = 'pwsh.exe -nop -ex ByPass -w Hidden -cwa ' +
  // The execution of the Target Script and its markdown file argument.
  '"try{ & $args[0] -MarkdownFilePath $args[1] }' +
  // Get uniform error messages format by handling them in a catch statement.
  'catch { Write-Error (""' + errMessageDelim +
  '"" + $_.Exception.Message + ""' + errMessageDelim + '"") }" ' +
  '"' + targetPwshScript + '" "' + markdownPath + '"'

/** Show the message box through a simplified function interface.
 *  @param message the message string in the Message Box.
 *  @param type the type of message 'Exclamation'/'Error'.
 *  @return true if the user clicked on the OK\No button, false otherwise.
*/
function MessageBox(message, type) {
  // Set the default error message to Error message.
  if (type == undefined) {
      type = ERROR_MESSAGE;
  }
  // If the message notifies of an Error, the message box only displays an OK button.
  // Otherwise, the message box displays an alternative: Yes/No buttons.
  type += type == ERROR_MESSAGE ? OK_BUTTON:YESNO_BUTTON
  popupResult = shell.Popup(message, 0, 'Convert to HTML', type)
  return popupResult == OK_POPUPRESULT || popupResult == NO_POPUPRESULT
}

/** Represents the handler of the event that occurs when the PowerShell process
 *  redirects outputs to the parent Standard Output stream. This handler observes
 *  when the PowerShell process console prompts the user to overwrite the HTML file.
 *  It then propagate the prompt to the parent process that will show a Message box
 *  with the prompted text and the prompted actions to take Yes/No.
 *  @param pwshExe the PowerShell process or child process.
 *  @param outData the line of text output on the PowerShell console host.
*/
function StdOutHandler(pwshExe, outData) {
  // If the console host output a line, append it to the message text.
  if (outData.length > 0) {
    // Add a new line to the message text when it is not empty.
    if (lineCount++ > 0)
      outMessage += '\n';
    // Append the data line to the message text.
    outMessage += outData;
    // Show the Message box to prompt for overwrite when the
    // data line output the overwrite prompt message.
    if (outData == PROMPT_OVERWRITE) {
      // Get the answer of the user and write it to the process console host.
      var promptAnswer = MessageBox(outMessage, EXCLAMATION_MESSAGE) ? 'N':'Y';
      pwshExe.StdIn.WriteLine(promptAnswer);
    }
  }
}

/** Represents the handler of the event that occurs when the PowerShell
 *  process redirects errors to the parent Standard Error stream.
 *  Raised exceptions are terminating errors. This handler simply notifies
 *  the user that an error has occured and displays the error message.
 *  This is why the pwshExe (the child process) parameter is unused.
 *  @param errData the error message object thrown by the powershell process.
*/
function StdErrHandler(errData) {
  if (errData.length > 0) {
    // Remove the polluted characters from the error message data text.
    var delimIndex = errData.indexOf(errMessageDelim);
    var delimLastIndex = errData.lastIndexOf(errMessageDelim);
    MessageBox(errData.substring(delimIndex+2, delimLastIndex));
  }
}

/** The method starts the PowerShell console that executes the Target Script.
 *  @param pwshExe the PowerShell process or child process.
*/
function StartTargetScript(pwshExe) {
  // Wait for the process to complete or throw an error.
  while (!pwshExe.Status && !pwshExe.ExitCode) {
    StdOutHandler(pwshExe, pwshExe.StdOut.ReadLine());
  }
  // If the process throws an error.
  if (pwshExe.ExitCode) {
    StdErrHandler(pwshExe.StdErr.ReadAll());
  }
}

StartTargetScript(shell.Exec(pwshCommand));