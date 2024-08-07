/**
 * This script is the launcher script.
 * It starts the shortcut target PowerShell script with
 * the path of the selected markdown file as an argument.
 * The script aims to eliminate the flashing console window
 * when the user clicks on the shortcut menu.
 * The second argument of the Windows Script Host Shell COM object Run
 * method specifies that the window of the command runner is invisible.
 * The ConvertFrom-Markdown cmdlet requires PowerShell Core (pwsh.exe).
 * The Windows Script Host Shell COM object RegRead method reads the
 * PowerShell Core path string from the Registry.
 * The Windows Script Host Shell COM object CreateShortcut method
 * lists the properties of the intermediate shortcut link.
 * The shortcut link sets a custom icon for the PowerShell Core
 * window instead of the proprietary icon.
 * The shortcut link lists a partial list of arguments
 * completed with the markdown path string.
 * @param {string} MarkdownPath is the input markdown path argument.
 */

/**
 * The registry key stores the path to the PowerShell Core application.
 * @constant {string}
 */
var PWSH_KEY = 'HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\pwsh.exe\\';
/**
 * Open the application with a hidden window.
 * @constant {number}
 */
var WINDOW_STYLE_HIDDEN = 0;

StartWith(WSH.Arguments.Named('MarkdownPath'));

/**
 * Start the shortcut target PowerShell script with
 * the path of the selected markdown file as an argument.
 * @param {string} markdown is the input markdown path argument.
 */
function StartWith(markdown) {
  var link = ChangeScriptExtension('.lnk');
  var shell = new ActiveXObject('WScript.Shell');
  if (!IsLinkReady(shell.CreateShortcut(link))) {
    return
  }
  shell.Run(GetPathArgument(link) + ' ' + GetPathArgument(markdown), WINDOW_STYLE_HIDDEN);
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
    ((new ActiveXObject('WScript.Shell')).RegRead(PWSH_KEY) +
    ' -nol -ep Bypass -noni -nop -w Hidden -f ' +
    GetPathArgument(ChangeScriptExtension('.ps1')) + ' -MarkdownPath').toLowerCase();
}

/**
 * Double-quote the file path to make it command-ready.
 * @param {string} file is the file path.
 * @returns {string} a double-quoted path string.
 */ 
function GetPathArgument(file) {
  return '"' + file + '"';
}