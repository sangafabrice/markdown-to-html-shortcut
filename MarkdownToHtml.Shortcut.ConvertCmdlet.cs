using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace MarkdownToHtml.Shortcut
{
  [Cmdlet(VerbsData.Convert, "MarkdownToHtml")]
  public class ConvertCmdlet : Cmdlet
  {
    #nullable enable
    string _markdown = "";
    string? _html;

    /// <summary>
    /// Specifies the path of an existing .md Markdown file.
    /// </summary>
    [Parameter(Position = 0, Mandatory = true)]
    [ValidatePattern(@"\.md$")]
    public string MarkdownFilePath
    {
      private get
      {
        return _markdown;
      }
      set
      {
        if (!File.Exists(value)) {
          throw new FileNotFoundException(null, value);
        }
        _markdown = value;
      }
    }

    /// <summary>
    /// Specifies the path string of the output HTML file.
    /// By default it differs to the path of the input markdown file only by the extension. The parent directory and the base name are the same.
    /// </summary>
    [Parameter()]
    [ValidatePattern(@"\.html?$")]
    public string HtmlFilePath
    {
      private get
      {
        return _html ?? Path.ChangeExtension(MarkdownFilePath, "html");
      }
      set
      {
        _html = value;
      }
    }

    /// <summary>
    /// Specifies that the output file should be overridden.
    /// </summary>
    [Parameter()]
    public SwitchParameter OverWrite;

    protected override void ProcessRecord()
    {
      #nullable disable
      string answer;
      // If the HTML file exists, prompt the user to choose to overwrite or abort.
      if (File.Exists(HtmlFilePath))
      {
        if (!OverWrite.IsPresent)
        {
          do
          {
            Console.Write($"The file \"{HtmlFilePath}\" already exists.\nDo you want to overwrite it?\n[Y]es [N]o: ");
          }
          while (!(new Regex("((Y(e(s)?)?)|(No?))$", RegexOptions.IgnoreCase)).IsMatch((answer = Console.ReadLine())));
          if ((new Regex("No?", RegexOptions.IgnoreCase)).IsMatch(answer))
          {
            return;
          }
        }
      }
      else if (Directory.Exists(HtmlFilePath))
      {
        throw new Exception($"\"{HtmlFilePath}\" cannot be overwritten because it is a directory.");
      }
      // Create runspace and proxy variable of MarkdownFilePath property.
      InitialSessionState sessionState = InitialSessionState.CreateDefault2();
      sessionState.Variables.Add(new SessionStateVariableEntry("MarkdownFilePath", MarkdownFilePath, ""));
      using (PowerShell runspace = PowerShell.Create(sessionState))
      {
        // Conversion from Markdown to HTML.
        using (var iterator = runspace.AddScript("(ConvertFrom-Markdown $MarkdownFilePath).Html").Invoke().GetEnumerator())
        {
          if (iterator.MoveNext())
          {
            File.WriteAllText(HtmlFilePath, iterator.Current.ToString());
          }
        }
      }
    }
  }
}
