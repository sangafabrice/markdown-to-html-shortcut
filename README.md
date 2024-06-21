# **MarkdownToHtmlShortcut**
![Module Version](https://img.shields.io/badge/version-0.3.3-teal)
[![Publish Installer Module](https://github.com/sangafabrice/convertto-html-shortcut/actions/workflows/publish-installer-module.yaml/badge.svg)](https://github.com/sangafabrice/convertto-html-shortcut/actions/workflows/publish-installer-module.yaml)

|||
| --- | ------------------------------------------------------- |
| <img src='module-icon.svg' alt='Module Icon' width='300px'> | **MarkdownToHtmlShortcut** helps configure the _Windows context menu shortcut_ that converts Markdown files to HTML files. The module packages functions to add and remove the shortcut on and from the right-click context menu of `.md` files. Note that it does not require administrators' privileges to run. |

[![Downloads](https://img.shields.io/powershellgallery/dt/MarkdownToHtmlShortcut?color=blue&label=PSGallery%20%E2%AC%87%EF%B8%8F)](https://www.powershellgallery.com/packages/MarkdownToHtmlShortcut)

## **Requirements**

- Windows 10/11
- Powershell Core

## **Setup**

Install the **MarkdownToHtmlShortcut** module from a PowerShell Core console:

```PowerShell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module MarkdownToHtmlShortcut
```

</br>

Configure the shortcut menu using `Set-MarkdownToHtmlShortcut`.

```PowerShell
Set-MarkdownToHtmlShortcut [-NoIcon] [-HideConsole] [<CommonParameters>]
```

|||
|:-|-:|
|`Set-MarkdownToHtmlShortcut            `|`     Set-MarkdownToHtmlShortcut -NoIcon`|
|![](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgkl9ZoiktsJdPISp6cF7Nd78k4Gx3rOfaF8DeBP5AUFN43q4HB3vgGTxxW_hohH0HP-NF_B-eCzIFPP2LNSbWtgPITluDgiD0kyB-7hifjW6sdbiRgQP_tuTxg2MuCiylpDhirQwIBqRKBr8UbFy_wEepopwI78NJw8pC6VEOq-ujmO6NB3HJ2gtMlSmck/s1600/mdtohtm-icon.png)|![](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgbM8Cqr-CFSu82JcTmgcWU41yhAwpqr1CrLAHnKx2eF0iiXeFS_V-_ru_o0PmCWBeglaB6eF-OIAljs9qJy_VDmRF9jVb0sbbZ5EGt5eqqARQE9QGxwdsbsq6S_7u6lZdMT03ww9WwpPfb6BhyAQkRL2kN92vPiAFMP0Vxl2A40Vr95JZ6lpq8QI20d517/s1600/mdtohtm-noicon.png)|

|||
|:-|-:|
|`Set-MarkdownToHtmlShortcut            `|`Set-MarkdownToHtmlShortcut -HideConsole`|
|<img src='https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiVHdACvtp1rO0G6GylcUgwHIaJtPaEq1CO5T_R1OLr5XsQcsLnlaXY_Ilq9k0lOGko_6h8Gb8epoVxItmNYrGTJp1dNl_DpyQKyDBiXPkpbWqRGgwfnMjCJvYb8XNwYM3QYgNlrQ5Hvmo96BKepY26X5ZY3ytDfYbwfKl_DXLN63P6IHKBErBIocbFg_x6/s1600/showconsole.gif' alt='Module Icon' width='246px'>|<img src='https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi0Q6sgWoHantyvQXxp4eIDOtXL7ABAjfw-d2LCC76C383xAdDqHDVdxK1_cFgn-INdu2eVRKVeP2dWQQJtdEID4XKpCIid3Cpmj1LyibV2Vyi6xr2EixvsHUvrA7YmOtAQ_HkHDCwm9KhiSEUj2_axCnOmj1yVDTz5j_3o-2jmTH6qt0jAooSYXX8HmIm5/s1600/hideconsole.gif' alt='Module Icon' width='246px'>|

</br>

Remove the shortcut menu using `Remove-MarkdownToHtmlShortcut`.

```PowerShell
Remove-MarkdownToHtmlShortcut [<CommonParameters>]
```