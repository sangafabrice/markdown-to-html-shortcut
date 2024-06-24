import System;
import MarkdownToHtml.Shortcut;
import System.Reflection;
import System.Configuration.Assemblies;

[assembly: AssemblyFileVersionAttribute('0.0.1.*')]
[assembly: AssemblyInformationalVersionAttribute('1.0.0')]
[assembly: AssemblyAlgorithmIdAttribute(AssemblyHashAlgorithm.SHA256)]
[assembly: AssemblyCompanyAttribute('sangafabrice')]
[assembly: AssemblyCopyrightAttribute('© 2024 sangafabrice')]
[assembly: AssemblyProductAttribute('MarkdownToHtml Shortcut')]
[assembly: AssemblyTitleAttribute('Convert Markdown to HTML Launcher')]

TargetScriptLauncher.Start(Environment.GetCommandLineArgs());