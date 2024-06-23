# **MarkdownToHtmlShortcut**
![Module Version](https://img.shields.io/badge/version-0.3.3-teal)
[![Publish Installer Module](https://github.com/sangafabrice/convertto-html-shortcut/actions/workflows/publish-installer-module.yaml/badge.svg)](https://github.com/sangafabrice/convertto-html-shortcut/actions/workflows/publish-installer-module.yaml)

</br>
<img src='module-icon.svg' alt='Module Icon' width='90px' />

[![Downloads](https://img.shields.io/powershellgallery/dt/MarkdownToHtmlShortcut?color=blue&label=On%20PowerShell%20Gallery%20%E2%AC%87%EF%B8%8F)](https://www.powershellgallery.com/packages/MarkdownToHtmlShortcut)

**MarkdownToHtmlShortcut** helps configure the _Windows context menu shortcut_ that converts Markdown files to HTML files. The module packages functions to add and remove the shortcut on and from the right-click context menu of `.md` files. Note that it does not require administrators' privileges to run.

**Requirements:** Windows 10/11, Powershell Core.

[![](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiJ2Q7CXDzeKOAHYyQovUE-CLzi1Iq2UTHpWtZ88PzG7cLBbZPCQ32Z4fpONAuWfk456VJMVgCt6FKhWhx3ckBesQ2VcIAMrzetKqmwAYnTPTajcernVI2TIYwbmI34L6z5W99XrkLzqGT-yMcOF5Xo61vJWCVZjA580s0DF7E8I2ylLzmt5p8byGtPgd3q/s1600/blogger-markdown-to-html-shortcut.png)](https://fromthetechlab.blogspot.com/2024/03/mind-blogging-convert-from-markdown-to-html.html)
</br>

## **Setup**

Install the **MarkdownToHtmlShortcut** module from a PowerShell Core console:
```PowerShell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module MarkdownToHtmlShortcut
```
Configure the shortcut menu with the functions below.
```PowerShell
Set-MarkdownToHtmlShortcut [<CommonParameters>]
Remove-MarkdownToHtmlShortcut [<CommonParameters>]
```

</br>
</br>

![](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgkl9ZoiktsJdPISp6cF7Nd78k4Gx3rOfaF8DeBP5AUFN43q4HB3vgGTxxW_hohH0HP-NF_B-eCzIFPP2LNSbWtgPITluDgiD0kyB-7hifjW6sdbiRgQP_tuTxg2MuCiylpDhirQwIBqRKBr8UbFy_wEepopwI78NJw8pC6VEOq-ujmO6NB3HJ2gtMlSmck/s1600/mdtohtm-icon.png)

<span style="font-size: 0.8em">Convert to HTML shortcut</span>