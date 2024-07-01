/**Launches a hidden PowerShell Core console that executes
 * the target Convert-MarkdownToHtml.ps1 script. The Markdown file path
 * string is passed to that script as its argument.
 * @param MarkdownFilePath The specified markdown file path string.
*/
(new ActiveXObject('WScript.Shell')).Run(
  // The shortcut link to the PowerShell Target script.
  '"' + WScript.ScriptFullName.replace(/\.js$/i,'.lnk') + '" "' +
  // The input Markdown file path.
  WScript.Arguments.Named('MarkdownFilePath') + '"',
  0 // Hide the console window.
);