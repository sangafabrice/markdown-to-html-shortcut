/*
 * Launches a hidden PowerShell Core console that executes
 * the target Convert-MdToHtml.ps1 script. The Markdown file path
 * string is passed to that script as its argument.
 * @param MarkdownFilePath The specified markdown file path string.
*/
(new ActiveXObject('WScript.Shell')).Run(
  // pwsh.exe is used because the ConvertFrom-Markdown
  // is available by default with PowerShell Core.
  'pwsh.exe -nop -noni -f "' +
  // We change the extension of the current JScript script
  // to the extension of the PowerShell script because
  // they have the same base name.
  WScript.ScriptFullName.replace(/\.js$/,'.ps1') + '" "' +
  // The input Markdown file path.
  WScript.Arguments.Named('MarkdownFilePath') + '"',
  0, // Hide the console window.
  false // Start a non blocking process.
);