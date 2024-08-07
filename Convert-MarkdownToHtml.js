/**
 * This script is the launcher and watcher script.
 * As a launcher, it starts the shortcut target PowerShell script
 * with the path of the selected markdown file as an argument.
 * As a watcher, it observes the PowerShell Core output and error
 * text on the hidden console host and displays them in a message box.
 * The Windows Script Host Shell COM object Exec method runs the shortcut
 * target script runner in an intermediate child command prompt process.
 * There is no option to hide that command shell window. However, the Exec
 * method provides an API to interact with the started PowerShell Core process
 * in a way similar to a file. The parent WSH watcher process reads from the
 * PowerShell Core console host the overwrite prompt or the error text and displays
 * them in a message box. In case of the overwrite prompt, the watcher writes back
 * to the console host the user's choice. This method separates the window (handled
 * by the watcher) and the console (implemented in the target script) UI.
 * The second argument of the Windows Script Host Shell COM object Run 
 * method specifies that the window of the command runner is invisible.
 * The ConvertFrom-Markdown cmdlet requires PowerShell Core (pwsh.exe).
 * The Windows Script Host Shell COM object RegRead method reads the
 * PowerShell Core path string from the Registry. 
 * The Windows Script Host Shell COM object CreateShortcut method
 * creates the intermediate shortcut link in the TEMP folder.
 * The shortcut link sets a custom icon for the PowerShell Core
 * window instead of the proprietary icon.
 * The shortcut link lists a partial list of arguments
 * completed with the markdown path string.
 * The FileSystem COM object creates and delete de shortcut link.
 */

/**
 * The registry key stores the path to the PowerShell Core application.
 * @constant {string}
 */
var PWSH_KEY = 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\pwsh.exe\\';
/** @constant {string} */
var TEMP_PATH = (new ActiveXObject('WScript.Shell')).ExpandEnvironmentStrings('%TEMP%')

/**
 * Read the script execution arguments.
 * @typedef {object} args
 * @param {string} MarkdownPath is the input markdown path argument.
 * @param {boolean} RunLink specifies to run the shortcut link.
 * @param {string} LinkName is the name of the link restarting the launcher.
 */
var args = {
  MarkdownPath: WSH.Arguments.Named('MarkdownPath'),
  RunLink: WSH.Arguments.Named.Exists('RunLink')
}

if (args.RunLink) {
  StartWith(args.MarkdownPath);
  WSH.Quit();
}

/** @property @memberof args */
args.LinkName = WSH.Arguments.Named('LinkName')

/**
 * Represents the markdown conversion message box.
 * @typedef {object} MessageBox
 * @property {number} EXCLAMATION specifies that the dialog shows a warning message.
 */
var MessageBox = (function() {
  /** @private @constant {number} */
  var MESSAGE_BOX_TITLE = 'Convert to HTML';
  /** @private @constant {number} */
  var NO_MESSAGE_TIMEOUT = 0;
  /** @private @constant {number} */
  var YESNO_BUTTON = 4;
  /** @private @constant {number} */
  var OK_BUTTON = 0;
  /** @private @constant {number} */
  var YES_POPUPRESULT = 6;
  /** @private @constant {number} */
  var NO_POPUPRESULT = 7;
  /** @private @constant {number} */
  var ERROR_MESSAGE = 16;
  /** @private @constant {number} */
  var WARNING_MESSAGE = 48;

  /** @typedef MessageBox */
  var MessageBox = { };

  /** @public @static @readonly @property {number} */
  MessageBox.WARNING = WARNING_MESSAGE;
  // Object.defineProperty() method does not work in WSH.
  // It is not possible in this implementation to make the
  // property non-writable.

  /**
   * Show a warning message or an error message box.
   * The function does not return anything when the message box is an error.
   * @public @static @method Show @memberof MessageBox
   * @param {string} message is the message text.
   * @param {number} [messageType = ERROR_MESSAGE] message box type (Warning/Error).
   * @returns {string|void} "Yes" or "No" depending on the user's click when the message box is a warning.
   */
  MessageBox.Show = function(message, messageType) {
    if (messageType != ERROR_MESSAGE && messageType != WARNING_MESSAGE) {
      messageType = ERROR_MESSAGE;
    }
    // The error message box shows the OK button alone.
    // The warning message box shows the alternative Yes or No buttons.
    messageType += messageType == ERROR_MESSAGE ? OK_BUTTON:YESNO_BUTTON;
    switch ((new ActiveXObject('WScript.Shell')).Popup(message, NO_MESSAGE_TIMEOUT, MESSAGE_BOX_TITLE, messageType)) {
      case YES_POPUPRESULT:
        return 'Yes';
      case NO_POPUPRESULT:
        return 'No';
    }
  }

  return MessageBox;
})();

