# **MarkdownToHtmlShortcut**
![Module Version](https://img.shields.io/badge/version-0.3.5-teal)

<br />

**MarkdownToHtmlShortcut** helps configure the _Windows context menu shortcut_ that converts Markdown files to HTML files. The module packages functions to add and remove the shortcut on and from the right-click context menu of `.md` files. Note that it does not require administrators' privileges to run.

**Requirements:** Windows 10/11, Powershell Core.

## **Setup**

Configure the shortcut menu with the functions below.
```PowerShell
Set-MarkdownToHtmlShortcut [-NoIcon] [-HideConsole] [<CommonParameters>]
Remove-MarkdownToHtmlShortcut [<CommonParameters>]
```
<br />

![](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgbM8Cqr-CFSu82JcTmgcWU41yhAwpqr1CrLAHnKx2eF0iiXeFS_V-_ru_o0PmCWBeglaB6eF-OIAljs9qJy_VDmRF9jVb0sbbZ5EGt5eqqARQE9QGxwdsbsq6S_7u6lZdMT03ww9WwpPfb6BhyAQkRL2kN92vPiAFMP0Vxl2A40Vr95JZ6lpq8QI20d517/s1600/mdtohtm-noicon.png)