/**
 * Represents the shortcut target script runner watcher.
 * @typedef {object} ConversionWatcher
 */
var ConversionWatcher = (function() {
  /**
   * The specified Markdown path argument.
   * @private @type {string}
   */
  var MarkdownPath;
  /**
   * The overwrite prompt text as read from the powershell core console host.
   * @private @type {string}
   */
  var OverwritePromptText;

  /**
   * Separate the polluted characters from the informative message.
   * @private @constant {string}
   */
  var ERROR_MESSAGE_DELIM = '--';

  /**
   * @class @constructs ConversionWatcher
   * @param {string} markdown is the specified Markdown path argument.
   */
  function ConversionWatcher(markdown) {
    MarkdownPath = markdown;
    OverwritePromptText = '';
  }

  /**
   * Execute the runner of the shortcut target script and wait for its exit.
   * @public @memberof ConversionWatcher @instance
   */
  ConversionWatcher.prototype.Start = function() {
    WaitForExit(StartPwshExeWithMarkdown());
    // This method will run only once.
    delete ConversionWatcher.prototype.Start;
  }

  /**
   * Start a PowerShell Core process that runs the shortcut menu target
   * script with the markdown path as the argument.
   * The Try-Catch handles the errors thrown by the process. The Standard Error
   * Stream encoding is not utf-8. For this reason, it surrounds the message with
   * unwanted characters. The error message delimiter constant string separates
   * the informative message from noisy characters.
   * @private
   * @returns {object} the process started by the built command.
   */
  function StartPwshExeWithMarkdown() {
    var shell = new ActiveXObject('WScript.Shell');
    return shell.Exec(
      GetPathArgument(shell.RegRead(PWSH_KEY)) +
      ' -nop -ep Bypass -w Hidden -cwa ' +
      '"try{ & $args[0] -MarkdownPath $args[1] }' +
      // Get uniform error messages format by handling them in a catch statement.
      'catch { Write-Error (""' + ERROR_MESSAGE_DELIM +
      '"" + $_.Exception.Message + ""' + ERROR_MESSAGE_DELIM + '"") }" ' +
      GetPathArgument(ChangeScriptExtension('.ps1')) + ' ' +
      GetPathArgument(MarkdownPath)
    );
  }

  /**
   * Observe when the child process exits with or without an error.
   * Call the appropriate handler for each outcome.
   * @private
   * @param {object} pwshExe is the PowerShell Core process or child process.
   * @param {number} pwshExe.Status specifies whether the process is running (=0) or has completed (=1).
   * @param {number} pwshExe.ExitCode specifies that the process terminated with an error (!=0) or not (=0).
   * @param {number} pwshExe.StdOut the standard output stream.
   * @param {number} pwshExe.StdErr the standard error stream.
   */
  function WaitForExit(pwshExe) {
    // Wait for the process to complete.
    while (!pwshExe.Status && !pwshExe.ExitCode) {
      HandleOutputDataReceived(pwshExe, pwshExe.StdOut.ReadLine());
    }
    // When the process terminated with an error.
    if (pwshExe.ExitCode) {
      HandleErrorDataReceived(pwshExe.StdErr.ReadAll());
    }
  }

  /**
   * Show the overwrite prompt that the child process sends.
   * Subsequently, wait for the user's response.
   * Handle the event when the PowerShell Core (child) process
   * redirects output to the parent Standard Output stream.
   * @private
   * @param {object} pwshExe it the sender child process.
   * @param {string} outData the output text line sent.
   */
  function HandleOutputDataReceived(pwshExe, outData) {
    if (outData.length > 0) {
      // Show the message box when the text line is a question.
      // Otherwise, append the text line to the overall message text variable.
      if (outData.match(/\?\s*$/)) {
        OverwritePromptText += '\n' + outData;
        // Write the user's choice to the child process console host.
        pwshExe.StdIn.WriteLine(MessageBox.Show(OverwritePromptText, MessageBox.WARNING));
        // Optional
        OverwritePromptText = '';
      } else {
        OverwritePromptText += outData + '\n';
      }
    }
  }

  /**
   * Show the error message that the child process writes on the console host.
   * It handles the event when the child process redirects errors to the parent Standard
   * Error stream. Raised exceptions are terminating errors. Thus, this handler only notifies
   * the user of an error and displays the error message. For this reason, this subroutine
   * does not define the sender objPwshExe object parameter in its signature.
   * @private
   * @param {string} errData the error message text.
   */
  function HandleErrorDataReceived(errData) {
    if (errData.length > 0) {
      // Remove the polluted characters from the error message data text.
      var delimIndex = errData.indexOf(ERROR_MESSAGE_DELIM);
      var delimLastIndex = errData.lastIndexOf(ERROR_MESSAGE_DELIM);
      MessageBox.Show(errData.substring(delimIndex+2, delimLastIndex));
    }
  }

  return ConversionWatcher;
})();

(new ConversionWatcher(args.MarkdownPath)).Start();

DeleteLink(args.LinkName);

/**
 * Start the shortcut target PowerShell script with
 * the path of the selected markdown file and the link
 * name as the arguments.
 * @param {string} markdown is the input markdown path argument.
 */
function StartWith(markdown) {
  var linkName = (new ActiveXObject('Scriptlet.TypeLib')).Guid.substr(1, 36).toLowerCase() + '.tmp.lnk'
  var link = TEMP_PATH + '\\' + linkName;
  var shell = new ActiveXObject('WScript.Shell');
  var shortcut = shell.CreateShortcut(link);
  shortcut.TargetPath = WSH.FullName;
  shortcut.Arguments = GetPathArgument(WSH.ScriptFullName) + ' /MarkdownPath:' +
    GetPathArgument(markdown) + ' /LinkName:' + linkName;
  shortcut.IconLocation = ChangeScriptExtension(".ico");
  shortcut.Save();
  shell.Run(GetPathArgument(link));
}

/**
 * Change the launcher script path extension.
 * This change implies that the launcher script and the resulting
 * path file reside in the same directory and have the same name.
 * @param {string} extension is the new extension.
 * @returns {string} a file path with the new extension.
 */
function ChangeScriptExtension(extension) {
  return WSH.ScriptFullName.replace(/\.js$/i, extension);
}

/**
 * Check the link target command.
 * @param {object} link is the shortcut link.
 * @param {string} link.TargetPath is the path to the runner.
 * @param {string} link.Arguments is the target command line list of arguments.
 * @returns {boolean} True if the target command is as expected, false otherwise.
 */
function IsLinkReady(link) {
  return (link.TargetPath + ' ' + link.Arguments).toLowerCase() == 
    (WSH.FullName + ' //e:jscript ' + GetPathArgument(WSH.ScriptFullName)).toLowerCase();
}

/**
 * Double-quote the file path to make it command-ready.
 * @param {string} file is the file path.
 * @returns {string} a double-quoted path string.
 */ 
function GetPathArgument(file) {
  return '"' + file + '"';
}

/**
 * Delete the shortcut link from the TEMP folder.
 * @param {string} linkName is the link file name.
 */
function DeleteLink(linkName) {
  (new ActiveXObject('Scripting.FileSystemObject')).DeleteFile(TEMP_PATH + "\\" + linkName, true);
}