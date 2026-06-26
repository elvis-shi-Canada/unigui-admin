# uniGUI Component Reference Manual

来源: https://www.unigui.com/doc/online_help/index.html

---

## 组件目录

1. [Introduction](#component-1)
2. [System Requirements](#component-2)
3. [Installation Instructions](#component-3)
4. [Installing uniGUI Using The New Installer](#component-4)
5. [Trial Edition](#component-5)
6. [Commercial Edition](#component-6)
7. [Trial Edition (C++ Builder)](#component-7)
8. [Commercial Edition (C++ Builder)](#component-8)
9. [C++ Builder (Without RAD Studio)](#component-9)
10. [Bypassing Installer BDS check](#component-10)
11. [Building 64-bit library files](#component-11)
12. [Silent Installation of Runtime Packages](#component-12)
13. [Sencha Touch Installation](#component-13)
14. [Running Demos](#component-14)
15. [Technology Overview](#component-15)
16. [Unified GUI](#component-16)
17. [uniGUI Application Architecture](#component-17)
18. [Deployment Options](#component-18)
19. [Forms and Modules](#component-19)
20. [ServerModule](#component-20)
21. [MainModule](#component-21)
22. [LoginForm](#component-22)
23. [MainForm](#component-23)
24. [Other Forms](#component-24)
25. [Application Form](#component-25)
26. [Free Form](#component-26)
27. [DataModules](#component-27)
28. [Application DataModule](#component-28)
29. [Free DataModule](#component-29)
30. [Frames](#component-30)
31. [ServiceModule](#component-31)
32. [Components](#component-32)
33. [Standard](#component-33)
34. [Additional](#component-34)
35. [Data Controls](#component-35)
36. [Extra](#component-36)
37. [UniApplication Object](#component-37)
38. [UniSession Object](#component-38)
39. [UniServerInstance Object](#component-39)
40. [Creating a New uniGUI Application](#component-40)
41. [Standalone Server Project](#component-41)
42. [Standalone Server (Console Application)](#component-42)
43. [Standalone Server / ISAPI Module Project](#component-43)
44. [ISAPI Module Project](#component-44)
45. [Windows Service Project](#component-45)
46. [Apache Module](#component-46)
47. [Application Design Considerations](#component-47)
48. [General Design Concept](#component-48)
49. [Web Application Scalability](#component-49)
50. [Create Resources on Demand](#component-50)
51. [Database Connections](#component-51)
52. [Web Application Stability](#component-52)
53. [Memory Management](#component-53)
54. [Importance of Proper Memory Management](#component-54)
55. [Object Lifetime Management](#component-55)
56. [Special Considerations for ISAPI Modules](#component-56)
57. [Thread Stack Size](#component-57)
58. [Using OLE based components](#component-58)
59. [Third party Component Libraries](#component-59)
60. [Reporting Tools](#component-60)
61. [FastReport](#component-61)
62. [Important notes on FastReport and thread safety](#component-62)
63. [ReportBuilder](#component-63)
64. [Using a Report Server](#component-64)
65. [Database Components](#component-65)
66. [FireDAC](#component-66)
67. [Using Runtime Packages](#component-67)
68. [Runtime Packages & C++ Builder](#component-68)
69. [Special Considerations](#component-69)
70. [FormatSettings](#component-70)
71. [Decimal Separator in Mobile Devices](#component-71)
72. [Dynamically Created Controls](#component-72)
73. [Creating Controls at Runtime](#component-73)
74. [Destroying Controls at Runtime](#component-74)
75. [Creating or Destroying of Multiple Controls at Runtime](#component-75)
76. [Best Practices](#component-76)
77. [Handling Concurrency](#component-77)
78. [N-Tier web applications](#component-78)
79. [Synchronous and Asynchronous Operations](#component-79)
80. [Database-Centric Applications](#component-80)
81. [User Interface](#component-81)
82. [Small hybrid application](#component-82)
83. [Features and limitations](#component-83)
84. [Programming the hybrid application](#component-84)
85. [Server Module](#component-85)
86. [Main Module](#component-86)
87. [Login Form](#component-87)
88. [Main Form (launching pad)](#component-88)
89. [Users Editor Form](#component-89)
90. [Orders Editor Form](#component-90)
91. [Sales Report Form](#component-91)
92. [Client-side Scripting](#component-92)
93. [Adding Custom Ext JS Events](#component-93)
94. [Deployment](#component-94)
95. [Sencha Ext JS License Considerations](#component-95)
96. [uniGUI Runtime Package](#component-96)
97. [uniGUI Runtime Package in tar.gz format](#component-97)
98. [Adjusting Paths](#component-98)
99. [Standalone Server](#component-99)
100. [Windows Service](#component-100)

---

## 1. Introduction

### Introduction

来源: https://www.unigui.com/doc/online_help/introduction.htm

#### 章节标题

  - Introduction
  - Introduction

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      »No topics above this level«
      
   
      Introduction |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Introduction
	  

uniGUI is a Web Application Framework for Embarcadero Delphi and C++ Builder. uniGUI features a full set of visual controls for developing stateful Web applications, namely SPAs. The development process is very similar to developing regular VCL applications. uniGUI Web applications can be run and debugged directly in the RAD Studio Delphi IDE, which makes the development process very easy and straightforward. UniGUI extends the Web application development experience to a new dimension. In this new dimension, productivity is the primary goal. uniGUI allows the developer to focus on application business logic rather than working on Web application development details such as working directly with HTML, JavaScript, XML Templates, and other Web technologies. uniGUI will save many valuable development hours, which in turn helps to reduce project development, deployment, and support costs considerably. It makes uniGUI a perfect tool for small development teams which have limited resources to spend on development details. uniGUI is also the right tool for large teams creating enterprise-scale Web applications in a limited time.

Deployment is another important step in the Web application development process. With uniGUI, deployment is simple. Developers can choose any of the available deployment options such as Windows Service, Standalone Server, or ISAPI Module. ISAPI modules can be deployed using Microsoft IIS, Apache Web Server for Windows, or any other compatible ISAPI-enabled Web server.

uniGUI uses Sencha Ext JS library for client-side rendering. These libraries are considered among the industry leading frameworks to create SPA applications. uniGUI combines the power of Ext JS with the RAD capabilities of Delphi to provide the fastest way of creating SPAs in Delphi. uniGUI encapsulates Ext JS classes inside a special set of Delphi controls which enables developers to create feature rich web applications without needing to learn client-side scripting and web UI details. The developers can focus on business logic rather than working on repetitive UI design details which can be time-consuming and technically demanding tasks.

uniGUI application in Delphi 10 Seattle IDE

Web Application running inside a browser

---

## 2. System Requirements

### Installation > System Requirements

来源: https://www.unigui.com/doc/online_help/requirements.htm

#### 章节标题

  - System Requirements
  - System Requirements

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation >
   
      System Requirements |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

System Requirements
	  

Supported Delphi* versions are Turbo Delphi, Delphi 2006, Delphi 2007, Delphi 2009, Delphi 2010, Delphi XE-XE8, Delphi 10 Seattle, Delphi 10.1 Berlin, Delphi 10.2 Tokyo, 10.3.3 Rio, 10.4 Sydney, 11.3 Alexandria and 12.0 Athens (Win32, Win64 and Linux64 platforms). (Linux support is available for Delphi 10.3 and later)

 

C++ Builder is supported but not tested with all Versions.

 

uniGUI does not require any special hardware or OS configuration. A typical uniGUI installation requires 100-150MB of HDD space.

 

Note: Requirements for run-time environment can be very different and will be discussed under the deployment topic.

 

*All Delphi versions must be installed with the latest available updates and service packs.

 

 

---

## 3. Installation Instructions

### Installation > Installation Instructions

来源: https://www.unigui.com/doc/online_help/installation_instructions.htm

#### 章节标题

  - Installation Instructions
  - Installation Instructions
    - Introduction to New Installer
      - 
      - Installing uniGUI using New Installer
      - 
    - Installing using uniGUI Legacy Installer
      - 

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation >
   
      Installation Instructions |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Installation Instructions
	  
Introduction to New Installer

 

Starting with build 1601 uniGUI introduces a fully automated installer. Unlike the previous installer which required manual building and installing uniGUI packages, this new installer will compile packages during installation and registers them in the Delphi IDE.

Installing uniGUI using the new installer is easy and straightforward.  This installer automatically installs uniGUI for both Delphi and C++ Builder. It makes life easier especially for C++ Builder developers.

The new installer also builds 64-bit BPLs and related library files if selected Delphi version supports Win64 platform.

 
Installing uniGUI using New Installer
 

 

Installing using uniGUI Legacy Installer

 

This includes all uniGUI installers that were published prior to uniGUI build 1601.

Please follow below instruction to install uniGUI using the legacy installers:

 

oTrial Edition

oCommercial Edition

oTrial Edition (C++ Builder)

oCommercial Edition (C++ Builder)

oC++ Builder (Without RAD Studio)

oBuilding 64-bit library files

 

 

---

## 4. Installing uniGUI Using The New Installer

### Installation > Installation Instructions > Installing uniGUI Using The New Installer

来源: https://www.unigui.com/doc/online_help/installing-unigui-using-the-ne.htm

#### 章节标题

  - Installing uniGUI Using The New Installer
  - Installing uniGUI Using The New Installer
    - Running the Installer
    - Activating The License
    - Offline Activation
    - License Agreement
    - Installation Folder
    - Choosing Delphi (RAD Studio) Versions
    - Installation of uniGUI Files and Packages
    - Compiling the Packages
    - Finalizing The Installation
    - Additional Steps for RAD Studio Community Edition

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation > Installation Instructions >
   
      Installing uniGUI Using The New Installer |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Installing uniGUI Using The New Installer
	  

Installing uniGUI using the new installer is easy and straightforward. This guide aims to cover all available scenarios including the trial edition.

First step is to download uniGUI from the Customer Portal. If you are installing uniGUI trial edition you can download it from uniGUI website.

 

Running the Installer

 

After running the installer you will see the introduction page.

 

Pressing Next will show the Registration Information form. (Commercial edition only. This form won't be shown if you are installing the trial edition)

Please enter your name and email address (Company is optional). This email address should be the same address you have used to buy uniGUI license.

 

 

Activating The License

 

Next step is to activate your license. (Commercial edition only)

This new form will be used to acquire your license key and activate your license.

You need to enter your Customer Portal password in the related field and press the Get License Key button.

This an automatically generated password which is sent to by an email when you purchase a license.

If you are a team member this password is sent to you by an email when your team leader assigns you as a team member.

Needless to say that if you have changed your password in the Customer Portal then you must use the updated one.

 

 

If your password is correct then a license will be acquired from our server and Continue... button will be activated.

 

 

Note:  If your computer is behind a proxy server you may not to be able to retrieve a license key directly. In this case you can get your license key indirectly by clicking on the blue link Web link to license key....

This will open a browser window containing your license key. You can paste the key in the License Key area.

 

 

Offline Activation

 

Alternatively you can activate your license using a previously saved license key. After retrieving your key you can save it your HDD using save button and load it later when installing uniGUI again on same computer. Please note that the save license key is only valid for the computer you are installing uniGUI. This key maybe also valid for next uniGUI releases, but it can not be guaranteed. We may change license key validation algorithm from time to time, so your saved key may become invalid sometime in the future for any of the future releases. (It will stay valid for the version that you have used to obtained this key)

 

 

License Agreement

 

Pressing the Continue... key will show the License Agreement page. Please review the displayed EULA terms and choose I accept the agreement choice to continue.

 

 

Installation Folder

 

Next step will ask you to choose a folder to install uniGUI or choose the default folder (Recommended).

 

 

Choosing Delphi (RAD Studio) Versions

 

In next page a list of available Delphi installation will be displayed. Installer scan registry information to detect valid Delphi installations in your computer. Only valid installations of Delphi will be available in the list.

For example, if there's only one version installed in your PC you will see it as the only item in the list. You can customize this list by deselecting the Delphi versions you don't want to install uniGUI. In below picture as you may have noticed some of the Delphi versions are listed as Delphi while others are listed as RAD Studio. This means that for some of the versions only Delphi is supported while for others uniGUI supports both Delphi and C++ Builder.

Basically, uniGUI support for C++ Builder starts from RAD Studio 2009. The term RAD Studio will be displayed regardless of the actual products that are installed. (Whether the installed product is Delphi, C++ Builder or both)

For example, if you have installed Delphi XE only (no C++ Builder), it will be still listed as RAD Studio XE in the components list.

 

 

As said above, the list of components will be customized based on the versions of RAD Studio that are installed on your PC.

For example, in below image four different versions of RAD Studio are installed on the PC.

 

 

Installation of uniGUI Files and Packages

 

In next screen uniGUI installer is ready to install the packages. You can go Back if you want to change any detail or press Install to complete the installation.

The rest of the process will happen automatically and installer will display various information about the process stages.

 

 

In next stage files will be extracted.

 

 

Compiling the Packages

 

One of the new features of the new installer is its ability to compile uniGUI package during the installation.

For each selected version of Delphi the installer will compile uniGUI package for Delphi and generates C++ library and header files.

 

 

It is possible that you may encounter an error during package compilation. In this case an error message will be displayed as below:

 

 

So what can be done when you get a compile time error?

There are few things to try:

 

•Make a clean install of uniGUI especially when you try to upgrade from or downgrade to a different uniGUI edition. A clean install means uninstalling any previous version of uniGUI and completely erasing the uniGUI Framework folder.

•Make sure your Delphi edition has all available updates and patches installed.

•Make sure your Delphi installation is valid and working i.e. you are able to build applications in Delphi IDE.

•If you have installed the Community Edition please scroll down the page and read the section (Additional Steps for RAD Studio Community Edition).

 

Finalizing The Installation

 

After all packages are compiled installer will apply necessary registry settings to adjust IDE paths and register uniGUI packages.

 

 

 

 

Additional Steps for RAD Studio Community Edition

 

Unfortunately, uniGUI installer is unable to automatically compile packages for RAD Studio Community Edition.

This edition doesn't include the command line compilers dcc32/dcc64 which makes it impossible to compile packages outside the IDE.

 

If you try installing uniGUI for Community Edition you will get below error message. After this error installation process will continue and will end normally.

At this stage you need to follow the installation instructions for our legacy installer.

Which means that you need to open uniGUI packages in the Delphi IDE, build them and install the design time packages manually.

 

 

 

 

---

## 5. Trial Edition

### Installation > Installation Instructions > Trial Edition

来源: https://www.unigui.com/doc/online_help/trial-edition.htm

#### 章节标题

  - Trial Edition
  - Trial Edition

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation > Installation Instructions >
   
      Trial Edition |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Trial Edition
	  

Installation instructions for uniGUI

 

•Before installing a new version please uninstall any previous uniGUI version.

 

1) Please download the latest uniGUI Trial Setup from uniGUI website.

 

Run the downloaded file named FMSoft_uniGUI_Complete_Professional_{version}_Trial.exe

 

 

 

 

 

2) Accept the license agreement and press next.

 

 

 

 

3) Select an installation folder. Default installation folder is [ProgramFiles]\Fmsoft\Framework\.

 

 

4) Select the Delphi version(s) for which you want to install uniGUI. You must be sure that Delphi is not running while the installation is in progress. The current version of the installer will not warn you about this.

 

 

5) Press Install to start, and complete the installation process.

 

 

 

 

6) Start Delphi and open the project group for your Delphi version. e.g. uniGUI_D10_3_Rio_PlusGroup (Delphi 10.3 Rio).  

 

 

7) In the project group there is a number of  Delphi packages. Build all of the packages starting from SynEdit_Rxxxx.bpl. You can run IDE Build All command for the whole project group.

 

 

Important: Do not select Clean All or Clean commands for any of the uniGUI packages. This will delete all pre-compiled DCU files from the DCU folder and you will have to install uniGUI again.

 

 

8) After building all packages, you must install the design time packages by right-clicking and selecting Install in the following order:

 

•  SynEdit_D20xx.bpl

•    uniGUIxxdcl.bpl

•    uniGUIxxChartdcl.bpl ( Starting from build 1597 this package is no longer available )

•    uniGUIxxmdcl.bpl (Plus/Complete Editions only)

 

 

Several new components will be installed:

 

 

 

 

Complete/Plus Edition only

 

 

 

Now the installation is completed. You can proceed to running demos or creating new uniGUI projects.

---

## 6. Commercial Edition

### Installation > Installation Instructions > Commercial Edition

来源: https://www.unigui.com/doc/online_help/delphi-only.htm

#### 章节标题

  - Commercial Edition
  - Commercial Edition

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation > Installation Instructions >
   
      Commercial Edition |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Commercial Edition
	  

Installation instructions for uniGUI

 

•Before installing a new version please uninstall uniGUI from Windows Program Add/Remove.

•After re-compiling an application with this new version you should install the related uniGUI Runtime Package which can be downloaded from the customer portal.

 

1) Please download the latest uniGUI Setup from the customer portal.

You will notice that there are two Setup versions:

 

•FMSoft_uniGUI_{Edition_0.XX.0.YYYY}.exe

oThis is the one which will be installed on developer PC for development purpose.

•FMSoft_uniGUI_{Edition_runtime_0.XX.0.YYYY}.exe

oThis one is only for deployment and will be installed on server computer hosting your uniGUI apps.

 

 

2) Enter the following information. Make sure the email address is exactly the same as the email address registered in the customer portal.

 

 

 

3) Accept the license agreement and press next.

 

 

 

 

4) Starting from version 0.99.95 the license keys are directly obtained from an activation server. You can easily get your license key by entering your password and pressing the Get License Key button. This will fill the License Key area with an appropriate key. Alternatively you can get your license key by clicking on the blue link: Web link to license key.... This will open a browser window which will open a page containing your key. You can paste the key in License Key area.

 

 

After the key is acquired, you can press Continue... and proceed to the next step.

 

It is also possible to save your acquired license key in a local file and use it the next time you re-install the same edition and version of uniGUI.

 

 

5) Select an installation folder. Default installation folder is [ProgramFiles]\Fmsoft\Framework\.

 

6) Select the Delphi version(s) for which you want to install uniGUI. You must be sure that Delphi is not running while the installation is in progress. The current version of the installer will not warn you about this.

 

 

7) Press Install to start, and complete the installation process.

 

 

 

 

 

8) Start Delphi and open the project group for your Delphi version. e.g. uniGUI_D10_3_Rio_PlusGroup (Delphi 10.3 Rio).  

 

 

 

9) In Project Manager there are 11 Delphi packages. Build all packages starting from SynEdit_Rxxxx.bpl.

 

Important: Do not select Clean All or Clean commands for any of the uniGUI packages. This will delete all pre-compiled DCU files from the DCU folder and you will have to install uniGUI again.

 

 

In the project group there is a number of  Delphi packages. Build all of the packages starting from SynEdit_Rxxxx.bpl. You can run IDE Build All command for the whole project group.

 

 

 

10) After building all packages, you must install the design time packages by right-clicking and selecting Install in the following order:

 

•  SynEdit_D20xx.bpl

•    uniGUIxxdcl.bpl

•    uniGUIxxChartdcl.bpl ( Starting from build 1597 this package is no longer available )

•    uniGUIxxmdcl.bpl (Plus/Complete Editions only)

 

 

Several new components will be installed:

 

 

 

 

Complete/Plus Edition only

 

 

 

Now the installation is completed. You can proceed to running demos or creating new uniGUI projects.

---

## 7. Trial Edition (C++ Builder)

### Installation > Installation Instructions > Trial Edition (C++ Builder)

来源: https://www.unigui.com/doc/online_help/delphi--c-builder.htm

#### 章节标题

  - Trial Edition (C++ Builder)
  - Trial Edition (C++ Builder)

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation > Installation Instructions >
   
      Trial Edition (C++ Builder) |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Trial Edition (C++ Builder)
	  

Installation instructions for uniGUI (C++ Builder)

 

•Before installing a new version please uninstall any previous uniGUI version.

•You need RAD Studio IDE to install uniGUI for C++ Builder.

 

1) Please download the latest uniGUI Trial Setup from uniGUI website.

 

Run the downloaded file named FMSoft_uniGUI_Complete_Professional_{version}_Trial.exe

 

 

 

 

 

2) Accept the license agreement and press next.

 

 

 

 

3) Select an installation folder. Default installation folder is [ProgramFiles]\Fmsoft\Framework\.

 

 

4) Select the Delphi version(s) for which you want to install uniGUI. You must be sure that Delphi is not running while the installation is in progress. The current version of the installer will not warn you about this.

 

 

5) Press Install to start, and complete the installation process.

 

 

 

 

6) Start RAD Studio IDE and open the project group for your Delphi version. e.g. uniGUI_D10_3_Rio_PlusGroup (Delphi 10.3 Rio).  

 

 

7) In the project group there are several Delphi packages. Before building this packages we need to make a small changes to package configuration.

Note: Starting with uniGUI version 1.90.0.1537 all package are modified, so they will generate all C++ related files by default. If you are installing version 1.90.0.1537 of later then you can skip this step and continue to step 7.1.

 

Before building packages, for all uniGUI packages please go to Options->Linker and Select/Set Generate all C++Builder Files as shown below:

(If your Delphi version supports more than one platform make sure to set the Target to All configurations - All platforms )

 

Additional step for C++ Builder installation only.

 

The configuration screen may change between different Delphi versions. For example above picture is taken from Delphi XE4 while below picture is from Delphi 10.3.2.

Confiuration for Delphi 10.3.2

 

7.1) Now build all of the packages starting from SynEdit_Rxxxx.bpl. You can run IDE Build All command for the whole project group.

 

Important: Do not select Clean All or Clean commands for any of the uniGUI packages. This will delete all pre-compiled DCU files from the DCU folder and you will have to install uniGUI again.

 

 

 

8) After building all packages, you must install the design time packages by right-clicking and selecting Install in the following order:

 

•  SynEdit_D20xx.bpl

•    uniGUIxxdcl.bpl

•    uniGUIxxChartdcl.bpl ( Starting from build 1597 this package is no longer available )

•    uniGUIxxmdcl.bpl (Plus/Complete Editions only)

 

 

Several new components will be installed:

 

 

 

 

Complete/Plus Edition only

 

 

 

Now the installation is completed. You can proceed to running demos or creating new uniGUI projects.

 

Additional Notes:

 

•After starting a new C++ project, you must disable Linker->Dynamic RTL.

•New C++ projects are created without a resource (.RES) file. As a result, the project has no default Icon. This issue will be fixed in next releases.

•Combo VCL/ISAPI projects are not supported for C++ Builder.

•It is recommended to build your C++ Builder app without Run-Time Packages. You must statically link all libraries and create a single EXE. You can also use the default mode which uses run-time packages by default. If you want to build your application in this mode, then please read section Run-time Packages & C++ Builder.

 

 

---

## 8. Commercial Edition (C++ Builder)

### Installation > Installation Instructions > Commercial Edition (C++ Builder)

来源: https://www.unigui.com/doc/online_help/delphi--c-builder2.htm

#### 章节标题

  - Commercial Edition (C++ Builder)
  - Commercial Edition (C++ Builder)

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation > Installation Instructions >
   
      Commercial Edition (C++ Builder) |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Commercial Edition (C++ Builder)
	  

Installation instructions for uniGUI (C++ Builder)

 

•Before installing a new version, remove all design packages from Delphi and uninstall uniGUI from Windows Program Add/Remove.

•After re-compiling an application with this new version you should install the related uniGUI Runtime Package which can be downloaded from the customer portal.

•You need RAD Studio IDE to install uniGUI for C++ Builder.

 

1) Please download the latest uniGUI Setup from the customer portal.

You will notice that there are two Setup versions:

 

•FMSoft_uniGUI_{Edition_0.XX.0.YYYY}.exe

oThis is the one which will be installed on developer PC for development purpose.

•FMSoft_uniGUI_{Edition_runtime_0.XX.0.YYYY}.exe

oThis one is only for deployment and will be installed on server computer hosting your uniGUI apps.

 

 

2) Enter the following information. Make sure the email address is exactly the same as the email address registered in the customer portal.

 

 

 

3) Accept the license agreement and press next.

 

 

 

 

4) Starting from version 0.99.95 the license keys are directly obtained from an activation server. You can easily get your license key by entering your password and pressing the Get License Key button. This will fill the License Key area with an appropriate key. Alternatively you can get your license key by clicking on the blue link: Web link to license key.... This will open a browser window which will open a page containing your key. You can paste the key in License Key area.

 

 

After the key is acquired, you can press Continue... and proceed to the next step.

 

It is also possible to save your acquired license key in a local file and use it the next time you re-install the same edition and version of uniGUI.

 

 

5) Select an installation folder. Default installation folder is [ProgramFiles]\Fmsoft\Framework\.

 

6) Select the Delphi version(s) for which you want to install uniGUI. You must be sure that Delphi is not running while the installation is in progress. The current version of the installer will not warn you about this.

 

 

7) Press Install to start, and complete the installation process.

 

 

 

 

8) Start RAD Studio IDE and open the project group for your Delphi version. e.g. uniGUI_D10_3_Rio_PlusGroup (Delphi 10.3 Rio).  

 

 

 

9)  In the project group there are several Delphi packages. Before building this packages we need to make a small changes to package configuration.

Note: Starting with uniGUI version 1.90.0.1537 all package are modified, so they will generate all C++ related files by default. If you are installing version 1.90.0.1537 of later then you can skip this step and continue to step 9.1.

 

Before building packages, for all uniGUI packages please go to Options->Linker and Select/Set Generate all C++Builder Files as shown below:

(If your Delphi version supports more than one platform make sure to set the Target to All configurations - All platforms )

 

Additional step for C++ Builder installation only.

 

The configuration screen may change between different Delphi versions. For example above picture is taken from Delphi XE4 while below picture is from Delphi 10.3.2.

 

Confiuration for Delphi 10.3.2

 

 

9.1) In Project Manager there are 11 Delphi packages. Build all packages starting from SynEdit_Rxxxx.bpl.

Important: Do not select Clean All or Clean commands for any of the uniGUI packages. This will delete all pre-compiled DCU files from the DCU folder and you will have to install uniGUI again.

 

 

 

9.2) Additional steps for C++ Builder (Win64 Platform):

 

If you plan to compile C++ Builder projects for Win64 platform, you must repeat this step for uniGUI Runtime Packages only for 64-bit Windows Platform as well.

Here is the list of uniGUI Runtime Packages that should be built for C++ Builder Win64 platform only:

 

uniToolsXX
uIndyXX
uniGUIXXCore
uniGUIXX
uniGUIXXChart ( Starting from build 1597 this package is no longer available )
uniGUIXXmCore
uniGUIXXm

 

Which means you need to go to each of the above packages in project manager, change the selected platform to Win64 and Build the package to generate required HPP and other C++ specific files for Win64 platform.

Note: the above steps are only needed for Win64 platform and C++ Builder.

 

In the project group there is a number of  Delphi packages. Build all of the packages starting from SynEdit_Rxxxx.bpl. You can run IDE Build All command for the whole project group.

 

10) After building all packages, you must install the design time packages by right-clicking and selecting Install in the following order:

 

•  SynEdit_D20xx.bpl

•    uniGUIxxdcl.bpl

•    uniGUIxxChartdcl.bpl ( Starting from build 1597 this package is no longer available )

•    uniGUIxxmdcl.bpl (Plus/Complete Editions only)

 

 

Several new components will be installed:

 

 

 

 

Complete/Plus Edition only

 

 

Now the installation is completed. You can proceed to running demos or creating new uniGUI projects.

 

Additional Notes:

 

•After starting a new C++ project, you must disable Linker->Dynamic RTL.

•New C++ projects are created without a resource (.RES) file. As a result, the project has no default Icon. This issue will be fixed in next releases.

•Combo VCL/ISAPI projects are not supported for C++ Builder.

•It is recommended to build your C++ Builder app without Run-Time Packages. You must statically link all libraries and create a single EXE. You can also use the default mode which uses run-time packages by default. If you want to build your application in this mode, then please read section Run-time Packages & C++ Builder.

 

 

---

## 9. C++ Builder (Without RAD Studio)

### Installation > Installation Instructions > C++ Builder (Without RAD Studio)

来源: https://www.unigui.com/doc/online_help/c-builder-(without-rad-studio).htm

#### 章节标题

  - C++ Builder (Without RAD Studio)
  - C++ Builder (Without RAD Studio)

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation > Installation Instructions >
   
      C++ Builder (Without RAD Studio) |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

C++ Builder (Without RAD Studio)
	  

This is a new installation method introduced in uniGUI build 1552. This method doesn't required RAD Studio, so can be very useful for developers who own C++ Builder license only. In order to use this method to install uniGUI for C++ Builder you need to follow regular instructions for C++ Builder until a certain step. For Commercial Edition until step 7 and for Trial Edition until step 5.

 

Note: Currently this method works for C++ Builder XE and later.

 

After this step you need you open C++ Builder IDE and close it. This step is required to make sure IDE will recognize new registry settings applied by the installer.

 

Next step is to run a batch file which will build uniGUI packages and create the required BPL files.

 

To do this go to uniGUI installation folder:

 

 

 

In above folder you can see batch files starting with "Buildlib". For each installed version of C++ Builder a batch file is created during installation.

By running this batch files you can create automatically create BPL files. There are also separate batch files to create 64-bit BPL files for Delphi version which support Win64 platform. For IDE you only need to build 32-bit BPL files. 64-bit BPL files are only needed if you want to deploy your application with 64-bit runtime packages.

 

 

You should be able to see Build succeeded message for each uniGUI package in the batch file.

 

At this step open C++ Builder IDE. Here we use C++ Builder 10.2 for demonstration.

In top menu choose Component->Install Packages.

In below windows press Add button.

 

 

Point to default BPL folder for your C++ Builder version. For example for 10.2 Tokyo below is the default folder:

 

 

 

 

You should install below design packages: ( You can select multiple files )

 

uSynEdit_DXXXX.bpl
uniGUIXXdcl.bpl
uniGUIXXChartdcl.pbl ( Starting from build 1597 this package is no longer available )
uniGUIXXmdcl.bpl

 

This will complete your uniGUI installation for C++ Builder IDE.

 

In future uniGUI versions we will try to improve installation user experience further and automate many of these tasks.

---

## 10. Bypassing Installer BDS check

### Installation > Installation Instructions > Bypassing Installer BDS check

来源: https://www.unigui.com/doc/online_help/suppressing-bds-check.htm

#### 章节标题

  - Bypassing Installer BDS check
  - Bypassing Installer BDS check

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation > Installation Instructions >
   
      Bypassing Installer BDS check |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Bypassing Installer BDS check
	  

Normally uniGUI installer will check for a running instance Delphi before starting installation. If a Delphi instance is running the installer will not allow to go the next step unless BDS instance(s) are closed.

You cay bypass this by using -BDS switch and running the installer from a command line. This will allow you to install uniGUI even if a BDS (Delphi) instance is running.

 

Warning: uniGUI installer will apply several changes to Delphi registry settings. Those setting won't become effective unless Delphi is re-started. Use this switch at your own risk.

---

## 11. Building 64-bit library files

### Installation > Installation Instructions > Building 64-bit library files

来源: https://www.unigui.com/doc/online_help/building-64-bit-library-files.htm

#### 章节标题

  - Building 64-bit library files
  - Building 64-bit library files

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation > Installation Instructions >
   
      Building 64-bit library files |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Building 64-bit library files
	  

As we have already described in section C++ Builder (Without RAD Studio), you can build uniGUI library files (including C++ related object and header files) using batch files. These batch files are under uniGUI installation folder.

 

 

 

These batch files can be used to generate library files for both Win32 and Win64 platforms. Especially, if you intend to deploy Win64 applications along with Delphi Runtime Packages. (Both C++ Builder and Delphi)

Generating library files using  batch files is quite easy. Simply run the correct batch file for the Delphi version you want to create library files. The only prerequisite is to run Delphi or C++ IDE once after installing uniGUI. Otherwise msbuild may fail to find some of the related paths that are needed to find source files or DCU files.

 

A successful build should be free on any errors and generate an output screen like below:

 

 

Generated BPL files can be found in default RAD Studio library path. In below image these are 64-bit BPL files for Delphi 12.0.

 

 

Note:  Starting from build 1597 uniGUIxxChart packages are no longer available. Chart components are included in uniGUIxx packages.

 

 

---

## 12. Silent Installation of Runtime Packages

### Installation > Silent Installation of Runtime Packages

来源: https://www.unigui.com/doc/online_help/silent-installation-of-runtime.htm

#### 章节标题

  - Silent Installation of Runtime Packages
  - Silent Installation of Runtime Packages

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation >
   
      Silent Installation of Runtime Packages |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Silent Installation of Runtime Packages
	  

 

You can use /SILENT or /VERYSILENT command line parameters to silently install Runtime packages. uniGUI installers are built with Inno Setup , so below command line options can be applied:

 

 

/SILENT, /VERYSILENT

 

Instructs Setup to be silent or very silent. When Setup is silent the wizard and the background window are not displayed but the installation progress window is. When a setup is very silent this installation progress window is not displayed. Everything else is normal so for example error messages during installation are displayed and the startup prompt is (if you haven't disabled it with DisableStartupPrompt or the '/SP-' command line option explained above).

 

http://www.jrsoftware.org/ishelp/index.php?topic=setupcmdline

---

## 13. Sencha Touch Installation

### Installation > Sencha Touch Installation

来源: https://www.unigui.com/doc/online_help/sencha_touch_installation.htm

#### 章节标题

  - Sencha Touch Installation
  - Sencha Touch Installation

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation >
   
      Sencha Touch Installation |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Sencha Touch Installation
	  

Note: This step is only required for uniGUI Plus Edition. For other editions, you can skip this step.

Note: This step is only required for uniGUI Plus Edition until build 1425. For builds after 1425 with Ext JS 6.5 and further, Sencha Touch is not needed.

 

uniGUI Plus with Sencha Touch does not install Sencha Touch files. uniGUI Complete is the edition which deploys Sencha Touch.

 

You must download it from the Sencha Touch web site.

 

Here are the instructions:

 

Please download Sencha Touch from here. What you need from the package is the folder named touch-2.4.2, which will be extracted under touch-2.4.2-commercial folder.

 

You must copy touch-2.4.2 folder to the same location where Sencha Ext JS resides.

 

For example, if your folder structure looks like:

 

..\uniGUI\Dcu

..\uniGUI\Demos

..\uniGUI\ext-4.2.2.1144

 

You must copy touch-2.4.2 folder to ..\uniGUI.

 

The final structure should look like this:

 

..\uniGUI\Dcu

..\uniGUI\Demos

..\uniGUI\ext-4.2.2.1144

..\uniGUI\touch-2.4.2

---

## 14. Running Demos

### Installation > Running Demos

来源: https://www.unigui.com/doc/online_help/running_demos.htm

#### 章节标题

  - Running Demos
  - Running Demos

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Installation >
   
      Running Demos |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Running Demos
	  

Demos are a good place to start and become familiar with uniGUI's basics quickly. Fortunately, uniGUI comes with plenty of example projects which demonstrate all aspects of uniGUI, including standard and advanced features. Almost all uniGUI demos are compatible with all supported versions of Delphi. A few demos may not compile on earlier versions of Delphi because of language incompatibilities and lack of new features introduced in newer versions of Delphi. Running demos is a straightforward task almost identical to running any VCL application (except that the uniGUI application will run inside a browser).

 

To run a demo in the Delphi IDE, go to File->Open and look for the location of the uniGUI demos. The default location is under <install folder>\FMSoft\Framework\uniGUI\Demos\...

 

Select the demo folder named AllFeaturesDemo and open the project mdemo.dpr.

 

 

In the IDE, select Project->Build mdemo and build the project. After a successful build, press Run and you will notice a new icon on the system tray. 

 

At this stage, a firewall warning may appear on the desktop asking for permission to allow the uniGUI application to listen to its dedicated port. Please grant the required permission to firewall.

 

Now, in order to run a Web session, please open one of the compatible browsers such as FireFox, Chrome, IE9+, Edge, Safari, or Opera.

 

In the browser address bar, type the following URL:

 

http://localhost:8077

 

uniGUI application running

 

You can terminate the running application server by right-clicking on its tray icon and selecting shutdown from the pop-up menu.

 

 

If your uniGUI edition supports touch applications, you can run mobile/touch demos by following the same steps but selecting demos from a different folder.

 

This time please select and open mdemo.dpr from ..\Touch\AllFeatures.

 

 

You can open Mainm.pas in the IDE to see how the mobile designer looks in the IDE. It looks a bit different than the standard Form designer to mimic the look and feel of a mobile device.

 

uniGUI Mobile Web application in IDE

 

 

Now you can run the new application by building and running the selected project.

 

Again, a new tray icon will appear.

 

You can test or debug a mobile Web session in an ordinary desktop browser or directly run it on a mobile device. On the desktop, you need a fully HTML5 compatible browser. Fortunately all modern browsers come with extensive support for HTML5.

 

In the browser address bar, type the previous URL:

 

http://localhost:8077

 

You will notice that the address will be automatically redirected to a new address:

 

http://localhost:8077/m

 

 

uniGUI mobile app in Google Chrome browser

 

You can also run it on a mobile device by simply opening a browser window and typing a proper address. This time, you need to enter the IP address of the PC running the demo, and also make sure your mobile device and PC are connected to the same LAN.

 

uniGUI web application running on a smartphone

---

## 15. Technology Overview

### Technology Overview

来源: https://www.unigui.com/doc/online_help/technology_overview.htm

#### 章节标题

  - Technology Overview
  - Technology Overview

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      »No topics above this level«
      
   
      Technology Overview |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Technology Overview
	  

It is a known fact that Web applications are replacing the old desktop applications. A Web application is accessible from any modern web browser without deploying anything to the client device, it is much easier to update, there are many advantages. But achieving the same user interface and responsiveness provided by a desktop application on the Web was almost impossible or unfeasible until a few years ago.

 

The first attempt to bring the desktop user experience to the Web, Rich Internet Application (RIA), required the installation of a local run-time framework or plug-in on the client computer. Microsoft Silverlight, Microsoft WPF XAML Browser Applications, Flash, are some examples of this generation. Most of these technologies are now deprecated.

 

Currently, thanks to the advances in Web technology like HTML 5, AJAX, and powerful JavaScript libraries, there is a new concept, Single-Page Application (SPA). In many ways, it is similar to a desktop Single Document Interface (SDI) which uses a single window/page as the user interface and updates it dynamically according to the user actions.

 

uniGUI is a Web application framework capable of creating and deploying stateful Single-Page Applications.

 

What makes uniGUI unique is that it looks natural to any Delphi user, as simple as using any other component library in the Delphi marketplace. Behind the scenes, many things must happen to make the SPA work.

 

It is possible to create a uniGUI SPA with its own Web HTTP Server, or just an ISAPI module which will need an ISAPI Handler for answering the requests from the host Web server. But for any SPA, it is necessary to handle some typical tasks as part of the uniGUI Web Application framework:

 

1.Server singleton

2.User Sessions

3.Login form

4.Main form

5.Automatic and dynamic generation of the JavaScript code for rendering the forms in the client browser

6.Automatic handling of AJAX calls between each client and the server

 

uniGUI relies on the well known Sencha Ext JS JavaScript library for all client-side tasks. Thanks to Ext JS, uniGUI generates a high-end, visually perfect, and fully AJAX-enabled Web front-end.

 

While it is possible to create a uniGUI SPA without knowing anything about JavaScript or Sencha Ext JS, uniGUI allows to take advantage of JavaScript for writing client-side event handlers for the Ext JS controls. This advanced feature allows developers to execute interactions between client-side screen elements without communicating with the server. It is also possible to send AJAX requests to the server.

 

A uniGUI  application can be considered as a standard Delphi VCL application which uses a Web browser as its presentation layer. uniGUI enables developers to create, design, and debug their Delphi applications as they develop regular desktop applications, and allows them to choose any of the available options for Web deployment. This means that a Delphi developer with little knowledge about Web technologies can start developing a Web application using uniGUI out of the box.

---

## 16. Unified GUI

### Technology Overview > Unified GUI

来源: https://www.unigui.com/doc/online_help/unified_gui.htm

#### 章节标题

  - Unified GUI
  - Unified GUI

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview >
   
      Unified GUI |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Unified GUI
	  

uniGUI stands for Unified Graphical User Interface or Unified GUI in short. It is called unified because it provides the same UI experience in all devices with a Web browser. Regardless of the device, OS, CPU, and display, the user experience will be the same on all devices with a compatible Web browser. It allows great freedom in choosing client devices. Client devices can be Windows PC, OSX devices, Linux PC, smart phones, tablets, or even a Raspberry Pi!

 

Of course, this feature is not something unique to uniGUI. This level of platform independence is something that any Web application can provide, except that uniGUI enables you to create Web applications which are very close to desktop applications in their look and feel.

 

---

## 17. uniGUI Application Architecture

### Technology Overview > uniGUI Application Architecture

来源: https://www.unigui.com/doc/online_help/unigui_application_architecture.htm

#### 章节标题

  - uniGUI Application Architecture
  - uniGUI Application Architecture

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview >
   
      uniGUI Application Architecture |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

uniGUI Application Architecture
	  

The following diagram represents the internal structure of a uniGUI server. Each uniGUI server has a single copy of ServerModule, which is created once per server, along with multiple sessions, which are dynamically created and destroyed according to user activity. A uniGUI session contains a specialized DataModule called MainModule, which is automatically created for each session. It also contains a Form named MainForm, which is the main entry point for the Web application. If the project contains a LoginForm, it will be activated before the MainForm to provide a reliable and secure way for user login. As expected, each session can contain several additional DataModules and Forms.

 

Each time a user opens a new instance of the Web application, the server creates a new session. A session will remain active until the user logs out, closes the browser/tab, or it times out. Each session keeps a complete state of the running Web application so that uniGUI sessions are called stateful. You can consider each session as a private copy of your Web application, which co-exists with other sessions in the server address space but is isolated from all others. The server creates each session with a unique "Session Id", which it uses for correctly associating client requests with sessions (the Session Id is always part of the AJAX requests).

 

If the uniGUI application is just an ISAPI module, the running server will instantiate one ISAPI Handler. If there is no Web server, the running server will enable its internal Web server. In both cases, all the requests to the active Web server will eventually go to the correct session.

.

---

## 18. Deployment Options

### Technology Overview > Deployment Options

来源: https://www.unigui.com/doc/online_help/deployment_options.htm

#### 章节标题

  - Deployment Options
  - Deployment Options

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview >
   
      Deployment Options |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Deployment Options
	  

uniGUI supports all major deployment options available for the Windows platform.

 

1.Standalone Server

The simplest method of deployment is Standalone Server. In this mode, the application server runs directly like a desktop application. It is also the mode used for debugging the application. After running the application executable, it will minimize itself to the tray icon and will run until manually terminated by user. See the picture below:

                                                     

uniGUI Standalone Server

 

A standalone application can be accessed from the browser by simply typing:

 

 http://localhost:8077

 

Where 8077 is the dedicated port number which your application is bound to (listening port). It can easily be modified in the ServerModule.

 

Standalone mode is only recommended for debugging purposes. Since it runs as a desktop application it will be terminated as soon as the current user is logged off. Also, it will not start automatically after a restart. This mode is best for debugging purposes. When your app runs in debug mode, you can set breakpoints, pause, go to cursor, and use all other advanced debugging features of the Delphi IDE to debug your application, just like any other VCL application. This method is not recommended for production environments, as it does not automatically run when the OS restarts. Also, it can be easily terminated by an unauthorized user intervention.

 

2. Windows Service

Another deployment method is Windows Service. By creating a uniGUI Windows Service application, you can deploy your application as a standard Windows Service application. This method is one of the preferred methods for production environments. Windows Services will run automatically each time the system restarts. It will guarantee the availability expected from a Web application. A Windows Service application can be accessed from a browser like a Standalone server described above, meaning that each Windows Service application requires a dedicated port.

 

3. ISAPI Module

The last available deployment option is ISAPI Module. That technology was introduced by Microsoft IIS server. It is available from early versions of IIS and it is based on Windows DLL technology. There are other web servers such as Apache, which also support loading ISAPI modules. ISAPI modules differs from the previous options discussed above in many aspects. The most important, it does not contain a built-in Web server as opposed to Standalone Service and Windows Service. In ISAPI mode, IIS server is the HTTP server and the ISAPI module executes its requests. You can easily create an ISAPI module application using uniGUI Wizards in the Delphi IDE. Compiling an ISAPI uniGUI application will output a DLL file instead of an EXE file.This DLL file must be deployed to IIS server (described in detail in section ISAPI Module under Web Deployment section). uniGUI DLLs support all IIS versions starting from IIS 5.1. ISAPI modules gives developers the freedom of deploying many modules in the same server without a need to choose a different port for each application. It also inherit the benefits of all advanced security features available in Microsoft IIS.

 

Running an ISAPI application is as easy as opening the following URL in your browser:

 

 http://localhost/appdir/app.dll

 

If you have multiple apps under the same folder, you can call them by simply specifying a different DLL name:

 

 http://localhost/appdir/app.dll

 http://localhost/appdir/app2.dll

 http://localhost/appdir/appaccount.dll

 

---

## 19. Forms and Modules

### Technology Overview > Forms and Modules

来源: https://www.unigui.com/doc/online_help/application_components.htm

#### 章节标题

  - Forms and Modules
  - Forms and Modules

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview >
   
      Forms and Modules |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Forms and Modules
	  

Every uniGUI application is created with a specialized form named MainForm and two data modules, MainModule and ServerModule. The LoginForm has also a special meaning in uniGUI .

---

## 20. ServerModule

### Technology Overview > Forms and Modules > ServerModule

来源: https://www.unigui.com/doc/online_help/server_module.htm

#### 章节标题

  - ServerModule
  - ServerModule

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      ServerModule |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

ServerModule
	  

uniGUI ServerModule

 

Each uniGUI application contains a special data module named ServerModule, which is the core module of the application. It is a singleton, which means that it is created only once per application. It is mainly used to configure various server settings. ServerModule will be covered in more detail in other sections.

 

 

---

## 21. MainModule

### Technology Overview > Forms and Modules > MainModule

来源: https://www.unigui.com/doc/online_help/main_module.htm

#### 章节标题

  - MainModule
  - MainModule

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      MainModule |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

MainModule
	  

Application MainModule

 

MainModule can be considered the heart of a session. It is a special purpose DataModule which is automatically created and added to the project each time a new project is created. MainModule has many important roles in a uniGUI application. Some of these roles are not visible to the developers. For developers, MainModule can be used to place resources shared by a session, such as database connections, shared variables, etc. For example, you can declare public variables in MainModule's public section and then access them from other forms in the session. The following example demonstrates a common practice in uniGUI to share data among various forms in a session. Since each session has its private copy of MainModule, it will be ensured that each form will access its private set of data in its session.

 

  TUniMainModule = class(TUniGUIMainModule)
  private
    { Private declarations }
  public
    { Public declarations }
    aUserName, aPassword: string;
  end;

 

Later, you can access these variables from other forms in application:

 

procedure TMainForm.UniButton1Click(Sender: TObject);
begin
  UniLabel1.Caption :=

    UniMainModule.aUserName +

    ' ' +

    UniMainModule.aPassword;
end;

 

Also see uniGUI Application Architecture.

---

## 22. LoginForm

### Technology Overview > Forms and Modules > LoginForm

来源: https://www.unigui.com/doc/online_help/login-form.htm

#### 章节标题

  - LoginForm
  - LoginForm

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      LoginForm |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

LoginForm
	  

LoginForm is another special form type which is solely used for login purposes. If your application contains a LoginForm (any form inheriting from TUniLoginForm), it will be the first form displayed when a Web session starts. A LoginForm can be created with a uniGUI Wizard by following this path: File->New->Other->Delphi Projects->uniGUI for Delphi->Form.

 

uniGUI Wizard

     

Create a Login Form

 

This action will create a blank LoginForm which looks identical to a regular form:

 

A blank LoginForm

 

Sample LoginForm design

 

A LoginForm is a descendant of a built-in class named TUniLoginForm. Each application can only have one LoginForm. After adding a LoginForm, your application will show this form when a new session starts. You need to add controls, event handlers, everything you need, to implement the required functionality. Login behavior is controlled using form's ModalResult. If LoginForm returns mrOK, it means a successful login, and a new MainForm will be created and activated. When ModalResult returns mrCancel, it will terminate the session. If we use a fake form with just two buttons (one for successful login and other for failure) the following code will do it:

 

procedure TUniLoginForm1.UniButton1Click(Sender: TObject);
begin
  ModalResult := mrOK;  // Login is valid so proceed to MainForm
end;
 
procedure TUniLoginForm1.UniButton2Click(Sender: TObject);
begin
  ModalResult := mrCancel; // Invalid Login exit from app
end;

 

Once the user is logged in and MainForm is displayed, there are two ways to terminate the session. You can terminate the session and return to LoginForm by returning mrOK as ModalResult or terminate the session by returning mrCancel. For security reasons, the existing session is always terminated before displaying the LoginForm, i.e. each new login starts a new session.

 

 

---

## 23. MainForm

### Technology Overview > Forms and Modules > MainForm

来源: https://www.unigui.com/doc/online_help/main_form.htm

#### 章节标题

  - MainForm
  - MainForm

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      MainForm |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

MainForm
	  

MainForm is the single form implementing the SPA which is created and shown after a successful login (or if no LoginForm exists). In general, MainForm is the Application Form used to navigate to other forms using menus or other navigation tools. MainForm is automatically created when a new project is created. Each Web session has its own private copy of MainForm and closing a MainForm will terminate the session.

 

A blank MainForm

 

MainForm is registered in the initialization section of the unit so that uniGUI can distinguish it from other forms.

 

initialization
  RegisterAppFormClass(TMainForm);
 
end.

---

## 24. Other Forms

### Technology Overview > Forms and Modules > Other Forms

来源: https://www.unigui.com/doc/online_help/other-forms.htm

#### 章节标题

  - Other Forms
  - Other Forms

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      Other Forms |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Other Forms
	  

The uniGUI Wizard for creating new forms allows to create three kind of forms:

 

•Login Form (inheriting from TUniLoginForm)

•Application Form

•Free Form

 

There are a few differences between the Application Form and Free Form.

 

---

## 25. Application Form

### Technology Overview > Forms and Modules > Other Forms > Application Form

来源: https://www.unigui.com/doc/online_help/application-forms.htm

#### 章节标题

  - Application Form
  - Application Form
  - Using Application Form's global function

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules > Other Forms >
   
      Application Form |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Application Form
	  

This is the auto-generated code for an Application Form (already renamed):

 

unit _AppForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm;
 
type
  TAppForm = class(TUniForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function AppForm: TAppForm;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function AppForm: TAppForm;
begin
  Result := TAppForm(UniMainModule.GetFormInstance(TAppForm));
end;
 
end.

 

Instead of a variable like:

 

var
  AppForm : TAppForm;

 

which is the standard code generated for a VCL form, the Wizard generated a function with the same name and type.

 

The original variable was global in scope, useless in a multi-user environment.

 

The new function request the instance from the session UniMainModule, automatically making the form local to each session.

 

But the function keeps the original intent of the VCL variable, each session will always access only one instance of that form (it is a singleton per session).

 

The function is also smart enough to manage the lifetime of the form:

 

•It will create the form if it doesn't exist

•If the form is closed, it will be freed and will get unregistered from the managed form list. (Property FreeOnClose = True)

•It will be returned immediately if it already exist.

 

 

Using Application Form's global function

 

uniGUI forms are dynamic objects and framework automatically allocates and disposes them.  As described above each uniGUI application form is associated with a function which will create/return an instance of that form. Main purpose of providing this function was to provide syntax compatibility between VCL and uniGUI. In the VCL all of your forms are automatically created and all form global variables are initiated when your application is started. In VCL you can easily use your form by simply writing this simple syntax:

 

Form1.Show;

 

Likewise in uniGUI we have provided a handy syntax similar to above to allow you access your forms:

 

UniForm1.Show;

 

It must be reminded that in above code UniForm1 is a function not a variable. It returns the correct instance of Form for current session or it will create a new instance if an instance is not already created.

Let me restate that this function is provided to perform certain tasks only and it should not be treated as a global variable because it is not a variable in the first place.

This global function should must be used only when you want to instantiate and display a uniGUI form:

 

UniForm1.Caption := 'New Caption';   // A new form instance is created and Caption is assigned a new value
UniForm1.Show;                       // Show function is called for form instance created a previous line

 

Another important detail is that uniGUI forms must be shown as soon as they are created. It is not possible to create a form in one event and show it in another. If you attempt doing this uniGUI will automatically show the form if you do not call Show or ShowModal explicitly.

 

 

Incorrect usage:

 

procedure TMainForm.UniButton4Click(Sender: TObject);
begin
  UniForm1.Caption := 'New Caption';
end;

 

Correct usage:

 

procedure TMainForm.UniButton4Click(Sender: TObject);
begin
  UniForm1.Caption := 'New Caption';
  UniForm1.Show; // Show must be called
end;

 

It must be avoided to to use a form instance inside a datamodule unless it is used to create and show that form as demonstrated above.

You must avoid accessing form's public variables from a datamodule or another form. All of these are against good OOP design rules anyway.

 

Forms must not be used to store application global variables or data components such as connections which will be used by other forms and datamodules.  Each form must be considered as an atomic element of your application which will hold its own private variables for its own internal usage. If you want to define public variables for a session then you must MainModule or other datamodules for this purpose.

 

For instance in below code a label in a form is used to display a field data. As we stated above such usage of form must be avoided.

 

procedure TDataModule2.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  UniForm1.UniLabel1.Caption := Field.DisplayText;  // incorrect usage, form function should not be directly used inside an event handler of a component which belongs to another form/module
end;

 

Instead you can resolve this by simply using a data aware control such as TUniDBText and connecting it to a data source.

 

Another solution to above problem is to place a TDataSource component directly on form and use its event to update form's visual elements.

 

Here rule of thumb is to avoid updating a form's visual elements from event handlers of other components which does not belong to that form.

 

The only exception to above rule is that when you are completely in control of a specific form's lifetime. i.e. you explicitly create and destroy it in your own code.

 

 

 

 

---

## 26. Free Form

### Technology Overview > Forms and Modules > Other Forms > Free Form

来源: https://www.unigui.com/doc/online_help/free-form.htm

#### 章节标题

  - Free Form
  - Free Form

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules > Other Forms >
   
      Free Form |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Free Form
	  

This is the auto-generated code for a free form (already renamed):

 

unit _FreeForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm;
 
type
  TFreeForm = class(TUniForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
implementation
 
uses
  uniGUIApplication;
 
{$R *.dfm}
 
end.

 

The main difference between this free form and an application form is the absence of the function, the equivalent of the VCL global variable.

 

But the important difference is that, by requesting a free form, the user is planning to do things which are not possible with an application form:

 

•It will be possible to create several instances of the form (for example, leaving several non-modal forms on the screen showing different records of a dataset)

•The user will have tighter control over the form lifetime.

 

The next example shows the same form, but modified to capture a text as a modal form:

 

unit _FreeForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniButton, uniGUIBaseClasses, uniEdit;
 
type
  TFreeForm = class(TUniForm)
    edtText: TUniEdit;
    btnOk: TUniButton;
    btnCancel: TUniButton;
  private
    function GetText: string;
  public
    property Text : string read GetText;
  end;
 
  function GetText : string;
 
implementation
 
uses
  uniGUIApplication;
 
{$R *.dfm}
 
function GetText : string;
var
  frm : TFreeForm;
begin
  frm := TFreeForm.Create(uniGUIApplication.UniApplication);
 
  if frm.ShowModal = mrOk then
    Result := frm.Text
  else
    Result := ''; 
end;
 
{ TFreeForm }
 
function TFreeForm.GetText: string;
begin
  Result := edtText.Text;
end;
 
end.

 

The owner of the free form is not the global application, but the instance handling the current session.

Notice also that the form (frm) is automatically released (FreeOnClose is true and a value was assigned to ModalResult).

The variable itself will be released after going out-of-scope (when exiting the function GetText).

 

Free forms are convenient when the user is interested in services like GetText instead of on the form. If that is the case, the form will always be created and released as part of the service implementation and shouldn't be exposed to the rest of the program. What the program is expecting is just the service.

 

---

## 27. DataModules

### Technology Overview > Forms and Modules > DataModules

来源: https://www.unigui.com/doc/online_help/data_modules.htm

#### 章节标题

  - DataModules
  - DataModules

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      DataModules |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

DataModules
	  

uniGUI supports adding DataModules to the project. It allows developers to design their app like a standard VCL application, dividing the application business logic among several DataModules. The important thing to remember is that while uniGUI DataModules are identical to standard VCL DataModules in nature, when they are created using the uniGUI wizard, they will be managed automatically for each session (its lifetime will be the same as the session itself). If the DataModule is created using the standard IDE, it is the responsibility of the developer to create and release it when appropriate.

 

Using uniGUI wizard to create a new DataModule

 

There are two types of DataModules in uniGUI. Application DataModule and Free DataModule.

---

## 28. Application DataModule

### Technology Overview > Forms and Modules > DataModules > Application DataModule

来源: https://www.unigui.com/doc/online_help/application-datamodule.htm

#### 章节标题

  - Application DataModule
  - Application DataModule

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules > DataModules >
   
      Application DataModule |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Application DataModule
	  

An application datamodule is a datamodule which gets additional support by the uniGUI run-time:

 

•it is registered with the uniGUI run-time during the application initialization

•it is created at the beginning of each session, or on-demand (according to the property MainModule.ApplicationDataModuleOptions.CreateOnDemand)

•if not released by the user (using Free), it is automatically released when closing the session

 

 

Small applications requiring additional datamodules (that is, more than the MainModule), will probably use the default (CreateOnDemand = False), but big applications will enjoy better memory management creating the datamodules on-demand (and releasing them as soon as possible).

 

This is the auto-generated code for an Application DataModule:

 

unit _AppDM1;
 
interface
 
uses
  SysUtils, Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.StorageBin;
 
type
  TAppDM1 = class(TDataModule)
    tblList: TFDMemTable;
    tblListID: TAutoIncField;
    tblListText: TStringField;
    dsList: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function AppDM1: TAppDM1;
 
implementation
 
{$R *.dfm}
 
uses
  UniGUIVars, uniGUIMainModule, MainModule;
 

// This function returns an instance of TAppDM1 datamodule.

// When MainModule.ApplicationDataModuleOptions.CreateOnDemand is true and datamodule instance is not created yet, 

// this function will create an instance and will return it otherwise it will return the previously created instance.

// When MainModule.ApplicationDataModuleOptions.CreateOnDemand is false this function will return same instance of datamodule which is created when session is started.
function AppDM1: TAppDM1;
begin
  Result := TAppDM1(UniMainModule.GetModuleInstance(TAppDM1));
end;
 
initialization
  RegisterModuleClass(TAppDM1);
 
end.

 

Notice how similar this code is to the Application Form.

 

If the parameter CreateOnDemand is changed to true, let's show how a form will use the application datamodule.

 

unit _TestForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm,
  _AppDM1, uniGUIBaseClasses, uniBasicGrid, uniDBGrid;
 
type
  TTestForm = class(TUniForm)
    UniDBGrid1: TUniDBGrid;
    procedure UniFormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function TestForm: TTestForm;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function TestForm: TTestForm;
begin
  Result := TTestForm(UniMainModule.GetFormInstance(TTestForm));
end;
 
procedure TTestForm.UniFormDestroy(Sender: TObject);
begin
  AppDM1.Free; // this code is optional. it can be used to free resources when associated form is freed and datamodule is no longer needed.

               // you should not call this method if datamodule is re-used several times or it is used by several other forms in the same session
               // if Free is not called here, datamodule will be freed when session is terminated.

end;
 
end.

 

The datamodule is explicitly released when destroying the form (that is, as soon as the form does not need it anymore). But there is no code linking the UniDBGrid to the datamodule. Let's take a look at the DFM file:

 

object TestForm: TTestForm
  Left = 0
  Top = 0
  ClientHeight = 246
  ClientWidth = 477
  Caption = 'Test (using App DM On Demand)'
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  OnDestroy = UniFormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object UniDBGrid1: TUniDBGrid
    Left = 0
    Top = 0
    Width = 477
    Height = 246
    Hint = ''
    DataSource = AppDM1.dsList
    LoadMask.Message = 'Loading data...'
    Align = alClient
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
end

 

The link is also visible in the form designer:

 

 

The datasource was linked at design-time to the datamodule. There is no need to do it at run-time.

 

Running the application proof that it is indeed working without memory leaks.

 

 

 

---

## 29. Free DataModule

### Technology Overview > Forms and Modules > DataModules > Free DataModule

来源: https://www.unigui.com/doc/online_help/free-datamodule.htm

#### 章节标题

  - Free DataModule
  - Free DataModule

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules > DataModules >
   
      Free DataModule |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Free DataModule
	  

A free datamodule is just a plain old datamodule.

 

unit _FreeDataModule;
 
interface
 
uses
  SysUtils, Classes;
 
type
  TFreeDataModule = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
implementation
 
{$R *.dfm}
 
 
end.

 

This kind of datamodule is used in the same way it was used in common VCL applications. The user is totally responsible of creating it when needed, and of releasing it as soon as is not needed anymore.

 

The reason for using this kind of datamodule comes from the fact that some non-visual components need a host/container (or it is easier to use them in that way). One good example is a reporting tool because it is usually dropped into a datamodule even if the user will only use it for exporting the report.

 

An additional reason for using datamodules is that no "business code" should be hosted in the presentation layer (TForm, TUniForm, any form). Using a free datamodule allows the developer to handle resources on-demand, keeping memory usage to a minimum.

 

Usage of free datamodule is demonstrated in FastReport and ReportBuilder demos which are available under ..\demos\desktop folder.

 

---

## 30. Frames

### Technology Overview > Forms and Modules > Frames

来源: https://www.unigui.com/doc/online_help/frames.htm

#### 章节标题

  - Frames
  - Frames

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      Frames |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Frames
	  

uniGUI has complete support for frames. Frames must be created using the uniGUI IDE wizard.

 

Using uniGUI wizard to create a new Frame

 

An empty uniGUI Frame

---

## 31. ServiceModule

### Technology Overview > Forms and Modules > ServiceModule

来源: https://www.unigui.com/doc/online_help/servicemodule.htm

#### 章节标题

  - ServiceModule
  - ServiceModule

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      ServiceModule |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

ServiceModule
	  

A ServiceModule is only created when the project type is Windows Service. It is a descendant of Delphi's standard TService class. It allows to configure Windows Service related parameters including service name, service type, etc.

---

## 32. Components

### Technology Overview > Forms and Modules > Components

来源: https://www.unigui.com/doc/online_help/components.htm

#### 章节标题

  - Components
  - Components

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules >
   
      Components |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Components
	  

As Delphi itself, uniGUI offers a similar set of non-visual and visual components. Some of the Delphi components are compatible or supported by uniGUI, making unnecessary to include them as part of the uniGUI packages. For example, many data access controls are the same for VCL and uniGUI applications. Other components, like the TActionList, are supported by uniGUI.

 

uniGUI visual controls are Ext JS controls (or are made with), which typically offer a superset of the equivalent VCL controls. Sometimes, the functionality of the uniGUI control is closer to a powerful 3rd-party control (like a DevExpress or TMS control) than to the original VCL control.

 

The next sections will help developers to choose the correct uniGUI controls based on their previous experience with Delphi and the VCL control palette.

---

## 33. Standard

### Technology Overview > Forms and Modules > Components > Standard

来源: https://www.unigui.com/doc/online_help/standard.htm

#### 章节标题

  - Standard
  - Standard

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules > Components >
   
      Standard |  |
| --- | --- |

**表格 2:**

| VCL | uniGUI | Notes |
| --- | --- | --- |
| TCheckBox | TUniCheckBox |  |
| TComboBox | TUniComboBox |  |
| TEdit | TUniEdit
TUniNumberEdit
TUniFormattedNumberEdit |  |
| TLabel | TUniLabel |  |
| TMemo | TUniMemo |  |
| TPanel | TUniPanel (equivalent to TPanel)
TUniSimplePanel (simpler TUniPanel)
TUniHiddenPanel (invisible container)
TUniContainerPanel (visible generic container)
TUniFieldSet (set of fields with several automatic layout configurations)
TUniFieldContainer (visible field container) | Ext JS panels provide many more alignment options than TPanel.
FieldSets and FieldContainers can create trees by containing each other |
| Win32.TTabControl | TUniTabControl |  |
| Win32.TToolBar | TUniToolBar |  |
| Win32.TTreeView | TUniTreeView |  |
| Win32.TStatusBar | TUniStatusBar | ` |
| System.TTimer | TUniTimer | TTimer will not work in uniGUI |
| TRadioGroup | TUniRadioGroup |  |
| TRadioButton | TUniRadioButton |  |
| Win32.TProgressBar | TUniProgressBar |  |
| TButton | TUniButton |  |
| TStringGrid | TUniStringGrid |  |
| Samples.TSpinEdit | TUniSpinEdit |  |
| Win32.TPageControl | TUniPageControl |  |
| TMainMenu | TUniMainMenu |  |
| TGroupBox | TUniGroupBox |  |
| TListBox | TUniListBox |  |
| Win32.TImageList | TUniImageList (deprecated)
TUniNativeImageList (latest equivalent to TImageList)
TUniImageListAdapter (used for adapting a uniGUI ImageList to TImageList) |  |
| TActionList |  | Supported. Use TUniImageListAdapter as its TImageList |

#### 详细内容

<< Click to Display Table of Contents >>

Standard
	  

uniGUI standard controls provide equivalent controls from several Delphi palettes: System, Win32, TeeChart, Standard, Additional, and Samples.

 

VCL

	

uniGUI

	

Notes




TCheckBox

	

TUniCheckBox

	

 




TComboBox

	

TUniComboBox

	

 




TEdit

	

TUniEdit

TUniNumberEdit

TUniFormattedNumberEdit

	

 




TLabel

	

TUniLabel

	

 




TMemo

	

TUniMemo

	

 




TPanel

	

TUniPanel (equivalent to TPanel)

TUniSimplePanel (simpler TUniPanel)

TUniHiddenPanel (invisible container)

TUniContainerPanel (visible generic container)

TUniFieldSet (set of fields with several automatic layout configurations)

TUniFieldContainer (visible field container)

	

Ext JS panels provide many more alignment options than TPanel.

FieldSets and FieldContainers can create trees by containing each other




Win32.TTabControl

	

TUniTabControl

	

 




Win32.TToolBar

	

TUniToolBar

	

 




Win32.TTreeView

	

TUniTreeView

	

 




Win32.TStatusBar

	

TUniStatusBar

	

`




System.TTimer

	

TUniTimer

	

TTimer will not work in uniGUI




TRadioGroup

	

TUniRadioGroup

	

 




TRadioButton

	

TUniRadioButton

	

 




Win32.TProgressBar

	

TUniProgressBar

	

 




TButton

	

TUniButton

	

 




TStringGrid

	

TUniStringGrid

	

 




Samples.TSpinEdit

	

TUniSpinEdit

	

 




Win32.TPageControl

	

TUniPageControl

	

 




TMainMenu

	

TUniMainMenu

	

 




TGroupBox

	

TUniGroupBox

	

 




TListBox

	

TUniListBox

	

 




Win32.TImageList

	

TUniImageList (deprecated)

TUniNativeImageList (latest equivalent to TImageList)

TUniImageListAdapter (used for adapting a uniGUI ImageList to TImageList)

	

 




TActionList

	

 

	

Supported. Use TUniImageListAdapter as its TImageList

 

Notes:

•Use the new TUniNativeImageList instead of the deprecated TUniImageList.

•When a control requires a TImageList, use the TUniImageListAdapter.

•Most of the biggest differences/advantages of Web controls over the standard VCL controls are related to TPanel.

•Never use a TTimer, but the equivalent TUniTimer. If the timer is required for executing server threads, use the Win32 API.

---

## 34. Additional

### Technology Overview > Forms and Modules > Components > Additional

来源: https://www.unigui.com/doc/online_help/additional.htm

#### 章节标题

  - Additional
  - Additional

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules > Components >
   
      Additional |  |
| --- | --- |

**表格 2:**

| VCL | uniGUI | Notes |
| --- | --- | --- |
| TBitBtn | TUniBitBtn |  |
| Win32.TDateTimePicker | TUniDateTimePicker |  |
| TImage | TUniImage |  |
| TSpeedButton | TUniSpeedButton |  |
| Win32.TTrackBar | TUniTrackBar |  |
| TSplitter | TUniSplitter |  |
| TMonthCalendar | TUniCalendar |  |
|  | TUniCalendarDialog |  |
|  | TUniURLFrame |  |
|  | TUniPDFFrame |  |
|  | TUniFileUpload |  |
|  | TUniScreenMask |  |
|  | TUniHTMLFrame |  |
| TPopupMenu | TUniPopupMenu |  |
| Win32.TRichEdit | TUniHTMLMemo | Same goal, incompatible without using a converter |
| TScrollBox | TUniScrollBox |  |
|  | TUniCanvas |  |
|  | TUniMenuButton |  |
| TColorBox | TUniColorPalette |  |
| TeeChart.TButtonColor | TUniColorButton |  |
|  | TUniPropertyGrid |  |
|  | TUniGenericControl | Control implemented with JavaScript, capable of interacting with client-side controls and making Ajax requests to the server |

#### 详细内容

<< Click to Display Table of Contents >>

Additional
	  

This palette provides a few controls not available in Delphi VCL.

 

VCL

	

uniGUI

	

Notes




TBitBtn

	

TUniBitBtn

	

 




Win32.TDateTimePicker

	

TUniDateTimePicker

	

 




TImage

	

TUniImage

	

 




TSpeedButton

	

TUniSpeedButton

	

 




Win32.TTrackBar

	

TUniTrackBar

	

 




TSplitter

	

TUniSplitter

	

 




TMonthCalendar

	

TUniCalendar

	

 




 

	

TUniCalendarDialog

	

 




 

	

TUniURLFrame

	

 




 

	

TUniPDFFrame

	

 




 

	

TUniFileUpload

	

 




 

	

TUniScreenMask

	

 




 

	

TUniHTMLFrame

	

 




TPopupMenu

	

TUniPopupMenu

	

 




Win32.TRichEdit

	

TUniHTMLMemo

	

Same goal, incompatible without using a converter




TScrollBox

	

TUniScrollBox

	

 




 

	

TUniCanvas

	

 




 

	

TUniMenuButton

	

 




TColorBox

	

TUniColorPalette

	

 




TeeChart.TButtonColor

	

TUniColorButton

	

 




 

	

TUniPropertyGrid

	

 




 

	

TUniGenericControl

	

Control implemented with JavaScript, capable of interacting with client-side controls and making Ajax requests to the server

.

Notes:

•New applications should use HTML-based documents instead of the old RTF format.

•It is possible to insert any external URL as a TUniURLFrame, but there is limited control over the embedded frame.

•TUniURLFrame is capable of recognizing and rendering some extensions like .PDF (which provides a default PDF Viewer).

•TUniPDFFrame provides a feature-rich PDF Viewer.

•Check the TUniPropertyGrid, it is surprisingly powerful.

---

## 35. Data Controls

### Technology Overview > Forms and Modules > Components > Data Controls

来源: https://www.unigui.com/doc/online_help/data-controls.htm

#### 章节标题

  - Data Controls
  - Data Controls

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules > Components >
   
      Data Controls |  |
| --- | --- |

**表格 2:**

| VCL | uniGUI | Notes |
| --- | --- | --- |
| TDBEdit | TUniDBEdit |  |
|  | TUniDBNumberEdit |  |
| TDBGrid | TUniDBGrid |  |
| TDBImage | TUniDBImage |  |
| TDBMemo | TUniDBMemo |  |
| TDBRichEdit | TUniDBHTMLMemo | Same goal, incompatible |
| TDBNavigator | TUniDBNavigator |  |
| TDBListBox | TUniDBListBox |  |
|  | TUniDBFormattedNumberEdit |  |
| TDBComboBox | TUniDBComboBox |  |
| TDBCheckBox | TUniDBCheckBox |  |
| TDBText | TUniDBText |  |
| TDBLookupListBox | TUniDBLookupListBox |  |
| TDBLookupComboBox | TUniDBLookupComboBox |  |
|  | TUniDBDateTimePicker |  |
| TDBRadioGroup | TUniDBRadioGroup |  |
|  | TUniDBTreeGrid |  |
|  | TUniDBVerticalGrid |  |
|  | TUniDBVerticalTreeGrid |  |
| TDBCtrlGrid |  |  |

#### 详细内容

<< Click to Display Table of Contents >>

Data Controls
	  

In addition to the VCL data controls, uniGUI also provides the TUniDBTreeGrid, TUniDBVerticalGrid, and TUniDBVerticalTreeGrid.

 

VCL

	

uniGUI

	

Notes




TDBEdit

	

TUniDBEdit

	

 




 

	

TUniDBNumberEdit

	

 




TDBGrid

	

TUniDBGrid

	

 




TDBImage

	

TUniDBImage

	

 




TDBMemo

	

TUniDBMemo

	

 




TDBRichEdit

	

TUniDBHTMLMemo

	

Same goal, incompatible




TDBNavigator

	

TUniDBNavigator

	

 




TDBListBox

	

TUniDBListBox

	

 




 

	

TUniDBFormattedNumberEdit

	

 




TDBComboBox

	

TUniDBComboBox

	

 




TDBCheckBox

	

TUniDBCheckBox

	

 




TDBText

	

TUniDBText

	

 




TDBLookupListBox

	

TUniDBLookupListBox

	

 




TDBLookupComboBox

	

TUniDBLookupComboBox

	

 




 

	

TUniDBDateTimePicker

	

 




TDBRadioGroup

	

TUniDBRadioGroup

	

 




 

	

TUniDBTreeGrid

	

 




 

	

TUniDBVerticalGrid

	

 




 

	

TUniDBVerticalTreeGrid

	

 




TDBCtrlGrid

	

 

	

 

 

Notes:

•In addition to the standard TUniDBGrid, look for the additional grids (much like DevExpress grids).

---

## 36. Extra

### Technology Overview > Forms and Modules > Components > Extra

来源: https://www.unigui.com/doc/online_help/extra.htm

#### 章节标题

  - Extra
  - Extra

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Forms and Modules > Components >
   
      Extra |  |
| --- | --- |

**表格 2:**

| VCL | uniGUI | Notes |
| --- | --- | --- |
|  | TUniSyntaxEdit |  |
|  | TUniSyntaxEditEx |  |
|  | TUniCalendarPanel |  |
|  | TUniThreadTimer |  |
| TeeChart.TChart | TUniChart | Same goal, incompatible |

#### 详细内容

<< Click to Display Table of Contents >>

Extra
	  

uniGUI provides a Web version of the SynEdit editors, and basic TUniChart (compared to TeeChart).

 

VCL

	

uniGUI

	

Notes




 

	

TUniSyntaxEdit

	

 




 

	

TUniSyntaxEditEx

	

 




 

	

TUniCalendarPanel

	

 




 

	

TUniThreadTimer

	

 




TeeChart.TChart

	

TUniChart

	

Same goal, incompatible

 

Notes:

•TUniThreadTimer creates a timer which runs in its own thread. This is different than the original TTimer or its uniGUI equivalent, TUniTimer. Never try accessing uniGUI visual components in a TUniThreadTimer's event handler.

---

## 37. UniApplication Object

### Technology Overview > Special Objects > UniApplication Object

来源: https://www.unigui.com/doc/online_help/uniapplication-object.htm

#### 章节标题

  - UniApplication Object
  - UniApplication Object

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Special Objects >
   
      UniApplication Object |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

UniApplication Object
	  

UniApplication returns an instance of TUniGUIApplication which is the owner of all current session resources (MainForm, MainModule, and all other forms and DataModules). It is globally available and can be accessed inside uniGUI control event handlers. UniApplication has several useful properties which can be used to obtain information regarding the associated session. For example, URL parameters, client screen width, client screen height, device type, information related to the client PC, and cookies.

 

When a form is created in code, its owner must be set as UniApplication.

 

procedure TMainForm.UniButton2Click(Sender: TObject);
begin
  with TUniForm2.Create(UniApplication) do
    ShowModal();
end;

 

UniApplication itself is actually a function which returns the correct instance of TUniGUIApplication for the current session:

 

unit uniGUIApplication;
 
interface
 
function UniSession: TUniGUISession;
function UniApplication: TUniGUIApplication;
...

 

For this reason UniApplication should only be accessed inside an event handler which is fired from a uniGUI control.
 
procedure TMainmForm.UnimButton1Click(Sender: TObject);
begin
if upAndroid in UniApplication.UniPlatform then
   ShowMessage('This is an Android device!');
end;

---

## 38. UniSession Object

### Technology Overview > Special Objects > UniSession Object

来源: https://www.unigui.com/doc/online_help/unisession-object.htm

#### 章节标题

  - UniSession Object
  - UniSession Object

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Special Objects >
   
      UniSession Object |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

UniSession Object
	  

UniSession returns an instance of the TUniGUISession class for the current session. It contains all the information related to a session. For example, the IP Address, User Agent,  Host Address, Platform related data, etc. UniSession also contains important methods which can be used to control a session (as Terminate to terminate a session):

 

procedure TMainForm.UniButton2Click(Sender: TObject);
begin
  UniSession.Terminate;  // Terminate current session
end;
 
procedure TMainForm.UniButton2Click(Sender: TObject);
begin

  // Redirect current window to a new location
  UniSession.UrlRedirect('http://www.newsite.com');
end;

 

Like UniApplication, UniSession returns a valid instance only when accessed from a uniGUI control event handler, that is, controls which belong to a session. For example, a TUniButton instance always belongs to a session.

 

procedure TMainForm.UniButton2Click(Sender: TObject);
var
  IPAddress : string;
begin

  // We are in an event handler from a TUniButton, so UniSession 

  // can be accessed here.
  IPAddress := UniSession.RemoteIP;
 
end;

 

In the example below, accessing UniSession will cause an access violation because UniThreadTimer is not a uniGUI control and its events are not associated with any session. UniThreadTimer events run asynchronously in a separate thread.

 

procedure TMainForm.UniThreadTimer1Timer(Sender: TObject);
var
  IPAddress : string;
begin

  // this will cause an access violation error because there is

  // no session associated with this event
  IPAddress := UniSession.RemoteIP;
 
end;

 

UniSession is a "global" object which can return different values when accessed from different sessions. It is the same that happens to UniApplication; UniSession is actually a global function declared in uniGUIApplication.pas which returns the correct session instance when called inside an event handler.

 

unit uniGUIApplication;
 
interface
 
function UniSession: TUniGUISession;
function UniApplication: TUniGUIApplication;
...

---

## 39. UniServerInstance Object

### Technology Overview > Special Objects > UniServerInstance Object

来源: https://www.unigui.com/doc/online_help/uniserverinstance.htm

#### 章节标题

  - UniServerInstance Object
  - UniServerInstance Object

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Technology Overview > Special Objects >
   
      UniServerInstance Object |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

UniServerInstance Object
	  

UniServerInstance is a global function defined in uniGUIServer.pas which returns the global instance of the ServerModule singleton.

 
unit uniGUIServer;
 
interface
 
function UniServerInstance: TUniGUIServerModule;
...

---

## 40. Creating a New uniGUI Application

### Developer's Guide > Creating a New uniGUI Application

来源: https://www.unigui.com/doc/online_help/creating_a_new_unigui_applicat.htm

#### 章节标题

  - Creating a New uniGUI Application
  - Creating a New uniGUI Application

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide >
   
      Creating a New uniGUI Application |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Creating a New uniGUI Application
	  

Creating a new uniGUI project is quite easy. It is enough to use the Delphi IDE to activate the uniGUI Application Wizard.

 

Select File->New->Other

 

 

Select uniGUI for Delphi -> Application Wizard

 

Select a Project Type

---

## 41. Standalone Server Project

### Developer's Guide > Creating a New uniGUI Application > Standalone Server Project

来源: https://www.unigui.com/doc/online_help/standalone-server-project.htm

#### 章节标题

  - Standalone Server Project
  - Standalone Server Project
      - Delphi:
      - C++ Builder:

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Creating a New uniGUI Application >
   
      Standalone Server Project |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Standalone Server Project
	  

A Standalone Server project is the simplest type of uniGUI project. It creates an application which runs similar to a desktop application, i.e. the application is started and terminated by the user. This type of application is best used for debugging purposes. Below is the sample DPR file for a typical newly created Standalone Server project. Also see Deployment Options.

 

 

Delphi:

 

program Project1;
 
uses
  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  Main in 'Main.pas' {MainForm: TUniForm};
 
{$R *.res}
 
begin
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
end.

 

C++ Builder:

 

//---------------------------------------------------------------------------
 
#include <vcl.h>
#pragma hdrstop
#include <tchar.h>
#include <UniGUIVars.hpp>
 
USEFORM("ServerModule.cpp", UniServerModule); /* TUniGUIServerModule: File Type */
USEFORM("MainModule.cpp", UniMainModule); /* TUniGUIMainModule: File Type */
USEFORM("Main.cpp", MainForm); /* TUniForm: File Type */
//---------------------------------------------------------------------------
#ifdef _WIN64
   #pragma link "UniGUIVars.o"
#else
   #pragma link "UniGUIVars.obj"
#endif
 
#pragma Project1
 
//---------------------------------------------------------------------------
int WINAPI _tWinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
   ReportMemoryLeaksOnShutdown = true;
   try
    {
      Forms::Application->Initialize();
      Uniguivars::CreateServerModule(__classid(TUniServerModule));
         Forms::Application->Run();
   }
   catch (Exception &exception)
    {
 
   }
   return 0;
}
//---------------------------------------------------------------------------

 

See also: Standalone Server (Console Application)

---

## 42. Standalone Server (Console Application)

### Developer's Guide > Creating a New uniGUI Application > Standalone Server (Console Application)

来源: https://www.unigui.com/doc/online_help/standalone-server-(console-app.htm

#### 章节标题

  - Standalone Server (Console Application)
  - Standalone Server (Console Application)

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Creating a New uniGUI Application >
   
      Standalone Server (Console Application) |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Standalone Server (Console Application)
	  

This new option is introduced in uniGUI build 1608.

 

It will create standalone application which are similar to Standalone Servers. The only difference is that they are created as Windows console applications. Before we go into more details let's state that uniGUI standalone console applications are introduced to be deployed as HyperServer Nodes. Our extensive researches has shown that deploying HyperServer Nodes as console applications will highly improve scalability of HyperServer clusters especially when there are many Nodes running under same HyperServer instance. So, if you intend to deploy your uniGUI application as a part of a HyperServer cluster we recommend to create your Node app as console application.

 

Normally, any console application will show a console window. This window will be hidden by uniGUI server runtime code. In order to keep this window visible there is a property named HideConsoleWindow in ServerModule. This option is True by default which means console window will be hidden. Setting this property to False will keep the console window visible and also will redirect uniGUI server logs to this window. This can be useful for debugging purpose.

You can track application exceptions and error messages or use ServerModule's integrated logger to print custom log entries for debugging purpose.

 

 

Related information: Compiling Nodes as Console Applications

 

 

---

## 43. Standalone Server / ISAPI Module Project

### Developer's Guide > Creating a New uniGUI Application > Standalone Server / ISAPI Module Project

来源: https://www.unigui.com/doc/online_help/standalone-server-_-isap-modul.htm

#### 章节标题

  - Standalone Server / ISAPI Module Project
  - Standalone Server / ISAPI Module Project

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Creating a New uniGUI Application >
   
      Standalone Server / ISAPI Module Project |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Standalone Server / ISAPI Module Project
	  

This type of project is a combo project using conditional compilation for creating one of two types: Standalone server or ISAPI Module. This type of project is very good to start with if ISAPI  Module deployment will be targeted for production use. You will be able to convert your Standalone server to an ISAPI DLL by simply commenting out the first line of the DPR file. Also see Deployment Options.

 

{$define UNIGUI_VCL} // Comment out this line to turn this project into an ISAPI module'
 
{$ifndef UNIGUI_VCL}
library
{$else}
program
{$endif}
  Project1;
 
uses
  uniGUIISAPI,
  Forms,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  Main in 'Main.pas' {MainForm: TUniForm};
 
{$R *.res}
 
{$ifndef UNIGUI_VCL}
exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;
{$endif}
 
begin
{$ifdef UNIGUI_VCL}
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
{$endif}
end.

 

By default, the above project will produce an EXE file which is a Standalone server. If you comment out the first line of the project, it will turn into an ISAPI module. Later, you can convert it back to Standalone EXE mode by removing the comment from the first line. Here is how it works:

 

Steps to convert a combo project to an ISAPI DLL.

 

1.Open DPR file.

2.Change first line of DPR file to: {.$define UNIGUI_VCL}

3.If your Delphi edition is XE2 or newer, you need to close your project and open it again. (This step is not needed if your Delphi version is older than XE2)

4.Build your application.

5.DLL file will be created in the output folder.

 

 

Steps to convert a combo project back to Standalone mode.

 

1.Open DPR file.

2.Change first line of DPR file to: {$define UNIGUI_VCL}

3.If your Delphi edition is XE2 or newer, you need to close your project and open it again. (This step is not needed if your Delphi version is older than XE2)

4.Build your application.

5.Your project will be compiled to EXE file again.

 

---

## 44. ISAPI Module Project

### Developer's Guide > Creating a New uniGUI Application > ISAPI Module Project

来源: https://www.unigui.com/doc/online_help/isapi-module-project.htm

#### 章节标题

  - ISAPI Module Project
  - ISAPI Module Project

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Creating a New uniGUI Application >
   
      ISAPI Module Project |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

ISAPI Module Project
	  

If you plan to start an ISAPI Module project and choose it as the default deployment method, you can select this type of project. The DPR file shows that this project will produce a DLL when it is compiled. For deployment options, please see the ISAPI Module section. ISAPI modules can be deployed to Microsoft® IIS server or Apache server for Windows. Also see Deployment Options.

 

library Project1;
 
uses
  uniGUIISAPI,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule};
 
{$R *.res}
 
exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;
end.

---

## 45. Windows Service Project

### Developer's Guide > Creating a New uniGUI Application > Windows Service Project

来源: https://www.unigui.com/doc/online_help/windows-service-project.htm

#### 章节标题

  - Windows Service Project
  - Windows Service Project

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Creating a New uniGUI Application >
   
      Windows Service Project |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Windows Service Project
	  

Another deployment method for production environments is Windows Service. It creates a standard Delphi Windows Service project with a few modifications to allow creating a uniGUI ServiceModule. Service projects generate standard Windows Service executables which can be installed like any regular Windows Service. A Windows Service is automatically started by Windows and it is always available as long as Windows is running. This provides a high level of availability for the uniGUI application. Also, see Deployment Options.

 

program Project1;
 
uses
  SvcMgr,
  ServerModule in 'ServerModule.pas' {UniServerModule: TUniGUIServerModule},
  MainModule in 'MainModule.pas' {UniMainModule: TUniGUIMainModule},
  Main in 'Main.pas' {MainForm: TUniForm},
  ServiceModule in 'ServiceModule.pas' {UniServiceModule: TUniGUIService};
 
{$R *.res}
 
begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TUniServiceModule, UniServiceModule);
  Application.Run;
end.

---

## 46. Apache Module

### Developer's Guide > Creating a New uniGUI Application > Apache Module

来源: https://www.unigui.com/doc/online_help/apache-module.htm

#### 章节标题

  - Apache Module
  - Apache Module

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Creating a New uniGUI Application >
   
      Apache Module |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Apache Module
	  

Enter topic text here.

---

## 47. Application Design Considerations

### Developer's Guide > Application Design Considerations

来源: https://www.unigui.com/doc/online_help/application-design-considerati.htm

#### 章节标题

  - Application Design Considerations
  - Application Design Considerations

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide >
   
      Application Design Considerations |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Application Design Considerations
	  

There are certain aspects which make a uniGUI Web application different from a desktop application. A desktop application is designed to run as a single instance on the desktop, and it can use all available system resources. Most of the time, this will result in a bad application design, as developers don't see a need to optimize resource usage. With advancements in computer technology, new systems have more resources with each new model. A few years ago, PCs with 128mb of RAM were considered as entry level while today this limit is upgraded to at least 2 GB of memory.  Having so many resources may lead developers to adopt inefficient practices when designing applications and waste system resources. Unlike a desktop application where a single user session runs inside a single process, a Web application hosts several user sessions which run in the same process instance. In this case, resource management becomes a vital task which requires careful analysis.

 

Another difference is related to shared resources. In a desktop application, all resources are dedicated to one user, while in a uniGUI Web application, resources are shared among several user sessions. Any mismanagement of resources may affect the Web application server's health which may lead to server instability. One example of resource mismanagement is memory leaks. In a desktop app memory leaks can be a serious issue if it runs for extended periods of time. Since desktop apps are typically used for a few hours per day, mainly working hours, such memory leaks will not lead to serious issues. However, in a Web application, memory leaks can seriously affect server stability in a short period. If a desktop application fails, the affected user can restart it and continue its work. If a Web application fails, all connected users will be affected.

 

Web application servers are intended to work 24/7, so any resource management related issue can build-up over time and cause the server to run out of resources. Such conditions can lead to application server instability, and eventually to a server crash. When discussing shared resources, it is worth mentioning memory corruption problems. In a desktop application, memory corruption issues can remain undetected for a long time because such corruptions may not produce dangerous side-effects. In a Web application, memory is allocated and disposed at a very high rate in multiple threads, and any memory corruption can lead to severe server instability and erratic application behavior.

 

Finally, a uniGUI Web application is heavily multithreaded, and multiple sessions execute in different threads. As a result, components used in uniGUI must be multithread-aware. Components which are not multithread-aware will cause serious issues which will lead to instability of the Web server.

 

---

## 48. General Design Concept

### Developer's Guide > Application Design Considerations > General Design Concept

来源: https://www.unigui.com/doc/online_help/general-design-concept.htm

#### 章节标题

  - General Design Concept
  - General Design Concept

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations >
   
      General Design Concept |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

General Design Concept
	  

Each uniGUI application is created with a MainForm, a MainModule, and a ServerModule. As described before, MainModule and MainForm are instantiated per session, while ServerModule is a singleton. In addition to MainModule, you can add extra DataModules to your application. A LoginForm can also be added if needed.

 

MainModule is automatically created with your application and it performs many important tasks. MainModule is the best place to place shared resources for a session. These resources are shared among a session's forms and DataModules (or units called by them). A database connection is a good example for shared resources. We can consider each session as a separate copy of the web application and, like a regular application, you need a separate database connection for each application instance. In uniGUI this can be achieved by placing the connection component on DataModule, so that a connection will be created when a new session is started and destroyed when the session is terminated. This will guarantee that each session will use its private copy of the database connection.

 

Another example of shared resources are shared data structures. For instance, each session may need to keep a shared record which holds information about the current user. All other forms and DataModules in the application should be able to access this structure when needed. Consider the following data structure defined in unit MainModule.pas:

 

type  
  TUserInfo = record
    Name, Surname : string;
    UserId : Integer;
  end;

 

This structure needs to be accessible from other forms in the session, so we must define it as a public property in TUniMainModule:

 

  TUniMainModule = class(TUniGUIMainModule)
  private
    { Private declarations }
    FUserInfo: TUserInfo;
  public
    { Public declarations }
    property UserInfo: TUserInfo read FUserInfo;
  end;

 

The structure above will be populated with real user data when the user logs in. MainForm can access UserInfo like this:

 

procedure TMainForm.UniFormCreate(Sender: TObject);
begin
  UniLabel1.Caption :=

    UniMainModule.UserInfo.Name +

    ' ' +

    UniMainModule.UserInfo.Surname;
end;

 

You can see that it can be easily done by accessing the property UserInfo of the modified UniMainModule object. Since each session has its private copy of UniMainModule, each form will access the correct instance of the UserInfo record.

 

At this point, it is good to mention that one should avoid using shared global objects in uniGUI.

 

For example, one could define TUserInfo as a global variable in MainModule:

 

unit MainModule;
 
interface
...
var
  UserInfo: TUserInfo;

 

And access it in MainForm:

 

procedure TMainForm.UniFormCreate(Sender: TObject);
begin
  UniLabel1.Caption := UserInfo.Name + ' ' + UserInfo.Surname;
end;

 

Above code actually works during initial tests because, as long as there is only one active session, UserInfo will not be shared, and the application seems to behave correctly! However, as soon as multiple sessions logs in, the application starts to behave in a strange way.

 

Such design flaws may remain undetected when a few sessions are active at a time, but with an increased load, side effects of the initial design flaw will become more visible and it may not be easy to spot the source of the problem. Because of this, it is important to stick with a correct design pattern from the beginning.

 

Likewise, putting components on ServerModule must be avoided. As described before, ServerModule is a singleton and it will not be created for each session, so for example, putting a database Connection component on ServerModule may work when there are few sessions, but with more sessions you will get unexpected errors which are difficult to detect and debug.

 

Application ServerModule

---

## 49. Web Application Scalability

### Developer's Guide > Application Design Considerations > Web Application Scalability

来源: https://www.unigui.com/doc/online_help/web-application-scalability.htm

#### 章节标题

  - Web Application Scalability
  - Web Application Scalability

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations >
   
      Web Application Scalability |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Web Application Scalability
	  

When it comes to web application development, scalability is one of the most important topics. Web applications are designed to serve many users. While for some apps a few simultaneous users can be the maximum, for other application 100 can be the minimum. It is one of the major differences between a desktop app and a web application. A desktop app serves one user at a time, but a web application serves multiple users simultaneously. As the number of users grows, scalability issues may start to show. Many of such issues are related to flawed application design. A web application must be able to serve multiple simultaneous sessions, and it should take care of the increased resource usage.

 

Consider that you are porting a desktop application to a Web application. In your desktop application, you have a TDataset and a TDBGrid which load all available rows from a table. Now assume that each time a new session starts, thousands of rows are fetched from the table and added to the grid. Consider that each time the table becomes active, both data structures may consume up to a few megabytes of memory. It would pose no issue if it were a desktop application, as all system resources could belong to the desktop app. However, in a Web application, each new session will consume this amount of memory. In this case, if you have 100 active sessions and each session consumes 10MB of RAM, the total required memory will be 100 x 10 = 1,000 MB = 1 GB.

 

As you can see, memory consumption can become huge if your sessions are not optimized for resource usage. It shows the importance of resource optimization for applications where scalability is important. There can be cases where scalability doesn't have the highest priority. For example, if you develop a Web application for s system with up to 10 users, scalability is not an issue, but for a Web application where 100 users are the minimum, resource management should make sure your application will never run out of resources.

 

Stress Test Tool can assist in finding scalability issues. Running a stress test can precisely show the maximum amount of memory that your server will consume when a certain number of sessions are running. It can be used to test your web application in a worst case scenario and see if it can pass the test under such rare conditions. If your application can pass the stress test, it will be ready to deploy to a production environment.

 

uniGUI itself is optimized in many aspects to deal with resources. To give some examples, it stores bitmaps in cache files, creates forms when opened and destroys them when user closes them, keeps ImageLists in cache file, etc. Likewise, developers should consider adopting a Create Resource on Demand principle to optimize resource usage. One good example could be database tables and related datasets. In a classical Delphi approach, a developer may place the connection component and all related datasets on a DataModule, but in uniGUI it would force to create all datasets every time a new session starts. This will pose even more problems if datasets are Active by default.

 

In uniGUI the correct approach is to place connection components on MainModule and place the datasets on the forms or on DataModules owned by the forms. When you place a dataset on a form, it will be created when the form is shown and destroyed when the form is closed. This approach will optimize memory usage related to datasets.

---

## 50. Create Resources on Demand

### Developer's Guide > Application Design Considerations > Web Application Scalability > Create Resources on Demand

来源: https://www.unigui.com/doc/online_help/create-on-demand.htm

#### 章节标题

  - Create Resources on Demand
  - Create Resources on Demand

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Web Application Scalability >
   
      Create Resources on Demand |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Create Resources on Demand
	  

This is an approach which must be followed when designing a scalable web application. The general rule here is to create resource sensitive objects when they are needed, not before, and destroy them when they are no longer needed. One example is database tables. As described in the previous section, database tables can load many rows at once, which can increase memory usage with increased number of rows. It is true especially with memory datasets. Delphi's built-in TClientDataset is an example of memory dataset. In order to make sure a dataset is created and loaded with data when it is needed, it is good to place the dataset on a form or frame where db-aware controls exist. Each time the user needs to visit that form, it will be created and shown along with tables and db-aware controls. When the user closes the form, the dataset will be freed and its memory is sent back to the application memory pool.

 

The  method can be applied to reporting tools. Instead of putting report components on MainModule, it can be created just before generating the report and destroyed right after the report is generated and saved in a temporary file.

---

## 51. Database Connections

### Developer's Guide > Application Design Considerations > Web Application Scalability > Database Connections

来源: https://www.unigui.com/doc/online_help/database-connections.htm

#### 章节标题

  - Database Connections
  - Database Connections

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Web Application Scalability >
   
      Database Connections |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Database Connections
	  

Connections to a database is another resource which should be taken into consideration when it comes to application scalability. As recommended, for each session a connection object should be placed on MainModule. A new instance of the connection object will be created when a new session is initiated, so in a typical  scenario, each session will establish a new connection to the database server. This can pose an issue with scalability if the database server can only serve a limited number of simultaneous connections. It is the case with many database servers. Some of them have a default limit of a few hundred, while others can handle thousands of connections or more. Again, database connection must be treated as limited resources and your app should not reach the upper limit.

 

You can configure your server to serve a higher number of simultaneous connections, but it is not the correct way of dealing with this problem. There are ways to deal with this issue:

 

1. Enabling Connection Pooling. Connection pooling is a method to re-use database connections with same properties. Some database libraries implement pooling by default while others don't implement this feature. You must check your particular connection library to see if the pooling feature is available or not. For example, the TADOConnection component combined with Microsoft SQL Server enables pooling by default. FireDAC also supports pooling and can be enabled. Please see section FireDAC.

 

2. Using a Middleware Library. When the number of concurrent sessions is bigger than the upper limit of your database server, one way to overcome this issue is to use a middleware layer. This is one of the purposes of middleware layers, to manage database connections in the best possible way. A middleware layer creates a connection when it is needed and frees it when it is no longer used, making it possible to serve many sessions with a few simultaneous connections. Some middleware libraries implement connection pooling which improves performance. Among commonly used middleware libraries in Delphi we can count DataSnap, DataAbstract and kbmMW.

---

## 52. Web Application Stability

### Developer's Guide > Application Design Considerations > Web Application Stability

来源: https://www.unigui.com/doc/online_help/web-application-stability.htm

#### 章节标题

  - Web Application Stability
  - Web Application Stability

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations >
   
      Web Application Stability |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Web Application Stability
	  

With a Web application, stability is other major concern. Stability and scalability can be considered as two interconnected concepts. A Web app can not be scalable if it is not stable in the first place. So the first step towards scalability is to make sure the Web application is fully stable. One can say that scalability issues can lead to a non-stable application. Likewise, an unstable application can hardly be scalable. Hence, a Web application designer must keep both scalability and stability in mind in all development stages.

 

We have covered some of the stability related design issues under Web Application Scalability chapter. In this chapter we will try to cover the stability concept in depth.

---

## 53. Memory Management

### Developer's Guide > Application Design Considerations > Web Application Stability > Memory Management

来源: https://www.unigui.com/doc/online_help/memory-management.htm

#### 章节标题

  - Memory Management
  - Memory Management

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Web Application Stability >
   
      Memory Management |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Memory Management
	  

Delphi applications are Windows native applications, .i.e. they can directly run on a Windows PC without needing a runtime library such as .NET Framework or Java. Each Delphi executable is a set of machine code instructions which natively run on a CPU, unlike .NET or Java applications which need a translator to convert special OP codes to CPU machine code first. There are several differences between a native Delphi application and managed code apps such as Java and .NET, but here we will focus on memory management only.

 

Frameworks like .NET and Java come with sophisticated memory managers which have a built-in garbage collector. The availability of a garbage collector makes life  easier for developers. A garbage collector automatically manages the object lifetime. You only need to create objects and the garbage collector will take care of destroying them when not needed anymore. This will create a safer environment for developers, as they should not take care of memory management. They can leave memory management completely to the framework which is equipped with a garbage collector.

 

On the other hand, Delphi does not have a garbage collector, and the developer should take care of destroying objects correctly. Indeed Delphi has some capabilities to allow automatic disposal of objects, such as automatic reference counting used along with Interfaces, but it is far from being a complete garbage collector. Hence, Delphi developers should always take care of the object lifetime when they create them manually, .i.e. you must destroy what you have created! Fortunately, you don't need to take care of objects created at design-time, such as forms, frames, data modules, components, and controls. You only need to take care of objects which you create dynamically in code.

 

While a proper memory management is critical for a web application and should be handled with extreme care, one may not be that careful when designing a desktop VCL application. Desktop VCL applications have a limited lifetime, i.e. they are initiated and terminated by the user. A typical desktop client application may work only a few hours a day, typically 6-10 hours. On the other hand, a web application server is designed to run indefinitely. While there are several techniques to recycle or periodically restart web applications, the main idea behind it is to design them to run in a continuous manner. A desktop VCL application designer may adopt wrong coding habits regarding object lifetime management, but since a desktop application lifetime is finite, those wrong habits won't affect the end user for several reasons.

 

One of the reasons, as mentioned above, is that many VCL applications have a short life cycle of a few hours. With this short life cycle even severe memory leaks can remain hidden and unaddressed. Modern client PCs are equipped with several gigabytes of memory, which is huge when compared with the most severe memory leaks that may occur in a typical VCL application. That's why a VCL developer can adopt wrong coding habits without becoming aware of them. However, such habits should be avoided for Web applications. In a Web application, many sessions will be created and destroyed dynamically, and even a small memory leak in each session can lead to over usage of memory after a certain period of time, which will eventually lead to server instability and crash.

 

This is a typical risk when a legacy VCL application is ported to uniGUI. In this case, extreme care must be taken to make sure legacy VCL code is free of memory leaks. Fortunately, in Delphi, memory leaks can be traced easily by adding a single line to the project file.

 

begin
{$ifdef UNIGUI_VCL}

  // add this line to report memory leaks
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TUniServerModule.Create(Application);
  Application.Run;
{$endif}
end.

 

For more detailed information regarding memory issues and methods to debug and detect them please see section Using FastMM in Full Debug Mode.

---

## 54. Importance of Proper Memory Management

### Developer's Guide > Application Design Considerations > Web Application Stability > Memory Management > Importance of Proper Memory Management

来源: https://www.unigui.com/doc/online_help/importance-of-memory-managemen.htm

#### 章节标题

  - Importance of Proper Memory Management
  - Importance of Proper Memory Management

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Web Application Stability > Memory Management >
   
      Importance of Proper Memory Management |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Importance of Proper Memory Management
	  

Why is proper memory management so important for a web application?

 

The answer is simple: like any other server application, uniGUI servers are designed to run continuously. It means that any harmful memory operation can have adverse effects on server functionality and stability. These effects can remain hidden and undetected when server load is low, but they will be visible as more clients request its services.

 

Now let's discuss those so-called harmful memory operations in more detail:

 

1.Memory Leak

 

A memory leak happens when a manually allocated memory is never released. Sources of memory leaks can be various. A very common mistake is to create an object dynamically without adding proper code to dispose it. The following code shows an example of memory leak:

 

   A := TSomeControl.Create(nil);
   A.Property1 := 0;
   A.Run;
   A.Free;

 

At first glance the above code may look correct, as it calls the Free() method to dispose the created control. However, what will happen if the Run() method fails and raises an exception? In this case the Free method will be skipped and a memory leak will occur. This is the corrected version of the same code:

 

   A := TSomeControl.Create(nil);
   try
     A.Property1 := 0;
     A.Run;
   finally
     A.Free;
   end;

 

In the previous snippet the Free() method will be always called regardless of the code in the try .. finally block.

 

The following code shows a wrong solution (it won't produce a memory leak, but it will cause memory corruption).

 

   try

     // consider that an exception occurs while creating the object
     A := TSomeControl.Create(nil);
     A.Property1 := 0;
     A.Run;
   finally

     // in this case variable A will be not be initialized and a call

     // to Free may lead to memory corruption
     A.Free;
   end;

 

If the first statement fails to create the object A by throwing an exception, the next statement will be the request to free A. But the value of A is undefined, as the failure to create the object does not assign nil to the variable. An attempt to release an object pointing to a random location can potentially create a memory corruption or trigger an Access Violation.

 

Memory Corruption

 

A memory corruption occurs when a memory operation overwrites another memory location which is already occupied by an object or variable. Memory corruptions are more harmful than memory leaks. Memory corruptions can remain hidden for some time, but eventually you will start observing Access Violation errors in your application and uniGUI log files. There are many sources of memory corruption. Most of them are a result of bad coding habits. As described in previous sections, some bad coding habits may not be harmful in a desktop VCL application, but in a server application, the adverse effects of those habits will become apparent.

 

Perhaps one of the primary sources of memory corruption in a multithreaded server application is using global variables. If a server application needs global variables,  it is necessary to protect the access to them. In a standard VCL application using global variables is common, but in a multithreaded application, they should be used only when strictly necessary. While using ordinal variables such as integers will not lead to an immediate memory corruption, using dynamic global strings will cause memory corruption. Of course, memory corruption is only one side effect of using global variables, another important issue with global variables is the fact that they are shared between sessions.

 

Consider the following scenario:

 

You have an application with a login form and you save the user information in a record variable.

 

type
   TUserRecord = record
      Name, Surname: string;
   end;

 

Now let's declare it as a global variable in a unit (the wrong way):

 

var
   CurrentUser: TUserRecord;

 

After a new user is logged in, let's assign the user name to this variable:

 

procedure TMainForm.UniBitBtn1Click(Sender: TObject);
begin
  CurrentUser.Name := UniNameEdit.Text;
  CurrentUser.Surname := UniSurnameEdit.Text;
end;

 

There are two major issues with that scenario:

 

•When a new session is created, and user #1 is logged in, his/her name will be assigned to the CurrentUser variable. If another session is created, and user #2 is logged in, this time CurrentUser is overwritten with new user information for the current session. Obviously, the first session will lose the previously saved user information, as it was overwritten by the second session.

•This scenario can easily lead to severe memory corruptions. If your application has a mildly high traffic, it can lead to writing conflicts from more than one threads which will cause string corruption. In Delphi, string objects are dynamic memory locations which are internally managed by the memory manager. When two concurrent threads write on the same string, it can easily lead to pointer corruption.

 

Now, one may ask, what is the correct way of implementing that scenario? The answer is quite easy and straightforward. In uniGUI, each session comes with its set of modules and objects which are public to that session but private to others. Forms and modules are examples of such objects. Each session has its own private copy of MainForm, other forms, MainModule and DataModules (DataModules created with the uniGUI wizard).

 

So if you want to declare a "global" variable, declare it as a field or property of one of the above objects. By doing so, your variable will be global or public for its parent session, but private or invisible to other sessions. It will avoid all memory-related issues we just discussed above.

 

Let's re-implement our scenario according to those rules. Here we will use MainModule as the container class for our UserRecord. It is necessary to add a new property named UserRecord to the TUniMainModule class.

 

type
  PUserRecord = ^TUserRecord;
  TUserRecord = record
    Name, Surname : string;
  end;
 
  TUniMainModule = class(TUniGUIMainModule)
  private
    { Private declarations }
    FUserRecord: TUserRecord;
    function GetUserRecord: PUserRecord;
  public
    { Public declarations }
    property UserRecord: PUserRecord read GetUserRecord;
  end;
 
function UniMainModule: TUniMainModule;
 
implementation
 
{$R *.dfm}
 
uses
  UniGUIVars, ServerModule, uniGUIApplication;
 
function UniMainModule: TUniMainModule;
begin
  Result := TUniMainModule(UniApplication.UniMainModule)
end;
 
function TUniMainModule.GetUserRecord: PUserRecord;
begin
  Result := @FUserRecord;
end;

 

This will ensure that each session will access its own private copy of UserRecord, avoiding any possible memory issue raised from using global variables.

 

Finally, we can access UserRecord from other forms and modules simply by using the following syntax:

 

procedure TMainForm.UniBitBtn1Click(Sender: TObject);
begin
  UniMainModule.UserRecord.Name := UniNameEdit.Text;
  UniMainModule.UserRecord.Surname := UniSurnameEdit.Text;
end;

 

---

## 55. Object Lifetime Management

### Developer's Guide > Application Design Considerations > Web Application Stability > Memory Management > Object Lifetime Management

来源: https://www.unigui.com/doc/online_help/object-lifetime-management.htm

#### 章节标题

  - Object Lifetime Management
  - Object Lifetime Management

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Web Application Stability > Memory Management >
   
      Object Lifetime Management |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Object Lifetime Management
	  

In Delphi, there are several levels of Object Lifetime Management.

 

Delphi takes care of the design-time objects like components and controls on a form. It will also automatically release any auto-created form.

 

However, any dynamic object created in code is the responsibility of the developer. If using interfaces with reference counting, it is not necessary to explicitly release the variables. But the developer will be responsible for releasing any other variable. If the developer fails to dispose of these variables, it will create memory leaks which may exhaust the server memory and crash the application over time.

 

A typical syntax for creating dynamic objects with a short lifetime is creating and disposing them in a try .. finally block.

 

  F := TFileStream.Create('NewFile.bin', fmCreate);
  try
    F.Write(Buffer, 1024)
  finally
    F.Free; // dispose object when it is done
  end;

 

The file stream object will be freed when the try .. finally  block is executed. This principle must be followed when creating dynamic objects with a short lifetime.

---

## 56. Special Considerations for ISAPI Modules

### Developer's Guide > Application Design Considerations > Special Considerations for ISAPI Modules

来源: https://www.unigui.com/doc/online_help/isapi-module-related.htm

#### 章节标题

  - Special Considerations for ISAPI Modules
  - Special Considerations for ISAPI Modules

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations >
   
      Special Considerations for ISAPI Modules |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Special Considerations for ISAPI Modules
	  

An ISAPI module is a specialized DLL loadable by Microsoft IIS web server. ISAPI modules are standard Windows DLLs which must be hosted by another process. In IIS, a process named w3wp.exe loads and serves ISAPI DLLs. Each ISAPI DLL inherits privileges and access rights from its host process. It can only have access to folders, files, and other system resources which are accessible by the host process.

 

Windows assigns a user account to each ISAPI host process which either can be the built-in account named IUSR or any other user account which can be configured by the user. A host process is also called an ISAPI pool. In fact, an ISAPI pool is a collection of host processes which share the same configuration. Each pool can be configured to run one or more ISAPI applications. Please see this section for IIS 7.0 to see how an application is created and configured.

 

You can share one pool between more than one ISAPI module. You can also create a separate application for each ISAPI module and assign separate pools to each application. Applications in same pool are fully isolated from other applications in other pools, but applications in the same pool are not fully isolated. If one application in a pool becomes unstable, it can affect other applications sharing that pool. If one pool crashes, all applications in that pool also become unavailable until the application pool starts again.

 

uniGUI applications are stateful, keeping the complex state information in the server memory. If the application crashes, the active sessions will lose the state information. All connected users should log into a new session when the application pool is online again. It can be an unpleasant experience for all users when your application pool crashes as a result of an unstable ISAPI module. Hence, make sure your uniGUI application is stable enough before deploying it to a production environment.

 

---

## 57. Thread Stack Size

### Developer's Guide > Application Design Considerations > Special Considerations for ISAPI Modules > Thread Stack Size

来源: https://www.unigui.com/doc/online_help/thread-stack-size.htm

#### 章节标题

  - Thread Stack Size
  - Thread Stack Size
      - Changing ISAPI Application Default Stack Size

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Special Considerations for ISAPI Modules >
   
      Thread Stack Size |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Thread Stack Size
	  

Each Windows Thread receives a private stack which the same size as the default stack size of its host process. In StandAlone or Windows Service mode, the stack size is determined by Delphi. By default, the stack size of a Delphi application is 1 MB. It can be changed going to Project -> Options -> Linking -> Minimum Stack Size / Maximum Stack Size parameters.

 

They can also be adjusted by compiler directives:

 

{$M minstacksize,maxstacksize}
{$MINSTACKSIZE number}
{$MAXSTACKSIZE number}

 

These settings only apply to executable binaries. ISAPI DLLs use the host process default stack size value for internal threads. That can be a problem for a uniGUI application which is designed to work with a different stack size than the stack size of the DLL host process. In IIS 7.0 and later, the default stack size is 256Kb for 32-bit applications and 512Kb for 64-bit applications. These values are lower than the Delphi default which is 1 MB. As a result, you may experience that a web application which runs correctly in standalone mode can produce unexpected Stack Overflow exceptions when deployed in ISAPI format.

 

The default 1 MB stack size for Delphi applications is actually a big value for a typical applications. A Delphi application should not rely on stack size to work properly. The stack is a temporary storage in memory to be used for temporary variables inside functions and procedures. It is wise to keep local variable usage to a minimum  when designing an application. For instance, in the following snippet a method needs a local array to work with:

 

procedure TMyClass.DoCalculate;
var
  MyCalcArray : array [1..10240] of Integer;
  I : Integer;
begin
  for I := 1 to 10240 do
     MyCalcArray[I] := I * 10;
end;

 

The previous code uses a local array. This array is created in the stack and consumes the limited stack memory space. Such local data structures should be avoided; developers should use dynamic data structures which are created in the main memory pool of the application (the heap):

 

var
  MyCalcArray : array of Integer;
  I : Integer;
begin
  SetLength(MyCalcArray, 10240);
  for I := 1 to Length(MyCalcArray) do
     MyCalcArray[I] := I * 10;
end;

 

If your application crashes with Stack Overflow message it is a sign of either a recursive call to a method, which is a bug, or your application stack usage is greater than the default stack setting. In this case, you must try to reduce the application stack usage by changing your code and underlying logic or increase the application default stack size.

 

It is worth knowing that Stack Overflow is a serious condition with no recovery option. In some cases, the Stack Overflow condition will log an error in the uniGUI log file with an exception message on screen, but in an ISAPI application a Stack Overflow error may terminate your ISAPI pool silently without any on-screen exception message or error log in the uniGUI log file. However, you will be able to see a message in Windows Event Viewer showing that your application pool terminated and restarted as a result of an unexpected error.

 

Changing ISAPI Application Default Stack Size

 

Note: Starting with uniGUI build 1608 this option is no longer available. If you want to deploy your app as an ISAPI DLL and use a custom stack size you must choose uniGUI HyperServer as deployment method and deploy your app as standalone server EXEs. We strongly recommend deploying your apps along with HyperServer. This will also make debugging your apps much easier.

 

Below lines only apply to uniGUI build 1607 or older:

In any case, you may still want to change the stack size of your DLL application which is imposed by the IIS worker process. Fortunately, uniGUI provides a simple way to achieve this.

In ServerModule unfold ISAPIOptions and set AsyncMode to True. Now set ThreadStackSize to a desired value. In the example below the stack size is set to 2 MB.

 

 

Please note that these settings only apply to ISAPI DLL modules. For Standalone and Service Applications the stack size should be adjusted using conventional methods as explained before.

 

 

---

## 58. Using OLE based components

### Developer's Guide > Application Design Considerations > Special Considerations for ISAPI Modules > Using OLE based components

来源: https://www.unigui.com/doc/online_help/using-ole-based-components.htm

#### 章节标题

  - Using OLE based components
  - Using OLE based components

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Special Considerations for ISAPI Modules >
   
      Using OLE based components |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Using OLE based components
	  

There are certain report showing that OLE based components such as ADO components can leak Windows handles when used in an ISAPI application. The actual leaked handles are detected to be Windows USER Objects.

To avoid this behavior it is required to set the AsyncMode to true in uniGUI ISAPI application.

 

It can be simply done in ServerModule->ISAPIOptions:

 

 

 

It should be noted that not all OLE components  may cause such leaks. You can detect such leaks by observing Server Control Panel:

 

 

In a long term observation, if you can detect an steady increase in USER Objects regardless of number of sessions, then it can be a sign of leaked handles in your application.

If such a handle leak is detected it can be resolved by setting the AsyncMode to True.

---

## 59. Third party Component Libraries

### Developer's Guide > Application Design Considerations > Third party Component Libraries

来源: https://www.unigui.com/doc/online_help/third-party-component-librarie.htm

#### 章节标题

  - Third party Component Libraries
  - Third party Component Libraries

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations >
   
      Third party Component Libraries |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Third party Component Libraries
	  

There are few applications which may not rely on 3rd-party component libraries. 3rd-party libraries help to create a feature-rich application with expanded functionality. In some cases, using a 3rd-party library is mandatory. For instance, a database engine may need a particular set of components for connecting and making queries. Reporting is another area where 3rd-party tools come to mind. When it comes to uniGUI applications, 3rd-party tool compatibility becomes an important issue. As described in previous sections, the stability of a web application depends on all the elements of the application. A buggy, poorly developed, or incompatible 3rd-party library can lead to server instability.

 

There some important points to take into consideration when choosing a 3rd-party library for a uniGUI application:

 

Compatibility: As described in many places throughout this document, a uniGUI server is a heavily multithreaded environment. This means that any tool used along with uniGUI must be thread-safe, i.e. several instances of the component must be capable of running in several threads in parallel. If a component relies on global variables, it is very likely to fail in a web application. Likewise, if a component relies on embedded VCL controls, then it is likely to affect server stability in a harmful way. VCL controls are not thread-safe as it is explicitly stated in the VCL documentation. Unfortunately, some reporting tools are designed to rely on VCL controls to generate report output.

 

Some 3rd-party tools rely on window handles (HWND) and message loops to function. That is another point which can cause serious problems in uniGUI. uniGUI doesn't have a main thread and it doesn't implement a message loop. Although the Standalone Server borrows a main thread from Delphi's VCL, a main thread is not available in an ISAPI DLL. So, any 3rd-party component relying on sending messages is likely to fail in an ISAPI module. You may find out that some apps work properly in Standalone Mode and fail or work differently when deployed as an ISAPI module. It happens because in Standalone mode the uniGUI server implements a VCL Form which is minimized to tray. As a result, Application.Run() is called to keep the server running until the user terminates it. That form will create a message loop which allows some incompatible components work to some level. However, in an ISAPI module, no VCL form is created, and there is no call to Application.Run(), so that any attempt to call SendMessage() will fail to return a result because there is no message loop to process the messages.

 

To give a specific example, TRichEdit is a VCL control which is a Memo with styled text. Some reporting tools use it to generate blocks of text with various styles. Like other VCL controls, it internally uses SendMessage() to communicate with its Handle (HWND). As described above, that request will fail, and RichEdit will fail to render. You may find out that a report containing RichEdit renders correctly when the application is deployed in Standalone mode but doesn't render anything when the same app runs as Windows Service or ISAPI module.

 

As the last example, 3rd-party components should not use global variables. They must follow the same rules applied to uniGUI applications. Each instance of the component must have its own private set of variables to work with and should not rely on global variables or data modules without protecting the access to them.

 

Some 3rd-party components need to be configured properly to run in a threaded environment. You must check that specific section of their manual for the instructions.

 

Stability: Any 3rd-party component which have stability issues will affect the stability of the uniGUI application. Component libraries must be free of bugs and tested against memory leaks.Vendors must ensure that it can be used in a multi-threaded environment without any issues.

 

Scalability: 3rd-party Components used in uniGUI must be scalable. There should be no upper limit for the number of simultaneous instances of the component that may co-exist unless limited by system resources. If there are such limits, the developer must be aware of them and design the application accordingly.

 

---

## 60. Reporting Tools

### Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools

来源: https://www.unigui.com/doc/online_help/reporting-tools.htm

#### 章节标题

  - Reporting Tools
  - Reporting Tools

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Third party Component Libraries >
   
      Reporting Tools |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Reporting Tools
	  

There are some special guidelines for reporting tools to make sure they run in a compatible mode with uniGUI. Some reporting tools have special settings for multi-threaded applications. In many cases you need to disable visual dialogs and other VCL related forms from being displayed while the report engine is running. Since in uniGUI you cannot display VCL forms, you will need to export the report have to a file. A commonly used format is PDF which can be embedded in a browser window or an iframe.

 

In uniGUI, the recommended method to create a report is converting it to a PDF file and displaying it inside a TUniUrlFrame control. For each reporting tool there are different paths to achieve this. Under this topic we will shortly cover a few reporting tools. You can also load and run the related demos to see how it is actually done.

 

Important: As described in previous sections, there are some common issues in reporting tools that may affect the uniGUI application stability and scalability. The initial versions of reporting tools were created for desktop applications only. In time, they evolved and started to support server applications too; however, they may still contain components or code parts which are not compatible with multi-threaded server applications. Some reporting tools generate the report by using VCL controls which render it to a canvas before exporting it to a PDF file.

Be aware, some reporting tools render their reports by using the TRichEdit control with all the issues we described before. This kind of reporting tool cannot be used inside the uniGUI application, but it could be used by some external web service. A "printing server" web service could spawn external processes for exporting PDF reports, but this solution requires some central database where the information required for the report is stored (in such a way that the uniGUI application could ask for some specific report and receive the PDF file as the result).

To fully test the compatibility of a reporting tool with your application, you should run a Stress Test and fully analyze your application behavior. It is important to make sure that both your particular reporting tool and your particular report design can scale up when the server is under load.

 

Another important point here is to make sure creation of report components and generation of report are happening in same event. Some report components internally use VCL controls which need to create Window handles. Those handles must be created and released in same thread, so it is needed to create and destroy report components in a single event call. In order to achieve this, the best way to place report components on a Free DataModule. The free data module will be created when report is needed to be generated. After report is created data module should be freed.

 

Below code is taken from our FastReport demo:

 

procedure TUniForm1.UniFormBeforeShow(Sender: TObject);
var
  dm : TfrDM;
  RepUrl : string;
begin
  dm := TfrDM.Create(nil);
  try
    RepUrl := dm.GenReportPDF(InvNum);
  finally
    dm.Free;
  end;
 
  UniURLFrame1.URL := RepUrl; // display generated PDF inside a frame
end;

 

In above code data module is created on demand, report link is generated and data module is destroyed after.

 

Below is the actual free data module which is used to generate the report:

 

A Free DataModule for report generation

 

---

## 61. FastReport

### Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools > FastReport

来源: https://www.unigui.com/doc/online_help/fast-report.htm

#### 章节标题

  - FastReport
  - FastReport

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools >
   
      FastReport |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

FastReport
	  

FastReport is a widely used reporting tool for Delphi. To use FastReport in a uniGUI application there are certain rules to follow. The FastReport engine must be adjusted so it can cope with uniGUI multi-threaded environment.

 

First of all, the report engine parameters must be adjusted. In the next example Report is a TfrxReport object.

 

  Report.EngineOptions.SilentMode := True;
  Report.EngineOptions.EnableThreadSafe := True;
  Report.EngineOptions.DestroyForms := False;
  Report.EngineOptions.UseGlobalDataSetList := False;

 

Next step is to adjust the report settings:

 

  Report.PrintOptions.ShowDialog := False;
  Report.ShowProgress := False;
  Report.PreviewOptions.AllowEdit := False;

 

In order to export a file you need to use an export component. For PDF files you need the TfrxPDFExport component. Here are the settings:

 

  Exp.Background := True;
  Exp.ShowProgress := False;
  Exp.ShowDialog := False;

  / Assign a unique name to exported file name
  Exp.FileName := UniServerModule.NewCacheFileUrl(False, 'pdf', '', '', AUrl);
  Exp.DefaultPath := '';

 

After all settings are done, the last step is to generate the report:

 

  Report.PrepareReport;
  Report.Export(Exp);

 

Finally, we need to show the report in uniGUI. There are two options: using TUniURLFrame or TUniPDFFrame. The example PDFViewer uses both of them.

 

  UniURLFrame1.URL := AUrl;

 

PDF Viewer using TUniURLFrame

  UniPDFFrame1.PdfURL := Url;

 

PDF Viewer using TUniPDFFrame

 

Another method is to send the report to the user by downloading it with the UniSession.SendFile method.

 

  UniSession.SendFile(Exp.FileName);

 

 

---

## 62. Important notes on FastReport and thread safety

### Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools > FastReport > Important notes on FastReport and thread safety

来源: https://www.unigui.com/doc/online_help/important-notes-on-fastreport-.htm

#### 章节标题

  - Important notes on FastReport and thread safety
  - Important notes on FastReport and thread safety

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools > FastReport >
   
      Important notes on FastReport and thread safety |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Important notes on FastReport and thread safety
	  

FastReport is a popular reporting tool for Delphi and C++ Builder. In the previous section we described general guidelines for using FastReport components in a uniGUI application. Some recent findings have shown that special care must be taken to ensure that FastReport runs in a compatible mode with uniGUI and its multi-threaded environment.

 

Avoid using FastReport global dataset list

 

Global dataset is a collection used by FastReport in VCL applications. This collection should be avoided in uniGUI, otherwise its use can lead to severe issues such as stack overflow and immediate server crash. In the previous section we mentioned that the following setting must be applied to avoid global dataset usage:

 

  Report.EngineOptions.UseGlobalDataSetList := False;  // Do not keep a global list of a datasets

 

Developers must make sure that this setting is applied right after the TfrxReport component is created. If your TfrxReport component is on a Form or a DataModule, uniGUI will provide a handy method to do this. Go to MainModule, click on the OnNewComponent event and add the following code:

 

procedure TUniMainModule.UniGUIMainModuleNewComponent(AComponent: TComponent);
begin
  if AComponent is TfrxReport then
  begin
    (AComponent as TfrxReport).EngineOptions.UseGlobalDataSetList := False;
  end;
end;

 

The previous code will ensure that each new instance of the TfrxReport component will have the correct setting for its UseGlobalDataSetList property.

 

If you create the TfrxReport component in code, modify the setting manually:

 

// always create TfrxReport component with an owner

  f := TfrxReport.Create(Self);
  try
    f.EngineOptions.UseGlobalDataSetList := False;
    f.EngineOptions.SilentMode := True;
    f.EngineOptions.EnableThreadSafe := True;
    f.EngineOptions.DestroyForms := False;
    f.LoadFromFile(UniServerModule.FilesFolderPath + RepName + '.fr3');

    if f.Version >= '6.0.0' then f.DataSets.Add(frxDBDataset1); // starting from FastReport 6.x you need to add Datasets manually, 
                                                                // so your report will be able to find them  

 // generate report here
 
  finally
    f.Free;
  end;

 

In the above example, the TfrxReport component is created with owner self. It is very important to make sure you have passed a proper owner to it. You should avoid creating TfrxReport with a nil owner.

 

Generating reports using dynamic components

 

To save system resources, the best way to generate reports is to use dynamically created components. Please review the following demos to see the best way of doing this:

 

..\uniGUI\Demos\PublicDemos\Desktop\FastReport - Dynamic

..\uniGUI\Demos\PublicDemos\Desktop\FastReport - MultiReport

 

In those demos we use a free DataModule with TfrxReport and other required report components on it:

 

 

 

When we want to generate a new report, we simply create the free DataModule, generate the report and then destroy the DataModule:

 

procedure TUniForm1.UniFormBeforeShow(Sender: TObject);
var
  dm : TfrDM;
begin
  dm := TfrDM.Create(nil);
  try
    UniURLFrame1.URL := dm.GenReportPDF(RepName, Id);
  finally
    dm.Free;  // free reporting components as soon as report is generated
  end;
end;

 

The above code will ensure that system resources dedicated to reporting tools are freed as soon as the report is generated. This can be important in systems where the number of users is high and a precise resource management is required.

This also required when your report components are using Windows handles. In this case all report components must be created and destroyed in same thread. Using a dynamic data module as demonstrated above will ensure that creation, report generation and destruction of report components are done within context of same thread.

 

 

 

---

## 63. ReportBuilder

### Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools > ReportBuilder

来源: https://www.unigui.com/doc/online_help/reportbuilder.htm

#### 章节标题

  - ReportBuilder
  - ReportBuilder

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools >
   
      ReportBuilder |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

ReportBuilder
	  

ReportBuilder is another widely used reporting tool in Delphi. We also generate a PDF output of the report and direct it to a TUniUrlFrame.

 

  lPDFDevice := TppPDFDevice.Create(nil);
  try
    lPDFDevice.PDFSettings := ppReport1.PDFSettings;
    lPDFDevice.FileName    :=

      UniServerModule.NewCacheFileUrl(False, 'pdf', '', '', AUrl);
    lPDFDevice.Publisher   := ppReport1.Publisher;
    // generate the report
    ppReport1.PrintToDevices;
    UniURLFrame1.URL := AUrl;
  finally
    lPDFDevice.Free;
  end;

 

 

In order to avoid conflict with VCL based report components and uniGUI multi-threaded engine you must adopt dynamic creation of reports.

 

For this you need to create a Free DataModule from uniGUI Wizard and place all of your components and report generation code inside this module:

 

Free DataModule

 

Generation of report will be simply performed by creating the data module as demonstrated below:

 

procedure TUniForm1.UniFormBeforeShow(Sender: TObject);
var
  dm : TrepDataModule;
begin
  dm := TrepDataModule.Create(nil);
  try
    UniURLFrame1.URL := dm.GenRep(InvNum)
  finally
    dm.Free;
  end;
end;

 

The full demo is available under the ..\demos\Report Builder folder.

 

---

## 64. Using a Report Server

### Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools > Using a Report Server

来源: https://www.unigui.com/doc/online_help/using-a-report-server.htm

#### 章节标题

  - Using a Report Server
  - Using a Report Server

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Third party Component Libraries > Reporting Tools >
   
      Using a Report Server |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Using a Report Server
	  

In some cases where stability and scalability concerns have the highest priority, it is wise to use a separate report server. In many cases your reporting tool already provides a server solution which runs in its own service. Your uniGUI application can generate reports by sending proper requests to the report server. Generated reports can be displayed in a TUniUrlFrame or TUniPDFFrame as normal.

---

## 65. Database Components

### Developer's Guide > Application Design Considerations > Third party Component Libraries > Database Components

来源: https://www.unigui.com/doc/online_help/database-components.htm

#### 章节标题

  - Database Components
  - Database Components

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Third party Component Libraries >
   
      Database Components |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Database Components
	  

A 3-tier multi-user application using a shared database needs to handle concurrency. It happens both with desktop and web applications. In many ways, this also happens to a client/server desktop application accessing a database from several threads.

 

Some databases accept a single connection, while others have different limits. As mentioned before, connection pooling is a helpful feature typically available for high-end database engines (like Microsoft SQL Server and Oracle) using the right data access technology (like ADO and FireDAC).

 

In this section, we will describe how to configure several database components for selected database engines.

---

## 66. FireDAC

### Developer's Guide > Application Design Considerations > Third party Component Libraries > Database Components > FireDAC

来源: https://www.unigui.com/doc/online_help/firedac.htm

#### 章节标题

  - FireDAC
  - FireDAC

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Third party Component Libraries > Database Components >
   
      FireDAC |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

FireDAC
	  

Formerly known as AnyDAC, FireDAC is a widely used set of database components for Delphi. There are some thread-safety considerations when using FireDAC. uniGUI is a fully multithreaded application, so components used in each session must be isolated from other sessions. As described in the section Database Connections, each session should have its own copy of the Connection components. The same principle applies to FireDAC as well. In this Embarcadero document there are guidelines for using FireDAC in a multithreaded application.

 

In uniGUI, each TFDConnection component must be placed on MainModule or a DataModule created from uniGUI Wizard. It is also possible to create and destroy a common datamodule as part of the constructor and destructor of any TUniForm (because they are also private to its session). This will ensure that each session will have its own private TFDConnection component.

 

 

In addition to that, we need to place a TFDManager component on the ServerModule and set its Active property to True in ServerModule's OnCreate event.

 

Other components to place on ServerModule are TFDGUIxWaitCursor and TFDPhysXXXDriverLink. TFDPhysXXXDriverLink is the driver link component for your database engine. For MySQL it should be TFDPhysMySQLDriverLink. For TFDGUIxWaitCursor set Provider to Console and ScreenCursor to gcrNone.

 

In the OnCreate event FDManager1.Active should be set to True.

 

procedure TUniServerModule.UniGUIServerModuleCreate(Sender: TObject);
begin
.
.
.
.
  FDManager1.Active := True;
end;

 

In similar manner, in the OnDestroy event FDManager1.Close should be called.

 

procedure TUniServerModule.UniGUIServerModuleDestroy(Sender: TObject);
begin
.
.
.
  FDManager1.Close;
end;

 

Pooling Connections

 

One of the advanced features in FireDAC is the support for pooled connections. It allows sharing identical database connections among sessions.

 

For details please see:

http://docwiki.embarcadero.com/RADStudio/XE8/en/Multithreading_(FireDAC)

http://docwiki.embarcadero.com/RADStudio/XE8/en/Defining_Connection_(FireDAC)

 

Also see our example project:

 

DBLookupComboBox - Custom Remote Query

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

---

## 67. Using Runtime Packages

### Developer's Guide > Application Design Considerations > Using Runtime Packages

来源: https://www.unigui.com/doc/online_help/using-runtime-packages.htm

#### 章节标题

  - Using Runtime Packages
  - Using Runtime Packages

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations >
   
      Using Runtime Packages |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Using Runtime Packages
	  

One of Delphi's useful features is its support for "Runtime Packages." By using runtime packages, a Delphi application can spread several modules. These modules are BPL runtime packages used by the Delphi IDE itself. These packages are special DLLs dynamically loaded into the application memory space on demand. The size of the main application will be smaller, as any external BPL library will come to memory only when needed.  This feature also allows creating modular applications. You can divide your application modules and forms into smaller libraries which can be loaded in your code when they are needed.

 

uniGUI supports using Runtime Packages and this can be done easily by enabling Link with runtime packages in project options. Once this options is set you must make sure all uniGUI runtime packages are in the Runtime packages list.

 

Below is a list of all runtime packages that are used in a uniGUI application. XX stands for a number which corresponds to your Delphi version. For example, uniGUI25 for Delphi 10.2 Tokyo.

 

uniToolsXX
uIndyXX
uniGUIXXCore
uniGUIXX
uniGUIXXChart
uniGUIXXmCore
uniGUIXXm

 

For 64-bit applications you need 64-bit versions of BPL files. While you can build them from IDE manually by changing the target for each runtime BPL, it is more practical to use batch files to generate 64-bit BPL files. See Building 64-bit library files.

 

It is important to remember that you must make sure that all of the above packages will be linked with your application dynamically. If you include only a subset of these libraries in the Runtime packages list, then it can lead to a situation where some of the uniGUI libraries will be linked statically while others will be loaded dynamically. This must be avoided. You need to either link all of uniGUI libraries statically or all of them dynamically.

 

 

After this setting you will notice that the size of your project executable will be much smaller. For an empty uniGUI project in release mode, the executable size will be around 43KB. Compare that to several megabytes when the project is compiled normally without runtime packages.

 

 

---

## 68. Runtime Packages & C++ Builder

### Developer's Guide > Application Design Considerations > Using Runtime Packages > Runtime Packages & C++ Builder

来源: https://www.unigui.com/doc/online_help/runtime-packages--c-builder.htm

#### 章节标题

  - Runtime Packages & C++ Builder
  - Runtime Packages & C++ Builder

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Using Runtime Packages >
   
      Runtime Packages & C++ Builder |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Runtime Packages & C++ Builder
	  

Unlike Delphi, the C++ Builder default build mode is to link applications with runtime packages. When a new project is created, it will be dynamically linked with runtime packages. You change this setting from the IDE project options. If you want to build your project with runtime packages then you must make sure all uniGUI runtime packages are linked dynamically with your application.

 

Below is a list of all runtime packages that are used in a uniGUI application. XX stands for a number which corresponds to your Delphi version. For example, uniGUI25 for Delphi/C++ Builder 10.2 Tokyo.

 

uniToolsXX
uIndyXX
uniGUIXXCore
uniGUIXX
uniGUIXXChart
uniGUIXXmCore
uniGUIXXm

 

For 64-bit applications you need 64-bit versions of BPL files. While you can build them from IDE manually by changing the target for each runtime BPL, it is more practical to use batch files to generate 64-bit BPL files. See Building 64-bit library files.

 

It is important to remember that you must make sure that all of the above packages will be linked with your application dynamically. If you include only a subset of above libraries in the Runtime packages list then it can lead to a situation where some of uniGUI libraries will be linked statically while others will be loaded dynamically. This must be avoided. You need to either link all of the uniGUI libraries statically or all of them dynamically.

 

---

## 69. Special Considerations

### Developer's Guide > Application Design Considerations > Special Considerations

来源: https://www.unigui.com/doc/online_help/special-considerations.htm

#### 章节标题

  - Special Considerations
  - Special Considerations

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations >
   
      Special Considerations |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Special Considerations
	  

This section lists a few things to take into consideration while coding your web application.

---

## 70. FormatSettings

### Developer's Guide > Application Design Considerations > Special Considerations > FormatSettings 

来源: https://www.unigui.com/doc/online_help/formatsettings-.htm

#### 章节标题

  - FormatSettings
  - FormatSettings

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Special Considerations >
   
      FormatSettings |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

FormatSettings
	  

FormatSettings is a global record in Delphi which is used to keep locale related variables such as DecimalSeparator, CurrencyFormat, CurrencyString, etc. This variable was introduced in Delphi XE. Before Delphi XE, DecimalSeparator, CurrencyFormat, etc. were declared as separate global variables in SysUtils.pas.

 

The problem with FormatSettings is that it is a global variable which doesn't cope with uniGUI's multithreaded environment. To overcome this problem, developers must ensure that FormatSettings is modified only before sessions are started. It is not safe to modify FormatSettings inside sessions. To overcome this problem uniGUI implements two functions which giv access to FormatSettings in a safe way.

 

function FmtSettings: TFormatSettings;
function PFmtSettings: PFormatSettings;

 

The function FmtSettings returns a readonly TFormatSettings record which can be used in various RTL functions such as:

 

FloatToStr(FValue, FmtSettings);

 

The function PFmtSettings returns a pointer to the TFormatSettings record which allows modifications like:

 

PFmtSettings.CurrencyString := '£';

 

When called inside a session context, the above functions will return a private copy of TFormatSettings which belongs to that session. This private instance of TFormatSettings will be used internally in all uniGUI functions which use parameters in TFormatSettings. However, not all internal DB functions use this private copy. Some DB functions such as TField.AsString use the global FormatSettings, so if you want to use a different FormatSettings for each session you must take this into account. The same is true for 3rd-party database tools which use Delphi's global FormatSettings.  

 

On the other hand, if they're called inside the OnCreate event of ServerModule they will set the global FormatSettings used by all sessions in the application.

 

The code below will change the global FormatSettings for all sessions in the application:

 

procedure TUniServerModule.UniGUIServerModuleCreate(Sender: TObject);
begin
  // Change application global format settings
  PFmtSettings.CurrencyFormat := 0;
  PFmtSettings.CurrencyString := '€';
  PFmtSettings.DateSeparator := '/';
  PFmtSettings.ShortDateFormat := 'dd/mm/yyyy';

  PFmtSettings.ThousandSeparator := '.';
  PFmtSettings.DecimalSeparator := ',';

end;

 

When the above functions are called inside a session context, the returned record is not the global instance of FormatSettings record which is defined in SysUtils.pas. Instead, it will be a private instance of TFormatSettings record which is held in TUniGUIApplication class. This means that inside a session you should explicitly include FmtSetting as parameter for RTL functions which use it:

 

Flt := StrToFloat('10.0', FmtSettings);

 

The code below will change the private FormatSettings for current session only:

 

procedure TUniMainModule.UniGUIMainModuleCreate(Sender: TObject);
begin
// Change private format settings for current session
 PFmtSettings.DateSeparator := '/';
 PFmtSettings.CurrencyFormat := 0;
 PFmtSettings.CurrencyString := '$';
 PFmtSettings.ShortDateFormat := 'dd/mm/yyyy';
 PFmtSettings.ThousandSeparator := '.';
 PFmtSettings.DecimalSeparator := ',';

end;

 

 

 

---

## 71. Decimal Separator in Mobile Devices

### Developer's Guide > Application Design Considerations > Special Considerations > FormatSettings  > Decimal Separator in Mobile Devices

来源: https://www.unigui.com/doc/online_help/decimal-separator-in-mobile-de.htm

#### 章节标题

  - Decimal Separator in Mobile Devices
  - Decimal Separator in Mobile Devices

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Special Considerations > FormatSettings  >
   
      Decimal Separator in Mobile Devices |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Decimal Separator in Mobile Devices
	  

There is a detail regarding DecimalSeparator in mobile devices. In mobile devices we need to show the numeric keyboard when input field is a field for number values only. This requires Ext JS to use a html number input type. In this case this input field may use a different decimal separator than is used either for server side or client side. So, based on device, browser type and device language or device locale settings a numeric field may use either a dot or a comma as decimal separator.

 

 

For example in above grid comma is used as decimal separator, but when grid editor is activated in below picture you can see that mobile browser automatically uses dot as decimal separator.

 

 

 

 

---

## 72. Dynamically Created Controls

### Developer's Guide > Application Design Considerations > Dynamically Created Controls

来源: https://www.unigui.com/doc/online_help/dynamically-created-controls.htm

#### 章节标题

  - Dynamically Created Controls
  - Dynamically Created Controls

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations >
   
      Dynamically Created Controls |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Dynamically Created Controls
	  

uniGUI fully supports creating controls at runtime. This advanced feature enables developers to dynamically create UI thanks to the Ext JS framework's capability of creating, inserting and deleting controls dynamically. There is no difference between creating a dynamic control in uniGUI and the VCL. You can simply create the control by assigning it an owner and a parent. However, in uniGUI, all controls should always be created with an owner. Also, in many cases, a parent should always be assigned to the control.

---

## 73. Creating Controls at Runtime

### Developer's Guide > Application Design Considerations > Dynamically Created Controls > Creating Controls at Runtime

来源: https://www.unigui.com/doc/online_help/creating-controls-at-runtime.htm

#### 章节标题

  - Creating Controls at Runtime
  - Creating Controls at Runtime

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Dynamically Created Controls >
   
      Creating Controls at Runtime |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Creating Controls at Runtime
	  

In VCL, the rules for dynamically creating controls are more relaxed compared with uniGUI. For example, in uniGUI, forms and controls can not be created without an owner. In uniGUI, forms must be shown when they are created, while in VCL there is no such restriction.

 

Another important note here is regarding the lifetime management of dynamically created controls. When a control is created dynamically the correct practice is to let them be destroyed by they owners or parents. It is not recommended to destroy controls dynamically in code. Each control with an owner will be destroyed by its owner (or parent) when the owner itself is freed, so under normal conditions there is no need to write additional code to destroy dynamically created controls. The best practice is to allow user actions decide when a control must be freed. For instance, if you have a form which contains several dynamically created controls, these controls will be freed when the user closes the owner form.

 

Let's summarize some of the rules that must be followed when creating controls dynamically:

 

1.uniGUI forms, controls and components must be created with an owner.

2.For forms, the owner should always be the UniApplication object.

3.For controls and components, the owner must be a TUniForm or a TUniFrame descendant.

4.Forms must be shown after they are created. A form can not be created now and shown later.

5.Whenever possible, dynamically created objects must be assigned a unique name.

6.Controls must be assigned a parent after they are created.

7.Assigned parent must be a descendant of TUniContainer, TUniForm or TUniFrame.

8.The correct practice is to not to destroy controls in your code. Let the framework destroys them when the control's owner (or parent) is destroyed.

 

In the code below, a form is created dynamically. As you can see, the owner is the UniApplication object and the form is shown right after it is created.

 

procedure TMainForm.UniButton1Click(Sender: TObject);
begin
  TUniForm1.Create(UniApplication).Show;
end;

 

That syntax can be extended to modify form properties before showing it.

 

procedure TMainForm.UniBitBtn1Click(Sender: TObject);
begin
  with TUniForm1.Create(UniApplication) do
  begin
    Color := clGray;
    BorderStyle := bsNone;
    ShowModal;
  end;
end;

 

In both examples, we don't keep an instance of the created form because in many cases it is unnecessary. A form should be considered as an standalone object which is used and discarded. Of course, you can keep a reference to a form instance, but you must be aware that uniGUI forms are dynamically destroyed when they are closed by the user, so that any variable holding the form's instance will be in an invalid state after the form is closed.

 

To create controls dynamically, we can use form's OnCreate or OnBeforeShow events. Actually, any other event can be used, but if you want to create many dynamic controls it is wise to do this before the form becomes visible.

 

procedure TUniForm1.UniFormCreate(Sender: TObject);
begin
  with TUniButton.Create(Self) do
  begin
    Caption := 'Button1';
    Top := 100;
    Left := 10;
    Parent := Self;
    OnClick := UniButton1Click;
  end;
 
  with TUniLabel.Create(Self) do
  begin
    Caption := 'Button1';
    Top := 140;
    Left := 10;
    Parent := Self;
  end;
end;

 

 

 

---

## 74. Destroying Controls at Runtime

### Developer's Guide > Application Design Considerations > Dynamically Created Controls > Destroying Controls at Runtime

来源: https://www.unigui.com/doc/online_help/destroying-controls-at-runtime.htm

#### 章节标题

  - Destroying Controls at Runtime
  - Destroying Controls at Runtime

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Dynamically Created Controls >
   
      Destroying Controls at Runtime |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Destroying Controls at Runtime
	  

In uniGUI, it is possible to destroy a control at runtime by simply calling its Free() method. This action will remove the control from its parent, will destroy it and all associated resources. While it is possible to destroy uniGUI controls by calling Free(), it is not recommended unless there is a good reason to do so. It is always better to allow uniGUI to manage when controls must be freed. Normally, controls are destroyed when their owner form is closed. If the owner is a TUniFrame, then its child controls will be destroyed when the owner form is closed. In some cases, controls or a TUniFrame may reside inside a tab page (TUniTabSheet) of a page control. Again, if the tab page is closeable, it will be freed when the user closes it. As a result, all of its children controls will be freed as well.

 

You can create controls dynamically at runtime, but you must leave the task to uniGUI when it comes to destroying them. So, as a general rule, all controls must be freed by user actions which are primarily closing forms, closing tab pages, closing a session,  etc.

 

Why we don't prefer destroying components by calling Destroy() or Free() methods? The answer to this question is the asynchronous nature of the web. Consider the following scenario:

 

You have a UniDBGrid populated with data on the screen and you want to destroy it by calling its Free() method. Let's put this method in a button OnClick method.

 

procedure TMainForm.UniButton1Click(Sender: TObject);
begin
  UniDBGrid1.Free;
end;        

 

The above code will destroy DBGrid and remove it from the owner form as expected. The problem here is that there can be a delay between the time the user presses UniButton1 and the time the grid is freed and removed from the form. The communication between server and client can take some time, and this delay could be unnoticeable on a LAN, but on the internet, it can take longer depending on the connection quality. In this small time interval, the user still has access to the DBGrid and can continue navigating inside it. Probably, it will generate events which will go back to the server. However, this time the grid does not exist on the server and those events cannot be processed; the server will raise an exception.

 

This problem can be avoided by enabling screen mask of UniButton1 and blocking user interaction until DBGrid is freed and fully removed from the UI. This patch will resolve this issue, but adds complexity to the app design and requires enabling screen mask for each time there is such a case. The developer can easily forget to enable screen mask because he/she sees no issue on a local network because this problem can only arise on a slow connection over the internet.

 

In short, while it is quite possible to destroy uniGUI visual controls at runtime, it is not recommended for the reasons explained above. The best practice is to allow the framework to free controls with common user actions such as closing forms, closing tab sheets, ending a session and etc.

 

 

---

## 75. Creating or Destroying of Multiple Controls at Runtime

### Developer's Guide > Application Design Considerations > Dynamically Created Controls > Creating or Destroying of Multiple Controls at Runtime

来源: https://www.unigui.com/doc/online_help/creating--destroying-many-cont.htm

#### 章节标题

  - Creating or Destroying of Multiple Controls at Runtime
  - Creating or Destroying of Multiple Controls at Runtime

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Application Design Considerations > Dynamically Created Controls >
   
      Creating or Destroying of Multiple Controls at Runtime |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Creating or Destroying of Multiple Controls at Runtime
	  

If your application requires creating (or destroying) a big number of controls dynamically it is good to call SuspenLayouts()method before proceeding to start creating them.

 

Each SuspendLayouts() call must be paired with a ResumeLayouts() method, preferably in a try..finally block.

 

  SuspendLayouts;
  try
    for I := 1 to 20 do
    begin
      B := TUniDBGrid.Create(Self); // create 20 grids dynamically
      B.DataSource := DataSource1;
      B.Parent := UniContainerPanel1;
      .
      .
      .

 
    end;
  finally
    ResumeLayouts;
  end;
 

Calling SuspendLayouts() is especially useful when you are inserting new controls into an already created and rendered Form or Frame.

---

## 76. Best Practices

### Developer's Guide > Best Practices

来源: https://www.unigui.com/doc/online_help/best-practices.htm

#### 章节标题

  - Best Practices
  - Best Practices

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide >
   
      Best Practices |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Best Practices
	  

After looking at some of the differences between standard VCL desktop applications and web applications (SPA), we are ready to give some concrete guidelines about how to use uniGUI  (and what should be avoided).

 

---

## 77. Handling Concurrency

### Developer's Guide > Best Practices > Handling Concurrency

来源: https://www.unigui.com/doc/online_help/handling-concurrency.htm

#### 章节标题

  - Handling Concurrency
  - Handling Concurrency
  - ServerModule
  - MainModule
  - Free Forms and DataModules
  - Login Form
  - Using Global Form and DataModule references

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices >
   
      Handling Concurrency |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Handling Concurrency
	  

Even if the new application is the result of a migration from a current VCL application which is already multi-user and client/server, a uniGUI application will serve multiple users within the same process.

 

A multi-user client/server VCL application usually has multiple instances of the client application running on several computers, each one of them connects to a shared database server. Almost all database servers support multiple connections by implementing row/table locking when needed.

 

That kind of VCL application is a typical 2-tier application. A similar uniGUI application is a 3-tier application, because the user interface (presentation layer) runs in the client browser, most of the previous application code runs on the server (now serving multiple users/sessions), and it shares the same database server.

 

The fact that the new non-visual code of the uniGUI application serves multiple users requires handling concurrent access to any shared resources. This concurrent access will occur in a multi-threaded manner where each request comes from a different thread.

 

ServerModule

 

Use the ServerModule singleton for global and probably read/only information.

 

Most of the web applications require access to a database server. Some times it will use data access controls like TFDConnection, but it is also possible to use some middleware. In any case, the information about how to connect to the database server should be available to all user sessions. If using a TFDConnection or similar, the program will need to build the correct connection string or instantiate the corresponding components.

 

As mentioned previously, if using FireDAC we should add the TFDManager, the driver for the chosen database, etc. If using a TADOConnection it is enough to have the connection string.

 

After creating the ServerModule, it should only expose read/only properties to the user sessions.

 

Warning: As the ServerModule is a singleton, created when the server starts, introducing read/write variables will block the use of any load balancing technology. uniGUI plans to release its Load Balance Server and it assumes no affinity between users and servers, just between users and sessions; in other words, if a session needs to be restarted, it should be able to run in any available server. Any read/write variable with the right to be shared on the ServerModule should be moved to the shared database (which should take care of the concurrent access by itself).

 

If, despite the previous warning, there is some very important reason to expose here a read/write property, it must be protected by making sure that only one session at a time can modify it. The obvious solution for this kind of protection is to use a critical section.

 

unit ServerModule;
 
interface
 
uses
  Classes, SysUtils, uniGUIServer, uniGUIMainModule, uniGUIApplication,

  uIdCustomHTTPServer, uniGUITypes, SyncObjs;
 
type
  TUniServerModule = class(TUniGUIServerModule)
    procedure UniGUIServerModuleCreate(Sender: TObject);
    procedure UniGUIServerModuleDestroy(Sender: TObject);
  private
    FConnectionString   : string;
    FSharedVariable     : string;
    FLockSharedVariable : TCriticalSection;
 
    function  GetSharedVariable : string;
    procedure SetSharedVariable(const Value : string);
  protected
    procedure FirstInit; override;
  public
 
    property ConnectionString : string read  FConnectionString;
    property SharedVariable   : string read  GetSharedVariable

                                       write SetSharedVariable;
  end;
 
function UniServerModule: TUniServerModule;
 
implementation
 
{$R *.dfm}
 
uses
  UniGUIVars;
 
function UniServerModule: TUniServerModule;
begin
  Result:=TUniServerModule(UniGUIServerInstance);
end;
 
procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
end;
 
procedure TUniServerModule.UniGUIServerModuleCreate(Sender: TObject);
begin
  FConnectionString   := 'Some Connection String';
  FSharedVariable     := 'Shared';
  FLockSharedVariable := TCriticalSection.Create;
end;
 
procedure TUniServerModule.UniGUIServerModuleDestroy(Sender: TObject);
begin
  FLockSharedVariable.Free;
end;
 

function TUniServerModule.GetSharedVariable : string;
begin
  FLockSharedVariable.Acquire;
  try
    Result := FSharedVariable;
  finally
    FLockSharedVariable.Release;
  end;
end;

 
procedure TUniServerModule.SetSharedVariable(const Value : string);
begin
  FLockSharedVariable.Acquire;
  try
    FSharedVariable := Value;
  finally
    FLockSharedVariable.Release;
  end;
end;
 
initialization
  RegisterServerModuleClass(TUniServerModule);
end.

 

In this case, the connection string was assigned when creating the ServerModule, and it is a read/only property. However, the SharedVariable is a read/write property, and we must make sure that only one user can write to it. We are enforcing the single access to the variable by using a critical section. Even more, we are hiding this fact in the SetSharedVariable method so that it is not necessary to know, acquire, nor release the TCriticalSection object when accessing the property. Of course, by allowing to modify that property, we also need to control the readings. Any read/write property will slow down the application (depending on how frequently it accesses the variable).

 

It is important to note that while you can use writable shared variables in ServerModule as defined above, it is not recommended to rely it as an application wide global variable. In future each uniGUI application can be divided into many several smaller processes to implement load-balancing and other advance feature. In this case any shared global variable in ServerModule will be visible to its owner process only not to the other processes which will server same application in a pool of processes. For this, it is recommended to keep such global variables in a database table instead of keeping them in memory.

 

MainModule

 

Use the MainModule for user session variables.

 

Using RAD Studio for Delphi development generates correct code for a single-user VCL application, but some of that code will create issues in a multi-user or multithreaded environment. Let's give a few examples, showing why it will fail and how to fix it.

 

After asking to create a new VCL form we get this code:

 

unit Unit1;
 
interface
 
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,

  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;
 
type
  TForm1 = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
var
  Form1: TForm1;
 
implementation
 
{$R *.dfm}
 
end.

 

Notice the global variable Form1. You may be tempted to use it from other unit like this:

 

unit Unit2;
 
interface
 
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,

   System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

   Vcl.StdCtrls;
 
type
  TForm2 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
var
  Form2: TForm2;
 
implementation
 
uses
  Unit1;
 
{$R *.dfm}
 
procedure TForm2.Button1Click(Sender: TObject);
begin
  Form1 := TForm1.Create(Self);
  try
    Form1.ShowModal; 
  finally
    Form1.Free;
  end; 
end;

 
end.

 

Form1 is accessible to any user session, and several users could be using it. Imagine what will happen if two users created the same variable (causing a memory leak of one form and an invalid reference when releasing the surviving form).

 

A simple fix will avoid that situation:

 

procedure TForm2.Button1Click(Sender: TObject);
begin
  with TForm1.Create(Self) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

 

As you can see, in uniGUI we don't even need to keep an instance of the form in a variable. In other words, we don't need and we shouldn't have global variables. Delete all automatically generated global variables and create your own private instance. This is a good habit for VCL applications and it requires fixing forms and data modules.

 

unit Unit3;
 
interface
 
uses
  System.SysUtils, System.Classes;
 
type
  TDataModule1 = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 

// this is a global variable and can not be used in uniGUI
var
  DataModule1: TDataModule1;

 
implementation
 
{$R *.dfm}
 
end.

 

uniGUI is more than just a set of components for rendering the presentation layer; it is also a framework supporting the best practices for web application development. Among the supported best practices is the absence of automatically generated global variables and the automatic memory management of forms and data modules attached to a user session.

 

Instead of the global variable Delphi creates for forms and data modules, uniGUI creates functions which returns the session instance based on the previously registered type. Let's examine MainModule as a typical example.

 

unit MainModule;
 
interface
 
uses
  uniGUIMainModule, SysUtils, Classes;
 
type
  TUniMainModule = class(TUniGUIMainModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function UniMainModule: TUniMainModule;
 
implementation
 
{$R *.dfm}
 
uses
  UniGUIVars, ServerModule, uniGUIApplication;
 
function UniMainModule: TUniMainModule;
begin

  // returns the correct instance of MainModule for current session
  Result := TUniMainModule(UniApplication.UniMainModule)
end;
 
initialization
  RegisterMainModuleClass(TUniMainModule);
end.

 

Notice the call to RegisterMainModuleClass during initialization. When needing access to the session's MainModule, it is enough to use the function UniMainModule . Another session function, UniApplication, will return the instance of the registered MainModule corresponding to the current session.

 

The same kind of solution applies to session forms and modules. If we use the uniGUI Wizard for creating a new form, and select Application Form, we will get this:

 

unit Unit1;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm;
 
type
  TUniForm1 = class(TUniForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function UniForm1: TUniForm1;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function UniForm1: TUniForm1;
begin

  // returns the correct instance of UniForm1 for current session
  Result := TUniForm1(UniMainModule.GetFormInstance(TUniForm1));
end;
 
end.

 

But uniGUI also manages the lifetime of the form. Let's see how we use that form:

 

unit Main;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniButton;
 
type
  TMainForm = class(TUniForm)
    btnShow: TUniButton;
    btnShowModal: TUniButton;
    procedure btnShowClick(Sender: TObject);
    procedure btnShowModalClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function MainForm: TMainForm;
 
implementation
 
{$R *.dfm}
 
uses
  uniGUIVars, MainModule, uniGUIApplication,
  uniGUIDialogs,
  Unit1;
 
function MainForm: TMainForm;
begin

  // returns the correct instance of MainForm for current session
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;
 
procedure TMainForm.btnShowClick(Sender: TObject);
begin
  UniForm1.Show;
end;
 
procedure TMainForm.btnShowModalClick(Sender: TObject);
begin
  UniForm1.ShowModal; // Synchronous mode
  ShowMessage('Result = ' + IntToStr(UniForm1.ModalResult));
end;
 
initialization
  RegisterAppFormClass(TMainForm);
 
end.

 

In the previous VCL code we needed to create the temporary instance of the form, open it using ShowModal, and release it (we used try ... finally to avoid a memory leak).

 

This code only needs a call: UniForm1.ShowModal. Why?

 

UniForm1 creates a temporary form which is automatically released upon reaching the end of its lifetime, but it will be available until that moment.

 

What about showing a non-modal form? uniGUI forms are automatically released when closed.

 

If you need just a few data modules, you can use the MainModule for sharing your connection and other session variables, and create these data modules as "Application Data Modules". They will be attached to the session and managed by uniGUI. The code is very similar to the previous form.

 

unit Unit2;
 
interface
 
uses
  SysUtils, Classes;
 
type
  TDataModule2 = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function DataModule2: TDataModule2;
 
implementation
 
{$R *.dfm}
 
uses
  UniGUIVars, uniGUIMainModule, MainModule;
 
function DataModule2: TDataModule2;
begin

  // returns the correct instance of DataModule2 for current session
  Result := TDataModule2(UniMainModule.GetModuleInstance(TDataModule2));
end;
 
initialization
  RegisterModuleClass(TDataModule2);
 
end.

 

If you have many forms or the data modules consume many resources, any form could handle its own data module manually by creating it on FormCreate and releasing it on FormDestroy. Still, by creating the data module as a uniGUI data module, no global variable will be created, it won't be necessary to create it in FormCreate, and if the developer forgets to release the data module in FormDestroy, it will be automatically released when closing the user session.

 

As the MainModule is automatically created for each new user, all variables attached to a session should be accessible through it. Never use global variables.

 

Free Forms and DataModules

 

In uniGUI you can also create free forms and datamodules. They are referred as free because their lifetime is managed by the developer, not the framework.

 

Login Form

 

Once the MainModule exists, uniGUI runtime will check if a login form was registered. You can create the login form using the uniGUI Wizard for creating forms and selecting "Login Fom". The only difference with any other application form is that it inherits from TUniLoginForm and it will be automatically displayed when a new session is started.

 

unit LoginFormUnit1;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm;
 
type
  TUniLoginForm1 = class(TUniLoginForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function UniLoginForm1: TUniLoginForm1;
 
implementation
 
{$R *.dfm}
 
uses
  uniGUIVars, MainModule, uniGUIApplication;
 
function UniLoginForm1: TUniLoginForm1;
begin
  Result := TUniLoginForm1(UniMainModule.GetFormInstance(TUniLoginForm1));
end;
 
initialization
  RegisterAppFormClass(TUniLoginForm1);
 
end.

 

When implementing the functionality of this form, it is important to remember that it can only use the ServerModule, DataModule, and any other temporary form using them, but not the MainForm. In fact, no form should ever access the MainForm, but the MainModule.

 

Using Global Form and DataModule references

 

In uniGUI Application Forms, Application DataModules and MainModule are referenced with global functions which returns an instance of that object for the current session.

 

For forms, this function replaces the standard variable created in VCL applications. It allows to keep the same syntax for accessing the forms.

 

  UniForm1.Show;

 

In the above code, calling the UniForm1 function will create an instance of TUniForm1 or return the existing instance (making it a singleton). It can be used to easily create and display forms. One important detail here is that these functions should not be used as global references for those forms or data modules. It is not recommended to call a form's global function from other forms or data modules for any purpose other than displaying that form.

 

The uniGUI framework manages the lifetime of all previous "application" objects (forms and datamodules). Each uniGUI session/MainModule keeps a list of managed forms and datamodules. A call like UniMainModule.GetFormInstance(TUniForm1) asks for a singleton of that specific form (TUniForm1). If that instance doesn't exist, it will be created. If the instance was already created, it will be returned.

 

In addition to the singleton factories, uniGUI also tries to optimize memory usage. The application datamodules will be automatically released when closing the session (because there is no way to know if they are in use), but forms are released as soon as they are not in use. For example, after exiting from a call to ShowModal, and receiving the result, that form can be safely released.

 

Using functions for accessing a form instead of global variables provides two advantages:

•Each session has access to its own form, and only one (like a singleton per session)

•Application forms are managed by the uniGUI framework, becoming on-demand resources

 

 

---

## 78. N-Tier web applications

### Developer's Guide > Best Practices > N-Tier web applications

来源: https://www.unigui.com/doc/online_help/n-tier-web-applications.htm

#### 章节标题

  - N-Tier web applications
  - N-Tier web applications

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices >
   
      N-Tier web applications |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

N-Tier web applications
	  

N-tier applications are layered applications where each layer should only know and access the layer immediately below it. This approach provides many advantages, even for monolithic applications like a VCL application using an embedded database server.

 

However, when the layers are physically separated it is even better. A typical 2-tier application is a client/server VCL application connected to a shared database server. In this case, both tiers are clearly identifiable and separated.

 

Creating the equivalent uniGUI web application will automatically create a 3rd tier, physically running in the browser, dynamically created and transmitted to the client browser from the uniGUI application.

 

The developer must be aware of that physical separation between the presentation layer and the business layer (no matter how good it is concerning Object Oriented Design). In the new application, some code runs on the client, while other code runs on the server. There are client-side events, server-side events, and dynamic AJAX requests coming from the client which must be answered by the server.

 

A very important difference is the asynchronous character of the typical web application. The server application dynamically renders the client web page and wait for client events from all sessions; it is not supposed to wait in a message loop for a particular session as VCL applications do.

 

It is even more important to know about how to interact with huge amounts of data (in the end, most of these applications need a shared database server on the back-end).

 

---

## 79. Synchronous and Asynchronous Operations

### Developer's Guide > Best Practices > N-Tier web applications > Synchronous and Asynchronous Operations

来源: https://www.unigui.com/doc/online_help/synch-and-asynch-operations.htm

#### 章节标题

  - Synchronous and Asynchronous Operations
  - Synchronous and Asynchronous Operations
    - Asynchronous Mode
    - Synchronous Mode
      - ShowModal
      - Blocking Modals
      - Progress Bar
      - Synchronous processing using ShowMask
      - Synchronize waiting for events or timeout

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > N-Tier web applications >
   
      Synchronous and Asynchronous Operations |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Synchronous and Asynchronous Operations
	  

By default, uniGUI applications are standard web applications working in asynchronous mode. It means that the server doesn't need to block a session thread while waiting for a user response coming from the client.

 

Asynchronous Mode

 

How to use ShowModal in this mode?

 

Let's use a very simple example. We will create a form for entering a person name with buttons for accepting or canceling the request. Another form will use the previous form for updating its own internal field FFullName.

 

unit Unit3;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniButton, uniEdit, uniGUIBaseClasses, uniLabel;
 
type
  TUniForm3 = class(TUniForm)
    UniLabel1: TUniLabel;
    edtFullName: TUniEdit;
    btnOk: TUniButton;
    btnCancel: TUniButton;
  private
    function GetFullName: string;
    { Private declarations }
  public
    { Public declarations }
 
    property FullName : string read GetFullName;
  end;
 
function UniForm3: TUniForm3;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function UniForm3: TUniForm3;
begin
  Result := TUniForm3(UniMainModule.GetFormInstance(TUniForm3));
end;
 
{ TUniForm3 }
 
function TUniForm3.GetFullName: string;
begin
  if edtFullName.Text = '' then
    Result := 'John Doe'
  else
    Result := edtFullName.Text;
end;
 
end.

 

This form will return the entered full name or 'John Doe' if the full name was empty. Its result will depend on pressing the button OK or Cancel (or closing the form). How we use it?

 

unit Unit1;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniButton;
 
type
  TUniForm1 = class(TUniForm)
    btnGetFullName: TUniButton;
    procedure btnGetFullNameClick(Sender: TObject);
  private
    { Private declarations }
 
    FFullName : string;
  public
    { Public declarations }
  end;
 
function UniForm1: TUniForm1;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication,
  Unit3;
 
function UniForm1: TUniForm1;
begin
  Result := TUniForm1(UniMainModule.GetFormInstance(TUniForm1));
end;
 
procedure TUniForm1.btnGetFullNameClick(Sender: TObject);
begin
  UniForm3.ShowModal
  (
    procedure (Sender: TComponent; AResult: Integer)
    begin

      if TModalResult(AResult) = mrOk then
        FFullName := (Sender as TUniForm3).FullName;
    end
  );
end;
 
end.

 

What happens here?

 

•We start by pressing the button GetFullName.

•As soon as we call UniForm3, an instance of the form TUniForm3 will be created and returned.

•The call to ShowModal will popup the form and it will behave like a client-side modal form (meaning that no further interaction is allowed outside of this form).

•However, server-side, the program will continue, which in this case means that it will exit the OnClick event handler.

•At this point, the server finished the previous request (that is, the OnClick event triggered client-side by the user).

•When the user finally clicks any of the buttons (Ok or Cancel) or close the form, another request will go to the server: handle the ShowModal result for that form.

•The server will identify the user session, and will execute the anonymous method which still keeps the reference to UniForm3 (standard behavior for anonymous methods).

•Once the anonymous method is executed, the form UniForm3 will be available for disposal (its lifetime being managed by the uniGUI framework).

 

Synchronous Mode

 

It is always preferred to create the web application in asynchronous mode, but when migrating old VCL applications, the developer could find scenarios which couldn't be implemented or that will make the task too difficult. If necessary, uniGUI can be forced to work as a typical VCL application.

 

If the developer needs to reproduce the synchronous mode available in VCL applications, the property MainModule.EnableSynchronousOperations must be set to true.

 

ShowModal

 

How to use ShowModal in this mode?

 

procedure TUniForm1.btnGetFullNameClick(Sender: TObject);
begin
  if UniForm3.ShowModal = mrOk then
    FFullName := UniForm3.FullName;
end;
 

This is the same code we typically use for VCL applications. It also stops the execution after calling ShowModal until a result is returned. This kind of code requires spawning a thread in the server which will be waiting for the client request/answer. As you can expect, this kind of applications consumes more resources than a standard web application. Fortunately, uniGUI uses an internal thread-pool to minimize thread usage, but for each waiting modal window a thread will be consumed. After the modal window is closed, the waiting threads will be returned to the thread pool for future usage.

 

In addition to ShowModal, uniGUI allows to execute synchronous operations in other scenarios. Let's examine some demos.

 

Blocking Modals

 

There is one demo illustrating blocking modals, "BlockingModals".

 

\

 

The next code shows how each function is now a blocking call like it was in VCL.

 

procedure TMainForm.btnShowModalClick(Sender: TObject);
var
  M : TModalResult;
begin
  M := UniForm1.ShowModal;
 
  case M of
    mrOK  : ShowMessage('OK');
    mrCancel  : ShowMessage('Cancel');
    mrNone  : ShowMessage('None');
  end;
 
  ShowMessage('Done, ' + UniForm1.UniEdit1.Text);
end;
 
procedure TMainForm.btnMessageDlgClick(Sender: TObject);
var
  Res : Integer;
begin
  Res :=  MessageDlg('Test', mtConfirmation, mbYesNoCancel);
 
  case Res of
    mrYes  : ShowMessage('Yes');
    mrNo  : ShowMessage('No');
    mrCancel  : ShowMessage('Cancel');
  end;
end;
 
procedure TMainForm.btnPromptClick(Sender: TObject);
var
  sResult : string;
begin
  if Prompt('Please type something?', 'Value',
       mtInformation, mbYesNoCancel, sResult, True) = mrYes then
    ShowMessage('Result: ' + sResult);
end;
 
procedure TMainForm.btnNestedCallsClick(Sender: TObject);
var
  sResult : string;
begin
  if UniForm1.ShowModal = mrOK then
    if Prompt('Please type something?', '',
         mtInformation, mbYesNoCancel, sResult, True) = mrYes then
      if MessageDlg('Continue?', mtConfirmation, mbYesNoCancel) = mrYes then
        ShowMessage('Result: ' + sResult + ' ' + UniForm1.UniEdit1.Text );
end;
 
procedure TMainForm.btnNestedForms1Click(Sender: TObject);
begin
  if UniForm1.ShowModal = mrOK then
    if UniForm2.ShowModal = mrOK then
      if UniForm3.ShowModal = mrOK then
        if UniForm4.ShowModal = mrOK then
        begin
          ShowMessage('All shown!');
        end;
end;
 
procedure TMainForm.btnNestedForms2Click(Sender: TObject);
begin
  if UniForm5.ShowModal() = mrOK then
    ShowMessage('Completed');
end;
 
procedure TMainForm.btnFileUploadClick(Sender: TObject);
begin
  if UniFileUpload1.Execute then
  begin
    ShowMessage('File upload completed.' +
                ^M^M'Filename: ' + UniFileUpload1.FileName +
                ^M^M'Temporary file is located under:' +
                UniFileUpload1.CacheFile);
  end;
end;

 

Progress Bar

 

Demo "SyncClientUpdate-1" shows how to update a progress bar while executing a lengthy task.

 

 

Once the user clicks the button Start, this is the kind of code achieving the desired behavior:

 

begin
  FCancelled := False;
 
  UniProgressBar1.Min := 1;
  UniProgressBar1.Max := MAX_FILES;
  btnStart.Enabled  := False;
  btnCancel.Enabled := True;

 

  // Reset Progressbar and Label
  UpdateClient(0);
 

  // Initial refresh before entering the loop.

  // (Progressbar and Label will be refreshed)
  UniSession.Synchronize;
 
  N := 0;
  try
    for I := 1 to MAX_FILES do
    begin

      // Refresh the client at "X_INTERVAL" intervals
      if UniSession.Synchronize(X_INTERVAL) then
        UpdateClient(N);
 

      // Check if operation is cancelled.

      // (Either when Cancel button is pressed or Form is closed)
      if FCancelled then Break;
 
      // perform some tasks here
      CreateDummyFile(I);
 
      Inc(N);   // +1 number of created files
    end;
 
    UpdateClient(N);
  finally
    btnStart.Enabled  := True;
    btnCancel.Enabled := False;
  end;
end;

 

The call UniSession.Synchronize forces an immediate update. Passing an argument allows to synchronize at a controlled period (every some milliseconds).

 

Synchronous processing using ShowMask

 

Demo "SyncClientUpdate-3" executes a sequence of tasks with status updates and using ShowMask for avoiding user interaction with other visual controls.

 

 

The code for the Start button is:

 

begin
  UniLabel1.Caption := '';
  UniLabel2.Caption := '';
  UniLabel3.Caption := '';
  UniCheckBox1.Enabled := False;
 
  UniImage1.Hide;
 
  UniProgressBar1.Position := 0;
  UniButton1.Enabled := False;
 
  ShowMask('Level 1 in progress ..');
  UniSession.Synchronize;
 
  Sleep(1000);
 
  UniProgressBar1.Position := 1;
  UniLabel1.Caption := 'Level 1 Completed';
  UniLabel1.Font.Style := [fsBold];
  HideMask;

 
  ShowMask('Level 2 in progress ....');
  UniSession.Synchronize;
 
  Sleep(1000);
 
  UniProgressBar1.Position := 2;
  UniLabel2.Caption := 'Level 2 Completed';
  UniLabel2.Font.Style := [fsBold];
  HideMask;

 
  ShowMask('Level 3 in progress ......');
  UniSession.Synchronize;
 
  Sleep(1000);
 
  UniProgressBar1.Position := 3;
  UniLabel3.Caption := 'Level 3 Completed';
  UniLabel3.Font.Style := [fsBold];
  HideMask;

 
  ShowMask('Last level in progress ........');
  UniSession.Synchronize;
 
  Sleep(1000);
 
  UniProgressBar1.Position := 4;
  UniImage1.Show;
  UniButton1.Enabled := True;
  UniCheckBox1.Enabled := True;
  HideMask;
end;

 

Synchronize waiting for events or timeout

 

Demo "SyncClientUpdate-5" shows the difference between Synchronize(Wait : boolean) and Synchronize(Delay : integer).

 

 

Pressing the button "Start No Wait" will move the UniPanel1 to the bottom right corner 5 pixels every 200 milliseconds (showing the movement).

 

Pressing the button "Start" will accomplish the same, but each step will happen only when some client-side event is detected (for example, pressing the dummy button "Press!" or resizing the form.

 

The code is:

 

procedure TMainForm.btnStartNoWaitClick(Sender: TObject);
begin
  btnStart.Enabled := False;
  btnStartNoWait.Enabled := False;
 
  while UniPanel1.Top < Self.Height - 150 do
  begin
    if UniSession.Synchronize(200) then // wait 200 ms
    begin
      UniPanel1.Top := UniPanel1.Top + 5;
      UniPanel1.Left := UniPanel1.Left + 5;
    end
    else
      Sleep(10);
  end;
 
  UniPanel1.Top := 5;
  UniPanel1.Left := 5;
  btnStart.Enabled := True;
  btnStartNoWait.Enabled := True;
end;
 
procedure TMainForm.btnStartClick(Sender: TObject);
begin
  FStopped := False;
 
  btnStart.Enabled := False;
  btnPress.Enabled := True;
  btnStop.Enabled := True;
 
  while not FStopped do
  begin
    UniSession.Synchronize(True); // wait until next event
 
    UniPanel1.Top  := UniPanel1.Top + 5;
    UniPanel1.Left := UniPanel1.Left + 5;
  end;
 
  UniPanel1.Top := 5;
  UniPanel1.Left := 5;
  btnStart.Enabled := True;
  btnPress.Enabled := False;
  btnStop.Enabled := False;
end;
 
procedure TMainForm.btnPressClick(Sender: TObject);
begin
// Dummy Event generator
end;

 

---

## 80. Database-Centric Applications

### Developer's Guide > Best Practices > N-Tier web applications > Database-Centric Applications

来源: https://www.unigui.com/doc/online_help/database-centric-applications.htm

#### 章节标题

  - Database-Centric Applications
  - Database-Centric Applications
    - Database
    - Database Access
    - Data Controls (server and client)

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > N-Tier web applications >
   
      Database-Centric Applications |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Database-Centric Applications
	  

Most of the web applications require some persistent storage which usually means a shared database. In this kind of applications it is possibly to identify several layers:

 

1.The database server hosting the database.

2.The data access technology for connecting the application to the database

3.The web application

4.One or several clients running on many browsers.

 

While the clients could be connected from the Internet or from the local Intranet, the web application server needs a much better/closer connection to the database server for achieving a reasonable performance when answering client requests.

 

Accessing the database directly from the web application server (meaning that the item 2 will be part of it) increases the use of resources on the server, risking its stability and scalability.

 

Taking into account the limited bandwidth available between the clients and the server, it is important to limit the amount of information sent to the client (or coming back from it).

 

As one web server will be answering the requests coming from several clients, it is also important to limit the amount of information required for the client functionality.

 

Having one shared database server also means that the database should be optimized for multiple connections requesting access to that shared resource.

 

Let's mention a few best practices for handling this kind of applications.

 

Database

 

An enterprise-class application using a shared database as persistent storage usually follows some best practices:

 

•Instead of using the same tables for all purposes, it separates them by tasks. It is even possible to have different databases hosted by different servers. One of the databases takes care of the online transaction processing (OLTP), while other provides data for complex reports (OLAP).

•The OLTP database should be in 3rd Normal Form (3NF), making it easier to keep its integrity. It should be optimized for fast data-entry, updates, and simple queries (indexes should be optimized for the expected use). Complex updates should use transactions (so that a transaction could be rolled back at once).

•If the amount of transactions slows down the database, it is worth evaluating the option of moving transactions (which at that time could be considered read/only) to a secondary database used for historical purposes or as data source for the OLAP database.

•The OLAP database should be optimized for complex queries with fast response time. As a result, it usually aggregates data, and it adds dimensions. The most typical architecture is a big fact table in a star schema.

•Any heavy processing of the data stored on the database should be done on the database server (imagine what could happen if we wanted to modify millions of records in a table by reading them from the application server and posting them back!). Even if some modern developers think of the database as just an object storage, an enterprise-class database server can host some business logic as stored procedures which can have a dramatic impact in performance.

•Avoid triggering synchronous actions based on client requests unless strictly necessary. For example, if we need to publish/log any update to the database to a remote server or web service, it is better to leave a notification in a local table and process the notifications in a background job.

 

None of the previous best practices are specifically related to uniGUI, they apply to any data-centric application.

 

Database Access

 

Having a powerful database server and a fast connection to it doesn't mean that we should request information we don't need. A database table could hold millions of rows, but we should never ask for ALL of them, as there is no practical purpose in doing so.

 

Let's assume that we are accessing the database using a data module, a database connection (FireDAC TFDConnection or similar), and a query. What will happen if we ask for ALL the records from the previous HUGE table? Obviously, after some time (it could be a long time depending on the amount of memory available on the server) we will receive an exception "Out of Memory". Do we really need to ask for all records? No, we are just applying the same techniques we used for small applications.

 

The most important best practice when accessing a database is to ask for enough information, just what we need, never more.

 

It is also important to know the specific technology we are using for accessing the database:

•Some of these technologies are smart enough to accept a request to open such a query, but deliver the data using a clever paging algorithm. The developer will know how many records are available, but the paging process will deliver them only when needed.

•Other technologies require manual configuration for avoiding massive data loads and a having to fetch all records just to report the RecordCount.

•Most of the middleware products take care of these issues (like RemObjects DataAbstract, kbmMW and DataSnap).

 

The simplest solution to this kind of issues is to make sure that any information requested by the user is always filtered. If the amount of records is bigger than some predefined limit, the request could be rejected, and the user should provide a narrower filter.

 

Another option is to accept the original request, but take care of the paging (if not supported natively by the data access technology).

 

Above all things, as a principle, the amount of information the user is capable of using is always very small, never send superfluous information (in quality and quantity).

 

Data Controls (server and client)

 

In the layered approach of N-Tier applications, each layer should concern only about how to answer requests from the next layer by translating them to requests to the previous layer.

 

Any uniGUI data control makes requests to the previous layer through datasets.

The client-side Ext JS component (rendered dynamically by the uniGUI server) shows the data received and accepts the user input for making further Ajax requests back to the server.

 

It is obvious that this traffic should be kept at a minimum.

 

Let's see a few examples about how uniGUI implements the previous best practice:

•TUniEdit - Property CheckChangeDelay allows to trigger the OnChange event only after some time (useful when filtering a dataset based on the changed value).

•TUniDBLookupComboBox - Allows to enable a custom RemoteQuery which can be optimized according to the information the user is typing (there is also a RemoteDelay).

•TUniDBGrid - It provides column filtering, paging, client-side navigation, etc.

 

---

## 81. User Interface

### Developer's Guide > Best Practices > User Interface

来源: https://www.unigui.com/doc/online_help/user-interface.htm

#### 章节标题

  - User Interface
  - User Interface
  - VCL alignment vs web alignment
      - VCL
      - Web
        - Alignment in Containers
        - 
        - Panels
  - FieldSets
    - TUniFieldSet
    - TUniFieldContainer
  - Separate User Interface from Business Logic
    - Use interfaces, not forms
      - Extract an interface exposing the form behavior
      - Modify both forms to implement the interface
      - 
      - Don't reference the forms, but the interface
      - 
    - Don't access forms, except for creating and releasing instances
    - Never introduce business logic code in forms, take advantage of Delphi features
      - Database controls and its events
      - Requesting actions from the View without writing code (platform-independent)
        - Create an interface as a facade to platform-dependent services
        - Use Dependency Injection for registering multiple implementations of the same form interface

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices >
   
      User Interface |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

User Interface
	  

uniGUI conveniently integrates with the RAD Studio VCL designer to leverage the knowledge of current developers, but the designer is incapable of rendering the exact user experience of the real application running in a web browser.

 

As was already mentioned before, VCL components are incompatible with uniGUI, but the uniGUI components keep several VCL properties which provides better compatibility when migrating VCL applications to uniGUI applications. However, uniGUI components render ExtJS components which are specifically designed and optimized for the web. That being said, even standard uniGUI components like TUniPanel take advantage of web features, while other components don't have an equivalent in the VCL. uniGUI components become Sencha Ext JS components running in the client browser, and Sencha is continuously improving their components and creating new components.

 

The best practice when creating the uniGUI user interface is to configure the components for the web, and to use the best components optimized for the web.

 

Let's show how to apply this best practice by making a comparison between VCL alignment and client-side alignment, and learning how to use TUniFieldSet and TUniFieldContainer.

 

VCL alignment vs web alignment

 

VCL alignment happens server-side, while web alignment executes it immediately client-side. If the developer uses a TPanel control with a TSplitter to adjust the panel width, dragging the TSplitter will create a sequence of requests to the server which will send updates to the client to render the changes. It is costly and makes the user interface less responsive.

 

VCL

 

Some of the VCL control properties are:

•Height

•Width

•Top

•Left

•Align - alNone, alTop, alBottom, alLeft, alRight, alClient

 

Windows, and the VCL, which is an object oriented, component-based, encapsulation of Windows visual objects, are both based on screen physical coordinates (it is the reason for our current troubles with high resolution displays using much higher DPI).

 

The World Wide Web must cope with very different client devices, and it is based on relative positions.

 

uniGUI keeps the same VCL properties, but it also allows to override the VCL behavior and take advantage of the more powerful and flexible web properties.

 

Web

 

Alignment in Containers
 

Some of the Web properties are:

•AlignmentControl - uniAlignmentClient, uniAlignmentServer

•Layout - absolute, accordion, anchor, auto, border, fit, form, hbox, vbox, table, column

•LayoutAttribs

oAlign - top, middle, bottom, stretch, stretchmax

oColumns

oPack - start, center, end

oPadding

•LayoutConfig

oAnchor

oBodyPadding

oColSpan

oColumnWidth

oDockWhenAligned

oFlex

oHeight

oIgnorePosition

oMargin

oPadding

oRegion - north, south, east, west, center (equivalent to alTop, alBottom, alRight, alLeft, alClient)

oRowSpan

oSplit - To enable an automatic client-side splitter

oWidth

 

 

In the folder Demos there are several projects which show how to use the previous properties:

•Clientside Alignment - Dock and Align

•Clientside Alignment - Layout Accordion

•Clientside Alignment - Layout Anchor

•Clientside Alignment - Layout Border

•Clientside Alignment - Layout Column

•Clientside Alignment - Layout Fit

•Clientside Alignment - Layout Form

•Clientside Alignment - Layout HBox

•Clientside Alignment - Layout Percentage

•Clientside Alignment - Layout VBox

•Clientside Alignment - Layout Table

•Clientside Alignment - Layout Table Span

•Clientside Alignment - Features Demo

 

Panels

 

UniGUI panels are also collapsible. The corresponding properties are:

•Collapsed

•CollapseDirection - cdBottom, cdDefault, cdLeft, cdRight, cdTop

•Collapsible

 

The demo Collapsible Panels shows several collapsible panels.

 

Collapsible Panels with server-side alignment

 

This demo starts with some collapsed panels and all four of them can be collapsed or expanded using the corresponding buttons. You will notice that each collapse/expand request requires a trip to the server to render the new layout. Try changing that behavior by changing the form AlignmentControl to uniAlignmentClient and configuring the controls using the previously described web properties. Confirm that the new application executes layout changes much faster (there is no further need to ask the server for a new render).

 

FieldSets

 

TUniFieldSet

 

The uniGUI control TUniFieldSet contains fields (uniGUI controls/editors) which should be arranged in one column. This container will render each field according to common properties:

•FieldLabel

•FieldLabelAlign - alLeft, alRight, alTop

•FieldLabelFont

•FieldLabelSeparator - default ':'

•FieldLabelWidth

 

Among the uniGUI controls which could be included in a TUniFieldSet is the TUniFieldContainer, which allows to create hierarchical forms like:

 

TUniFieldSet and TUniFieldContainer(s) - UniFieldContainer example

 

TUniFieldContainer

 

The container arranges the fields according to the web layout requested. In the previous example, FieldContainer3 is using layout table with 3 columns.

 

FieldContainer3

 

The TUniFieldContainer renders the fields in the order they were created. If that order is or becomes incorrect, the property CreateOrder should be used to indicate the desired order. The default value is zero, meaning that they should be the last fields. The desired order starts with one, and the fields will be saved on the .DFM file in that order.

 

Separate User Interface from Business Logic

 

Delphi is a RAD environment which encourages development speed. It is easy to create a small application just by dropping a few components on a form, changing some properties, adding a few event handlers, and implementing the real code which was the original goal of the application. In a few minutes, you could have a working application. It is true; RAD Studio makes it possible. But it is also true that most of the time, that application will not be a good foundation for a bigger project. Merging the user interface with the business logic, adding visual controls and data access components, having all kind of event handlers in the same unit is a good recipe for failure.

 

There are many solutions for disconnecting the presentation layer and the business logic. Everyone knows about MVC (Model-View-Controller), MVP (Model-View-Presenter), MVVM (Model-View-ViewModel), and similar design patterns. While some of these patterns are generic and could be implemented in several languages, development environments, and supporting frameworks, some of them are better for specific scenarios. For example, MVVM was specifically designed to take advantage of WPF (Windows Presentation Foundation), XAML, and event-driven programming.

 

Despite the Delphi RAD environment, several of its features allow achieving the previous goal, not necessarily following strict patterns.

 

Use interfaces, not forms

 

Let's start by showing how to apply one of the more important best practices: code against interfaces, not concrete classes.

 

Our program could run as a desktop application or as a Web application, but our business logic will require user interaction. If we need to ask the user for some information, we will need to use some visual artifact, but it doesn't mean that our business logic needs to know unnecessary details about it. Even better, it should be possible to write the business logic without having a concrete implementation of the artifact (form, message dialog, whatever it is).

 

It will be better to explain this principle with a simple example.

 

 

unit _MyForm;
 
interface
 
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;
 
type
  TMyForm = class(TForm)
    edtSomeText: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    lblSomeText: TLabel;
  private
    function GetSomeText: string;
    procedure SetSomeText(const Value: string);
  public
 
    property SomeText : string read GetSomeText write SetSomeText;
  end;
 
  function GetOrModifySomeText(var aText : string) : boolean;
 
implementation
 
{$R *.dfm}
 
function GetOrModifySomeText(var aText : string) : boolean;
var
  MyForm: TMyForm;
begin
  MyForm := TMyForm.Create(Application);
  try
    MyForm.SomeText := aText;
 
    Result := MyForm.ShowModal = mrOk;
 
    if Result then
      aText := MyForm.SomeText;
  finally
    MyForm.Free;
  end;
end;
 
{ TMyForm }
 
function TMyForm.GetSomeText: string;
begin
  Result := edtSomeText.Text;
end;
 
procedure TMyForm.SetSomeText(const Value: string);
begin
  edtSomeText.Text := Value;
end;
 
end.

 

The business logic only needs access to a function GetOrModifySomeText which will return true if the text passed as parameter was modified. It doesn't need to know how that is done. If the only way of using the function is to make an explicit reference to the unit implementing the business logic, we will be adding a dependency to a VCL form and, even worse, to a particular implementation of it.

 

The same form, this time implemented as a uniGUI free form, requires a similar code.

 

unit _MyForm;
 
interface
 
uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  uniGUIBaseClasses,
  uniGUIClasses,
  uniLabel,
  uniGUITypes,
  uniGUIAbstractClasses,
  uniGUIForm,
  uniGUIApplication,
  uniEdit,
  uniButton;
 
type
  TMyForm = class(TUniForm)
    edtSomeText: TUniEdit;
    btnOk: TUniButton;
    btnCancel: TUniButton;
    lblSomeText: TUniLabel;
  private
    function GetSomeText: string;
    procedure SetSomeText(const Value: string);
  public
 
    property SomeText : string read GetSomeText write SetSomeText;
  end;
 
  function GetOrModifySomeText(var aText : string) : boolean;
 
implementation
 
{$R *.dfm}
 
function GetOrModifySomeText(var aText : string) : boolean;
var
  MyForm: TMyForm;
begin
  MyForm := TMyForm.Create(UniGUIApplication.UniApplication);
  MyForm.SomeText := aText;
 
  Result := (MyForm.ShowModal = mrOk);  // Synchronized mode
 
  if Result then
    aText := MyForm.SomeText;
end;
 
{ TMyForm }
 
function TMyForm.GetSomeText: string;
begin
  Result := edtSomeText.Text;
end;
 
procedure TMyForm.SetSomeText(const Value: string);
begin
  edtSomeText.Text := Value;
end;
 
end.

 

The only difference here is that we don't need to explicitly release the uniGUI form.

 

Now, what about being able to write the business logic without having a concrete implementation of the form, or even better, how to target both VCL and uniGUI with the same code?

 

Let's do some refactoring.

 

Extract an interface exposing the form behavior

 

type
 
  IMyForm = interface
    ['{80CDB092-DDA0-49A0-9FFF-F8D69E18777C}']
 
    function GetSomeText: string;
    procedure SetSomeText(const Value: string);
    function _ShowModal : integer;
 
    property SomeText : string read GetSomeText write SetSomeText;
  end;

 

Modify both forms to implement the interface
 

unit _MyForm;
 
interface
 
uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  uniGUIBaseClasses,
  uniGUIClasses,
  uniLabel,
  uniGUITypes,
  uniGUIAbstractClasses,
  uniGUIForm,
  uniGUIApplication,
  uniEdit,
  uniButton,
  _MyFormIntf;
 
type
 
  TMyForm = class(TUniForm, IMyForm)
    edtSomeText: TUniEdit;
    btnOk: TUniButton;
    btnCancel: TUniButton;
    lblSomeText: TUniLabel;
  private
    function GetSomeText: string;
    procedure SetSomeText(const Value: string);
    function _ShowModal : integer;
  public
 
  end;
 
implementation
 
{$R *.dfm}
 
{ TMyForm }
 
function TMyForm.GetSomeText: string;
begin
  Result := edtSomeText.Text;
end;
 
procedure TMyForm.SetSomeText(const Value: string);
begin
  edtSomeText.Text := Value;
end;
 
function TMyForm._ShowModal : integer;

begin

  Result := ShowModal;

end;

 
end.

 

Don't reference the forms, but the interface
 

function GetOrModifySomeText(MyForm: IMyForm; var aText : string) : boolean;
begin
  MyForm.SomeText := aText;
 
  Result := MyForm._ShowModal = mrOk;
 
  if Result then
    aText := MyForm.SomeText;
end;

 

Once the form was created, it can be passed around as the interface it implements. Notice that we added _ShowModal to the interface because ShowModal is different for VCL and uniGUI.

 

Don't access forms, except for creating and releasing instances

 

A Delphi form is a "view" or one of the possible implementations of the presentation layer. It should always implement one or several interfaces to clarify its purpose. Any access to the form should be done by using one of the interfaces it implements, hiding any implementation detail and avoiding future errors when modifying internal resources.

 

Accessing forms through interfaces avoids breaking the code using the form when the form changes. It also opens the possibility of creating different forms/views implementing the same interface. For example:

•The application could share most of the business logic while targeting the Delphi VCL desktop and Delphi uniGUI (also desktop-like).

•A web application built with uniGUI could provide two different user interfaces, one for desktop users (having mouse and keyboard), other for touch devices (phones and tablets).

 

Never introduce business logic code in forms, take advantage of Delphi features

 

Every line of code expressing business logic and embedded in a form creates an unnecessary dependency and impedes creating new views. A typical web application provides access to a database server through a business logic layer. The equivalent Delphi objects are forms, data modules, optional business classes, and the database connections.

 

Let's analyze how those Delphi objects relate to the components of the MVC pattern.

 

Model View Controller

 

A Delphi implementation of MVC is something like this:

•The View is a TForm, TUniForm, TUnimForm.

oIt is created at design-time and rendered at run-time.

oSome properties could be updated through its interface (still a good behavior)

oMost of the updates will be automatically propagated through the database components (connected during creating)

oAny user action could trigger database-related updates (perfect), while others could trigger actions (also good). Other acceptable good behavior could be to execute required/expected actions like creating its own data module and releasing it.

•The Controller usually is the data module used by the form, and most of the time it contains part of all the Model (at least, the database components).

oIn a small application, Controller and Model will be implemented in the MainModule.

oBigger applications could use a data module for some forms, in addition to the MainModule.

 

The Model-View-Presenter pattern suggests something similar.

 

Model View Presenter

 

In this pattern, the Presenter is the mechanism implemented in VCL or uniGUI for handling the "communication" between the Model (data module and business classes) and the View (form). It is worth mentioning that this View is passive (or as passive as possible), which means that it won't include any business logic.

 

In the next section we will show how to build an application targeting both uniGUI platforms (desktop and touch), but it is important to list the Delphi features that application will use.

 

Database controls and its events

 

As the goal is to keep the business logic code out of the View, we will never use data access components in a form. Instead, all these components will be hosted by data modules. In a VCL application, that data module will be automatically created and assigned to the global variable. In uniGUI the approach is different, as the MainModule will be accessible through the function uniMainModule. In both cases, any form can link its data access controls at design-time (to the corresponding data sources and datasets).

 

Following the principle of consuming resources when needed, always on-demand, each form requiring database access should announce/request the data module to activate/deactive its resources (that is, open and close datasets). These actions should be done in OnCreate and OnDestroy.

 

In bigger applications, it could be necessary to create and destroy any additional data module used by the form.

 

In any case, by hosting the data access controls in the data module, any event will be implemented in the same place (or it could ask some business class defined out of the data module).

 

By following these practices, no business logic is added to the View. As we will mention later in this chapter, it is even possible to inject these minimal dependencies.

 

Requesting actions from the View without writing code (platform-independent)

 

What about using a menu (MainMenu or PopupMenu), pressing a button for requesting a global action or an action focused on some selected dataset record?

 

In a data-centric application, most of the requested actions affect the active records or some selection of records. Other actions are global and could be requested in several places in the user interface.

 

Delphi supports actions and action lists for a long time. Each button in a toolbar can be linked to an action. Menu items from any menu can also be linked to actions. Other buttons share that capability. It the action list is hosted by the same data module, every time the user triggers an action, the action's Execute method will be able to query the context (for example, the selected record of a dataset) and implement the requested business logic.

 

Of course, some actions could require interacting with the user through the same user interface it came from. While using interfaces allows the developer to access a View without knowing how it is implemented or the platform it is targeting, in this case we will need to instantiate the View for the current platform.

 

Let's see two possible solutions to the previous question.

 

Create an interface as a facade to platform-dependent services

 

When the VCL application or uniGUI session starts, whatever is the current platform can be saved and used later for instantiating the correct Views. Of course, the VCL application will always be VCL, but a uniGUI application could be targeting two platforms: desktop and touch. If the user session started from a touch device, any further interaction would rely on touch forms and messages.

 

The easiest solution for small projects is to define an interface for all the "services" (forms and messaging) required by the business logic, implement them for both targets, and instantiate the correct one according to the user session. After that, every time a form is needed, the concrete implementation, available through the interface, will be used.

 

Use Dependency Injection for registering multiple implementations of the same form interface

 

Big projects can have hundreds or even thousands of forms, making the previous solution tedious, time-consuming, and error-prone. The correct solution is to leave that task to a Dependency Injection framework like Spring4D.

 

It is out of the scope of this documentation, but we will show how to modify our demo to do it.

 

---

## 82. Small hybrid application

### Developer's Guide > Best Practices > Small hybrid application

来源: https://www.unigui.com/doc/online_help/small-hybrid-application.htm

#### 章节标题

  - Small hybrid application
  - Small hybrid application

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices >
   
      Small hybrid application |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Small hybrid application
	  

After installing uniGUI Professional, more than 100 demo projects show off different features of uniGUI for creating web applications running on a desktop browser. With uniGUI Complete, a new target platform is available, touch-enabled devices.

 

Almost any application can provide a subset of its features for touch-enabled devices (typically, smartphones and tablets), while the standard web interface is full-featured. For example, a corporate application requires many forms for handling all their subsystems, but the executives could be interested in a much simpler dashboard accessible from any device (PC, notebook, smartphone, tablet).

 

In other words, hybrid applications are standard, and this section will show a pattern about how to create them following the previously mentioned best practices.

 

 

---

## 83. Features and limitations

### Developer's Guide > Best Practices > Small hybrid application > Features and limitations

来源: https://www.unigui.com/doc/online_help/features-and-limitations.htm

#### 章节标题

  - Features and limitations
  - Features and limitations
    - What is the application about
    - It is a database-based application
    - The data access technology is FireDAC
    - How to access the application
    - Access control
    - Main Form
    - Edit Users Form
    - Edit Orders Form
    - Report Sales

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application >
   
      Features and limitations |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Features and limitations
	  

This demo application illustrates several best practices, but it is simple enough to read and test. As such, some features involve limitations.

 

What is the application about

 

It is a very limited Point-of-Sale application.

 

•Users are the operators.

•Users with administrative rights can create other users.

•All users can enter orders.

•Orders identify the customer.

•Orders know when they were created and when the customer paid for them.

•Each order can have several items.

•Items refer to some product quantity.

•Products have a price.

•A Sales Report will export and show a PDF file with all the registered orders.

 

There are several obvious limitations:

 

•The same user can login from several devices

•Orders are not recording the user

•Paid orders are not read/only

•The report does not provide any filtering

 

As will be clear after looking at the code, it will be easy to overcome most of the previous limitations.

 

It is a database-based application

 

Even small web applications use some persistence. The most common persistence is a relational database, shared by multiple sessions. It is important to select an appropriate database, capable of delivering the expected performance (response time, concurrency) according to how many concurrent sessions the application will accept.

 

•The demo application uses SQLite, a database better suited for briefcase use.

•The only reason for using SQLite is that FireDAC supports it natively, without needing any external driver.

•Instead of SQLite, Microsoft SQL Server Express (or LocalDB) could be a better option.

 

If the application should be able to support or use a different database engine in the future, instead of "hardwiring" the current choice, it could be better to use an ORM (Object Relational Mapping) tool. For example, the following design was reverse-engineered from the SQLite database by Devart Entity Developer.

 

Sales database

 

The data access technology is FireDAC

 

As FireDAC is the Delphi preferred data access technology and it provides native support for SQLite, this demo uses FireDAC data access controls.

 

 

How to access the application

 

•As any web application, you will need a modern browser.

•A standard best practice is to use a login form to handle the user rights.

•If using a login form, it is a best practice to use SSL (https://), but this demo does not use SSL (just http://)

•There are two entry points to the application:

ohttp://<host>:8077 for the full desktop-like experience

ohttp://<host>:8077/m for the mobile/touch-enabled experience

 

Access control

 

The application login form uses the minimum standard for authenticating users: username and password.

 

•As usual, the password is masked with asterisks.

•Passwords should not go to the database. Best practices suggest to store a hash instead.

•This application stores the unencrypted password in the database (it is not important to show how to build the uniGUI application).

•Once the login is successful, the application will know if the current user is an administrator (administrators can manage the user list).

 

It is out of the scope of this document, but RBAC (Role-Based Access Control) describes how to manage privileges and roles (that is, each user could act in several roles, each of them giving specific permissions).

 

Desktop Login Form

 

Touch Login Form

 

Main Form

 

The main application form is usually the "launch pad" for the application. It is the place from which the user executes the application modules.

 

•A small application like this demo will have a few modules. It uses a tile-style UI (standard menu plus toolbar or just a few big buttons).

•Medium or large applications with many modules should use a different paradigm. One good start could be to use a navigation tree on a left panel, and a page control for hosting modules to the right.

 

Desktop Main Form

 

Touch Main Form

 

Edit Users Form

 

Users of the application will operate the application. Administrators can create and edit other users, while other users can only access orders and reports. In addition to the limitations already mentioned, there is other limitation which is a pending improvement. The button on the toolbar allows to toggle the "admin" status of the selected user. In the visible snapshot, pressing the button will pop up a message "You need at least one admin account!", but if the same change happens using the checkbox, it will be accepted. The same validation should happen in the OnBeforePost event of the table Users.

 

Storing and showing the passwords is also wrong. In a future implementation of this demo we will apply some best practices about application security.

 

Desktop Users Editor Form

 

Touch Users Editor Form

 

Edit Orders Form

 

This simple Point-of-Sale application will record orders with their items, and it will identify the customer. The database already contain some data, but to be able to manage all required information, it is possible to edit customers and products. Each new order records the time it started (Created). When the order is finished and paid, the user press the button (Mask as Paid) and the time is recorded (Paid).

 

Notice that a paid order should become read/only, but it is not enforced in this implementation.

 

Desktop Orders Editor Form

 

Touch Orders Editor Form

 

Report Sales

 

This is a demo about how to use Fast Reports in a web application. It shows how to modify Fast Report settings to avoid unnecessary visual pop ups, execute it in thread-safe mode, and consume resources on demand.

 

Desktop Sales Report

 

Touch Sales Report

 

---

## 84. Programming the hybrid application

### Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application

来源: https://www.unigui.com/doc/online_help/programming-the-hybrid-applica.htm

#### 章节标题

  - Programming the hybrid application
  - Programming the hybrid application

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application >
   
      Programming the hybrid application |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Programming the hybrid application
	  

As this demo application is already included in "Demos\Touch\Small Hybrid App", this section will only cover the most relevant programming details for each unit or form.

 

---

## 85. Server Module

### Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application > Server Module

来源: https://www.unigui.com/doc/online_help/small-server-module.htm

#### 章节标题

  - Server Module
  - Server Module

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application >
   
      Server Module |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Server Module
	  

It contains a component TFDManager which becomes active during the server module creation. This is the correct place to read the global connection string giving access to the shared database server and assign it to the a read/only property.

 

Server Module

 

Limitations of this code:

 

•The connection string is hard-coded and it should come from some external source (like a INI or XML file)

•In addition to file system security or any other access control over the external source, no critical information should be in the open. Use encryption for stronger protection.

 

unit ServerModule;
 
interface
 
uses
  Classes, SysUtils, uniGUIServer, uniGUIMainModule, uniGUIApplication,

  uIdCustomHTTPServer, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,

  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Phys,

  FireDAC.Comp.Client;
 
type
  TUniServerModule = class(TUniGUIServerModule)
    FDManager1: TFDManager;
 
    procedure UniGUIServerModuleCreate(Sender: TObject);
  private
    FConnString : string;
 
  protected
 
    procedure FirstInit; override;
  public
 
    property ConnString : string read FConnString;
  end;
 
function UniServerModule: TUniServerModule;
 
implementation
 
{$R *.dfm}
 
uses
  UniGUIVars;
 
function UniServerModule: TUniServerModule;
begin
  Result:=TUniServerModule(UniGUIServerInstance);
end;
 
procedure TUniServerModule.FirstInit;
begin
  InitServerModule(Self);
end;
 
procedure TUniServerModule.UniGUIServerModuleCreate(Sender: TObject);
begin
  FDManager1.Active := True;
 
  FConnString := 

    'DriverID=SQLite;Database=' +

    FilesFolderPath +

    'SQLite_Sales.db';
end;
 
initialization
  RegisterServerModuleClass(TUniServerModule);
end.

 

---

## 86. Main Module

### Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application > Main Module

来源: https://www.unigui.com/doc/online_help/small-main-module.htm

#### 章节标题

  - Main Module
  - Main Module
      - Create/Destroy
      - Login process
      - Platform selection
        - Desktop
        - Touch
      - Implementing the launching pad with actions
      - Moving the business logic from the user interface to the data module
        - Resource handling
        - Data-related event handling
        - Executing actions

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application >
   
      Main Module |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Main Module
	  

The main data module contains several objects associated with a session:

 

1.The connection to the database (TFDConnection)

2.Tables or queries to access the database (TFDTable, TFDQuery)

3.Data sources for accessing the database objects from data-bound controls.

4.A list of actions (TActionList).

5.A list of images (TUniNativeImageList) with an adapter (TUniImageListAdapter) for using the images from the action list.

 

Using the previous components and its internal code, the MainModule encapsulates most of the business logic of this simple application.

 

Create/Destroy

 

Each session has its own database connection. The connection string is already available from the server module.

 

procedure TUniMainModule.UniGUIMainModuleCreate(Sender: TObject);
begin
  Conn.ConnectionString := UniServerModule.ConnString;
  Conn.Open;
end;
 
procedure TUniMainModule.UniGUIMainModuleDestroy(Sender: TObject);
begin
  Conn.Close;
end;

 

Login process

 

Depending on how the user access the application, the application will instantiate the desktop or touch login form. After entering the username and password, pressing OK will trigger the login validation process.

 

{ Login validation and session platform selection }
 
function TUniMainModule.Login

(

  aUsername,

  aPassword: string;

  aDesktop : boolean

): boolean;
var
  UserFound : boolean;
  IsAdmin   : Variant;
begin
  Result := false;
 
  IsAdmin :=
    Conn.ExecSQLScalar
    (
      Format
      (
        'SELECT Admin FROM Users WHERE Username = ''%s'' AND Password = ''%s''',
        [aUserName, aPassword]
      )
    );
 
  UserFound := not VarIsClear(IsAdmin);
  if UserFound then
  begin
    FUsername := aUsername;
    FPassword := aPassword;
 
    FIsAdmin := not VarIsNull(IsAdmin) and IsAdmin;
 
    actEditUsers.Visible := FIsAdmin;
 
    if aDesktop then
      SetAsDesktop
    else
      SetAsMobile;
 
    Result := true;
  end;
end;

 

Login encapsulates two business rules: how to identify a valid user (combination username/password), and what kind of user can see the action "Edit Users".

 

Platform selection

 

Each login form (dLoginForm and mLoginForm) reports to the MainModule the selected platform when attempting a login.

 

{ Platform selection }
 
procedure TUniMainModule.SetAsDesktop;
begin
  FServices := TdServices.Create;
end;
 
procedure TUniMainModule.SetAsMobile;
begin
  FServices := TmServices.Create;
end;

 

After selecting a platform, the session will know how to interact with the user on that platform. The solution used in this application is to group different implementations of common actions behind a facade/interface and instantiate the correct one for the selected platform.

 

The interface is IService:

 

unit Services;
 
interface
 
type
 
  IServices = interface
    ['{CB442F06-D33F-488B-B643-22887D8F499B}']
 
    procedure EditUsers;
    procedure EditOrders;
    procedure ReportSales(const aPDFUrl : string);
  end;
 
implementation
 
end.

 

There are two implementations (for desktop and touch respectively).

 

Desktop

 

unit dServices;
 
interface
 
uses
  Classes,
  Services;
 
type
 
  TdServices = class(TInterfacedObject, IServices)
 
    procedure EditUsers;
    procedure EditOrders;
    procedure ReportSales(const aPDFUrl : string);
  end;
 
implementation
 
uses
  Vcl.Controls,
  uniGUIForm,
  _dUsersForm,
  _dOrdersForm,
  _dSalesReportForm;
 
{ TdServices }
 
procedure TdServices.EditUsers;
begin
  dUsersForm.ShowModal();
end;
 
procedure TdServices.EditOrders;
begin
  dOrdersForm.ShowModal();
end;
 
procedure TdServices.ReportSales(const aPDFUrl : string);
var
  frm : TdSalesReportForm;
begin
  frm := dSalesReportForm;
  frm.PDFUrl := aPDFUrl;
  frm.ShowModal();
end;
 
end.

 

Touch

 

unit mServices;
 
interface
 
uses
  Classes,
  Services;
 
type
 
  TmServices = class(TInterfacedObject, IServices)
 
    procedure EditUsers;
    procedure EditOrders;
    procedure ReportSales(const aPDFUrl : string);
  end;
 
implementation
 
uses
  Vcl.Controls,
  uniGUImForm,
  _mUsersForm,
  _mOrdersForm,
  _mSalesReportForm;
 
{ TdServices }
 
procedure TmServices.EditUsers;
begin
  mUsersForm.ShowModal();
end;
 
procedure TmServices.EditOrders;
begin
  mOrdersForm.ShowModal();
end;
 
procedure TmServices.ReportSales(const aPDFUrl : string);
var
  frm : TmSalesReportForm;
begin
  frm := mSalesReportForm;
  frm.PDFUrl := aPDFUrl;
  frm.ShowModal();
end;
 
end.

 

It is now clear that both implementations are practically identical, because the only differences are the classes implementing each method in the interface. That is a significant limitation in this solution, as there is duplicated code which is a bad programming practice. One of the possible solutions is to use Dependency Injection for locating the correct classes for a given platform and avoid code duplication.

 

Implementing the launching pad with actions

 

One of the best practices for separating the user interface from the business logic is to use actions. The main data module has an action list with the following actions:

 

1.Edit Users (only available to administrators)

2.Edit Orders

3.Report Sales

 

No matter what kind of visual control is used by the target platform, if it supports actions, it will be able to trigger the selected actions. For example, the desktop main form expose these actions in a TUniMainMenu and in a TUniToolBar, while the touch main form expose them in large buttons.

 

The user interface is not explicitly requesting anything from the MainModule and the MainModule is not aware of the user interface in any way.

 

On the other hand, the business logic requires executing the requested actions, which is the reason for creating the interface Services.

 

{ Launching pad business logic actions }
 
procedure TUniMainModule.actEditOrdersExecute(Sender: TObject);
begin
  Services.EditOrders;
end;
 
procedure TUniMainModule.actEditUsersExecute(Sender: TObject);
begin
  Services.EditUsers;
end;
 
procedure TUniMainModule.actReportSalesExecute(Sender: TObject);
var
  PDFUrl : string;
begin
  PDFUrl := ExportSalesReportToPDF;
  if PDFUrl <> '' then
    Services.ReportSales(PDFUrl);
end;

 
function TUniMainModule.ExportSalesReportToPDF : string;
var
  dm : TfrDataModule;
begin
  dm := TfrDataModule.Create(nil);
  try
    Result := dm.ExportReport;
  finally
    dm.Free;
  end;
end;
 
procedure TUniMainModule.UniGUIMainModuleNewComponent(AComponent: TComponent);
begin
  if AComponent is TfrxReport then
    (AComponent as TfrxReport).EngineOptions.UseGlobalDataSetList := False;
end;

 

Following the best practices, only when asking for a report the corresponding data module is created and used for exporting the report to PDF format.

 

Moving the business logic from the user interface to the data module

 

Explicit requests from the user were already mapped to actions and handled in the data module. Other user requests arrive to the data module as data-related events which should be handled according to the business logic of the application. But there is an implicit business logic which needs an explicit request, opening and closing datasets used by concrete forms.

 

In this application we will not use any registration system (which could related concrete forms or interfaces to resources), but just explicit calls requesting for data module support.

 

Resource handling

 

{ Resource handling for forms }
 
procedure TUniMainModule.OnCreateOrdersEditor(Sender: TObject);
begin
  tblCustomers.Open;
  tblProducts.Open;
  tblOrders.Open;
  tblItems.Open;
end;
 
procedure TUniMainModule.OnDestroyOrdersEditor(Sender: TObject);
begin
  tblItems.Close;
  tblOrders.Close;
  tblProducts.Close;
  tblCustomers.Close;
end;
 
procedure TUniMainModule.OnCreateUsersEditor(Sender: TObject);
begin
  tblUsers.Open;
end;
 
procedure TUniMainModule.OnDestroyUsersEditor(Sender: TObject);
begin
  tblUsers.Close;
end;

 

Each form requiring data module resources will call UniMainModule.OnCreate<form>(Self) and OnDestroy<form>(Self) so that the data module set up and tear off any required resources. In the previous code the data module opens and closes the datasets required by each form.

 

This particular code is just server-side business logic, and it could be activated by using Dependency Injection. It can be done by registering resources with their respective OnCreate and OnDestroy methods.

 

In more complicated situations, it could be possible to "inject" components into the concrete form. For example, the application MainMenu could be defined in the data module, and some generic method could be able to create the correct equivalent for the Sender form based on its type.

 

The goal of this kind of programming is achieving greater disconnection between the user interface and the business logic. The results will come later when looking at the implementation of each form.

 

Data-related event handling

 

Most of the business logic belongs to this category. It is typical to validate changes in OnBeforePost, refresh information or trigger other actions in OnAfterPost, calculate virtual fields in OnCalcFields, etc.

 

{ Data access event handlers }
 
procedure TUniMainModule.tblItemsAfterPost(DataSet: TDataSet);
begin
  // After posting a change in items, force a recalculation of the order
 
  tblOrders.Edit;
  tblOrdersCalcFields(tblOrders);
  tblOrders.Post;
end;
 
procedure TUniMainModule.tblItemsCalcFields(DataSet: TDataSet);
begin
  if Conn.Connected and not tblItemsQuantity.IsNull and not tblItemsPrice.IsNull then
    tblItemsTotal.Value := tblItemsQuantity.Value * tblItemsPrice.Value;
end;
 
procedure TUniMainModule.tblOrdersCalcFields(DataSet: TDataSet);
var
  t : Variant;
begin
  t :=
    Conn.ExecSQLScalar
    (
      Format
      (
        'SELECT' +
        '  sum(i.Quantity * p.Price) ' +
        'FROM' +
        '  Orders o' +
        '    INNER JOIN Items    i ON o.ID = i.OrderID' +
        '    INNER JOIN Products p ON i.ProductID = p.ID ' +
        'WHERE o.ID = %d',
        [tblOrdersID.Value]
      )
    );
 
 
  if VarIsNull(t) then
    t := 0;
 
  tblOrdersTotal.Value := t;
end;

 

Executing actions

 

Some actions are not standard for a data-related control and they are exposed on buttons, menu items, etc.

 

{ Business logic actions }
 
procedure TUniMainModule.actMarkAsPaidExecute(Sender: TObject);
begin
  if tblOrders.State = dsBrowse then
    tblOrders.Edit;
 
  tblOrdersPaid.Value := Now;
  tblOrders.Post;
end;
 
procedure TUniMainModule.actToggleAdminExecute(Sender: TObject);
var
  AdminQty : integer;
begin
  if tblUsers.State <> dsBrowse then
    ShowMessage('Commit any pending udpate before requesting admin status changes!')
  else
  begin
    AdminQty := Conn.ExecSQLScalar('SELECT count(*) FROM Users WHERE Admin = 1');
    if tblUsersAdmin.Value and (AdminQty = 1) then
      ShowMessage('You need at least one admin account!')
    else
    begin
      tblUsers.Edit;
      tblUsersAdmin.Value := tblUsersAdmin.IsNull or not tblUsersAdmin.Value;
      tblUsers.Post;
    end;
  end;
end;

 

The last action raises a concern. If the business logic mandates that at least one user must be admin, why this validation only happens when the user press the button "Toggle Admin Status"? What will happen if the same action happens by clicking the Admin checkbox in the user interface?

 

There are two options for solving the previous issue: making the column Admin read/only, or executing this validation in both places (here and in tblUsers.OnBeforePost).

 

---

## 87. Login Form

### Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application > Login Form

来源: https://www.unigui.com/doc/online_help/small-login-form.htm

#### 章节标题

  - Login Form
  - Login Form
      - Desktop Login Form
      - Touch Login Form

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application >
   
      Login Form |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Login Form
	  

The code for the login form is almost identical for the target platforms, but the user interface is totally different. As expected, the data module is unaware of the differences.

 

Desktop Login Form

 

 

unit _dLoginForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniFieldSet,
  uniEdit, uniPanel, uniButton;
 
type
  TdLoginForm = class(TUniLoginForm)
    UniFieldSet1: TUniFieldSet;
    edtUsername: TUniEdit;
    edtPassword: TUniEdit;
    UniFieldContainer1: TUniFieldContainer;
    btnOk: TUniButton;
    btnCancel: TUniButton;
    UniContainerPanel1: TUniContainerPanel;
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function dLoginForm: TdLoginForm;
 
implementation
 
{$R *.dfm}
 
uses
  uniGUIVars, MainModule, uniGUIApplication;
 
function dLoginForm: TdLoginForm;
begin
  Result := TdLoginForm(UniMainModule.GetFormInstance(TdLoginForm));
end;
 
procedure TdLoginForm.btnOkClick(Sender: TObject);
begin
  if uniMainModule.Login(edtUsername.Text, edtPassword.Text, true) then
    ModalResult := mrOk
  else
    ShowMessage('Invalid credentials!');
end;
 
initialization
  RegisterAppFormClass(TdLoginForm);
 
end.

 

This form uses FieldSets to achieve a consistent visual design.

 

 

UniFieldContainer1 which contains the buttons OK and Cancel uses client-side alignment table with two columns.

UniFieldSet1 will render the fields username and password using client-side alignment form.

 

Touch Login Form

 

 

unit _mLoginForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUImClasses, uniGUIRegClasses, uniGUIForm, uniGUImForm,

  uniGUImJSForm, uniGUIBaseClasses, unimFieldSet, uniEdit, unimEdit,

  uniButton, unimButton;

 
type
  TmLoginForm = class(TUnimLoginForm)
    UnimFieldSet1: TUnimFieldSet;
    UnimContainerPanel1: TUnimContainerPanel;
    edtUsername: TUnimEdit;
    edtPassword: TUnimEdit;
    btnOK: TUnimButton;
    btnCancel: TUnimButton;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function mLoginForm: TmLoginForm;
 
implementation
 
{$R *.dfm}
 
uses
  uniGUIVars, MainModule, uniGUIApplication;
 
function mLoginForm: TmLoginForm;
begin
  Result := TmLoginForm(UniMainModule.GetFormInstance(TmLoginForm));
end;
 
procedure TmLoginForm.btnOKClick(Sender: TObject);
begin
  if uniMainModule.Login(edtUsername.Text, edtPassword.Text, false) then
    ModalResult := mrOk
  else
    ShowMessage('Invalid credentials!');
end;
 
initialization
  RegisterAppFormClass(TmLoginForm);
 
end.

 

It is obvious that both forms are practically identical. The components are also similar, but each one of them targeting a different platform (for example, TUnimContainerPanel instead of TUniContainerPanel).

 

 

---

## 88. Main Form (launching pad)

### Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application > Main Form (launching pad)

来源: https://www.unigui.com/doc/online_help/main-form-(launching-pad).htm

#### 章节标题

  - Main Form (launching pad)
  - Main Form (launching pad)
      - Desktop Main Form
      - Touch Main Form

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application >
   
      Main Form (launching pad) |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Main Form (launching pad)
	  

As expected, the visual design of a traditional "desktop" form exposing the main services of an application is different to the latest touch-enabled user interfaces. The first design assumes the use of a high precision device, a mouse, instead of a fat finger which is the usual "device" for the second. It is also common in old-school user interfaces to access services through the "main menu".

 

Both user interfaces will give access to the same services, and a good implementation should keep the differences in the user interface code, sharing the same business logic.

 

Desktop Main Form

 

 

unit Main;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniLabel,
  uniButton, uniToolBar, uniBitBtn, Vcl.Menus, uniMainMenu;
 
type
  TMainForm = class(TUniForm)
    UniToolBar1: TUniToolBar;
    btnEditUsers: TUniToolButton;
    btnEditOrders: TUniToolButton;
    btnReportSales: TUniToolButton;
    UniMainMenu1: TUniMainMenu;
    Main1: TUniMenuItem;
    Exit1: TUniMenuItem;
    Administration1: TUniMenuItem;
    EditUsers1: TUniMenuItem;
    Operations1: TUniMenuItem;
    EditOrders1: TUniMenuItem;
    Reports1: TUniMenuItem;
    ReportSales1: TUniMenuItem;
    Logoff1: TUniMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure Logoff1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function MainForm: TMainForm;
 
implementation
 
{$R *.dfm}
 
uses
  uniGUIVars, MainModule, uniGUIApplication;
 
function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;
 
procedure TMainForm.Exit1Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;
 
procedure TMainForm.Logoff1Click(Sender: TObject);
begin
  ModalResult := mrOk;
end;
 
initialization
  RegisterAppFormClass(TMainForm);
 
end.

 

There are just two lines of code in this form which are redundant, showing the difference between login off and closing the session. Except for these two optional lines of code, the only link between this form and the MainModule is the link between menu items and toolbar buttons to actions.

 

The visual design is exposed in its structure:

 

 

Touch Main Form

 

 

unit Mainm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUImForm, uniGUIBaseClasses,
  uniLabel, unimLabel, uniButton, unimButton, uniToolBar, unimToolbar,
  uniBitBtn, unimBitBtn, uniGUImJSForm, unimPanel, unimMenu;
 
type
  TMainmForm = class(TUnimForm)
    btnEditUsers: TUnimBitBtn;
    btnEditOrders: TUnimBitBtn;
    UnimContainerPanel1: TUnimContainerPanel;
    btnReportSales: TUnimBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function MainmForm: TMainmForm;
 
implementation
 
{$R *.dfm}
 
uses
  uniGUIVars, MainModule, uniGUIApplication;
 
function MainmForm: TMainmForm;
begin
  Result := TMainmForm(UniMainModule.GetFormInstance(TMainmForm));
end;
 
initialization
  RegisterAppFormClass(TMainmForm);
 
end.

 

The only difference between this code and the previous code is the absence of the main menu.

The structure is also similar.

 

 

---

## 89. Users Editor Form

### Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application > Users Editor Form

来源: https://www.unigui.com/doc/online_help/users-editor-form.htm

#### 章节标题

  - Users Editor Form
  - Users Editor Form
      - Desktop Users Editor Form
      - Touch Users Editor Form

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application >
   
      Users Editor Form |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Users Editor Form
	  

This form uses a grid and navigator to add, delete, and edit users/operators of the Point-of-Sale. There is a button in the toolbar for changing the Admin status. Its implementation in both platforms will be identical, except for the visual controls.

 

Desktop Users Editor Form

 

 

unit _dUsersForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniBasicGrid, uniDBGrid, uniDBNavigator,
  uniGUIBaseClasses, uniPanel, uniToolBar;
 
type
  TdUsersForm = class(TUniForm)
    dbnCustomers: TUniDBNavigator;
    dbgCustomers: TUniDBGrid;
    barTop: TUniToolBar;
    btnToggleAdmin: TUniToolButton;
    cntUsers: TUniToolButton;
    procedure UniFormCreate(Sender: TObject);
    procedure UniFormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function dUsersForm: TdUsersForm;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function dUsersForm: TdUsersForm;
begin
  Result := TdUsersForm(UniMainModule.GetFormInstance(TdUsersForm));
end;
 
procedure TdUsersForm.UniFormCreate(Sender: TObject);
begin
  uniMainModule.OnCreateUsersEditor(Sender);
end;
 
procedure TdUsersForm.UniFormDestroy(Sender: TObject);
begin
  uniMainModule.OnDestroyUsersEditor(Sender);
end;
 
end.

 

It was mentioned before as a best practice. This form asks the MainModule to set up its environment at the beginning (OnCreate), and do the same in OnDestroy for tearing off them. Whatever has to be done is not the responsibility of the presentation layer.

 

Its visual design is:

 

 

Touch Users Editor Form

 

 

unit _mUsersForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUImClasses, uniGUIForm, uniGUImForm, uniGUImJSForm,
  uniBasicGrid, uniDBGrid, unimDBListGrid, unimDBGrid, uniGUIBaseClasses,
  uniDBNavigator, unimDBNavigator, uniToolBar, unimToolbar;
 
type
  TmUsersForm = class(TUnimForm)
    dbgUsers: TUnimDBGrid;
    barUsers: TUnimToolBar;
    btnToggleAdmin: TUnimToolButton;
    UnimContainerPanel1: TUnimContainerPanel;
    UnimToolButton1: TUnimToolButton;
    dbnUsers: TUnimDBNavigator;
    procedure UnimFormCreate(Sender: TObject);
    procedure UnimFormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function mUsersForm: TmUsersForm;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function mUsersForm: TmUsersForm;
begin
  Result := TmUsersForm(UniMainModule.GetFormInstance(TmUsersForm));
end;
 
procedure TmUsersForm.UnimFormCreate(Sender: TObject);
begin
  uniMainModule.OnCreateUsersEditor(Sender);
end;
 
procedure TmUsersForm.UnimFormDestroy(Sender: TObject);
begin
  UniMainModule.OnDestroyUsersEditor(Sender);
end;
 
end.

 

It is the same code (changing TUni<> controls by TUnim<> controls). It is also the same structure.

 

 

---

## 90. Orders Editor Form

### Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application > Orders Editor Form

来源: https://www.unigui.com/doc/online_help/orders-editor-form.htm

#### 章节标题

  - Orders Editor Form
  - Orders Editor Form
      - Desktop Orders Editor Form
      - Touch Orders Editor Form

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application >
   
      Orders Editor Form |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Orders Editor Form
	  

The name is correct, but the meaning covers more functionality. It is not possible to edit an order without being able to manage customers and products. The editor uses grids for managing customers and products, and a master/detail pair of grids for editing orders with its items.

 

Desktop Orders Editor Form

 

 

unit _dOrdersForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniPageControl, uniPanel,
  uniBasicGrid, uniDBGrid, uniDBNavigator, uniSplitter, uniToolBar;
 
type
  TdOrdersForm = class(TUniForm)
    pc: TUniPageControl;
    tsOrdersItems: TUniTabSheet;
    pnlItems: TUniPanel;
    dbnItems: TUniDBNavigator;
    dbgItems: TUniDBGrid;
    pnlOrders: TUniPanel;
    dbgOrders: TUniDBGrid;
    tsCustomers: TUniTabSheet;
    dbnCustomers: TUniDBNavigator;
    dbgCustomers: TUniDBGrid;
    barCustomers: TUniToolBar;
    barOrders: TUniToolBar;
    btnPaid: TUniToolButton;
    barItems: TUniToolBar;
    tsProducts: TUniTabSheet;
    barProducts: TUniToolBar;
    dbnProducts: TUniDBNavigator;
    dbgProducts: TUniDBGrid;
    cntOrders: TUniToolButton;
    dbnOrders: TUniDBNavigator;
    cntItems: TUniToolButton;
    btnItems: TUniToolButton;
    btnCustomers: TUniToolButton;
    cntCustomers: TUniToolButton;
    btnProducts: TUniToolButton;
    cntProducts: TUniToolButton;
    procedure UniFormCreate(Sender: TObject);
    procedure UniFormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function dOrdersForm: TdOrdersForm;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function dOrdersForm: TdOrdersForm;
begin
  Result := TdOrdersForm(UniMainModule.GetFormInstance(TdOrdersForm));
end;
 
procedure TdOrdersForm.UniFormCreate(Sender: TObject);
begin
  uniMainModule.OnCreateOrdersEditor(Sender);
end;
 
procedure TdOrdersForm.UniFormDestroy(Sender: TObject);
begin
  uniMainModule.OnDestroyOrdersEditor(Sender);
end;
 
end.

 

This form is using a TUniPageControl for hosting orders/items, customers, and products, in different tab sheets. Each one of them works almost the same as in a common VCL application. Following the same pattern as the Users Editor Form, there are only two requests to the MainModule, everything else is handled by event handlers and actions.

 

The whole structure of the form is:

 

 

Touch Orders Editor Form

 

 

unit _mOrdersForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUImClasses, uniGUIForm, uniGUImForm, uniGUImJSForm,
  uniGUIBaseClasses, uniDBNavigator, unimDBNavigator, uniBasicGrid, uniDBGrid,
  unimDBListGrid, unimDBGrid, uniToolBar, unimToolbar, unimCarousel,
  MainModule;
 
type
  TmOrdersForm = class(TUnimForm)
    dbgOrders: TUnimDBGrid;
    barOrders: TUnimToolBar;
    btnMarkAsPaid: TUnimToolButton;
    UnimCarousel1: TUnimCarousel;
    cpOrders: TUnimCarouselPage;
    pnlOrders: TUnimContainerPanel;
    pnlItems: TUnimContainerPanel;
    barItems: TUnimToolBar;
    dbgItems: TUnimDBGrid;
    cpCustomers: TUnimCarouselPage;
    barCustomers: TUnimToolBar;
    dbgCustomers: TUnimDBGrid;
    cpProducts: TUnimCarouselPage;
    barProducts: TUnimToolBar;
    dbgProducts: TUnimDBGrid;
    UnimToolButton1: TUnimToolButton;
    dbnOrders: TUnimDBNavigator;
    UnimToolButton2: TUnimToolButton;
    UnimToolButton3: TUnimToolButton;
    dbnItems: TUnimDBNavigator;
    UnimToolButton4: TUnimToolButton;
    UnimToolButton5: TUnimToolButton;
    dbnProducts: TUnimDBNavigator;
    UnimToolButton6: TUnimToolButton;
    UnimToolButton7: TUnimToolButton;
    dbnCustomers: TUnimDBNavigator;
    procedure UnimFormCreate(Sender: TObject);
    procedure UnimFormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
 
function mOrdersForm: TmOrdersForm;
 
implementation
 
{$R *.dfm}
 
uses
  uniGUIApplication;
 
function mOrdersForm: TmOrdersForm;
begin
  Result := TmOrdersForm(UniMainModule.GetFormInstance(TmOrdersForm));
end;
 
procedure TmOrdersForm.UnimFormCreate(Sender: TObject);
begin
  uniMainModule.OnCreateOrdersEditor(Sender);
end;
 
procedure TmOrdersForm.UnimFormDestroy(Sender: TObject);
begin
  uniMainModule.OnDestroyOrdersEditor(Sender);
end;
 
end.

 

As before, the code is similar, but the components are different. In this case, the TUniPageControl was replaced by a TUnimCarousel. As similar as the grids look, fat-finger oriented functionality requires big changes to the user interaction. After a double-click to an order row, the following automatic form pop ups:

 

 

Notice that there is a mask covering the grid in the background (telling the user that there is no access to them until closing the pop up editor).

 

Instead of showing a standard lookup combobox for selecting the customer, clicking that field will surface the typical picket at the bottom of the screen:

 

 

The whole structure is:

 

 

Of course, this is just a demo, because selecting a customer among hundreds will become a problem using this method.

 

---

## 91. Sales Report Form

### Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application > Sales Report Form

来源: https://www.unigui.com/doc/online_help/sales-report-form.htm

#### 章节标题

  - Sales Report Form
  - Sales Report Form
      - Desktop Sales Report Form
      - Touch Sales Report Form

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Best Practices > Small hybrid application > Programming the hybrid application >
   
      Sales Report Form |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Sales Report Form
	  

The MainModule already includes most of the functionality required for producing reports. In fact, using the data module reportDM, it creates a PDF report on the server. The Sales Report Form only shows the PDF report according to the target platform.

 

Desktop Sales Report Form

 

 

unit _dSalesReportForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUIForm, uniGUIBaseClasses, uniURLFrame;
 
type
  TdSalesReportForm = class(TUniForm)
    UniPDFFrame1: TUniPDFFrame;
  private
    procedure SetPDFUrl(const Value : string);
  public
 
    property PDFUrl : string write SetPDFUrl;
  end;
 
function dSalesReportForm: TdSalesReportForm;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function dSalesReportForm: TdSalesReportForm;
begin
  Result := TdSalesReportForm(UniMainModule.GetFormInstance(TdSalesReportForm));
end;
 
{ TdSalesReportForm }
 
procedure TdSalesReportForm.SetPDFUrl(const Value : string);
begin
  UniPDFFrame1.PdfURL := Value;
end;
 
end.

 

A full PDF Viewer (which can also download, print, and execute other actions) is already part of the uniGUI palette (available for both platforms). This form only exposes a property for receiving the filename of the PDF report before showing it.

 

Touch Sales Report Form

 

 

unit _mSalesReportForm;
 
interface
 
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses,
  uniGUIClasses, uniGUImClasses, uniGUIForm, uniGUImForm, uniGUImJSForm,
  uniGUIBaseClasses, uniURLFrame, unimURLFrame;
 
type
  TmSalesReportForm = class(TUnimForm)
    UnimPDFFrame1: TUnimPDFFrame;
  private
    procedure SetPDFUrl(const Value : string);
  public
 
    property PDFUrl : string write SetPDFUrl;
  end;
 
function mSalesReportForm: TmSalesReportForm;
 
implementation
 
{$R *.dfm}
 
uses
  MainModule, uniGUIApplication;
 
function mSalesReportForm: TmSalesReportForm;
begin
  Result := TmSalesReportForm(UniMainModule.GetFormInstance(TmSalesReportForm));
end;
 
{ TmSalesReportForm }
 
procedure TmSalesReportForm.SetPDFUrl(const Value : string);
begin
   UnimPDFFrame1.PDFUrl := Value;
end;
 
end.

 

---

## 92. Client-side Scripting

### Developer's Guide > Client-side Scripting

来源: https://www.unigui.com/doc/online_help/client-side-scripting.htm

#### 章节标题

  - Client-side Scripting
  - Client-side Scripting

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide >
   
      Client-side Scripting |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Client-side Scripting
	  

One of the advanced features of uniGUI is the ability to write JavaScript handlers for client-side events, i.e. it allows adding JS code for Ext JS events for uniGUI controls. Ext JS is a complete JavaScript framework with a rich set of components. Ext JS has its own object hierarchy. Like Delphi objects, each Ext JS component derives from a parent object. While JavaScript is not directly an object oriented language like Object Pascal, there are several means in JavaScript to allow developers create object hierarchies with object oriented language characteristics such as inheritance. For example, in JavaScript, member visibility is not the same as in Object Pascal. So-called private properties and methods are still visible in child classes and are accessible from object instances.

 

After this short introduction to Ext JS, let's see what the requirements for client-side scripting in uniGUI are. The first requirement is a fair knowledge of the JavaScript language. JavaScript is one of the C-like language variants which has a syntax very similar to C and Java. Another prerequisite is to become familiar with Sencha Ext JS library API. You can still write client-side code with little knowledge of JavaScript and Ext JS API. Let's show a simple example:

 

Place a TUniButton on your MainForm.

 

Place a TUniButton on MainForm

 

In Object Inspector, choose the ExtEvents property which is a sub-property of the ClientEvents property. Double click on ExtEvents which will open a new window.

 

In Object Inspector double click on  ExtEvents

 

The new window is the uniGUI JavaScript event editor. On the left side, you will see all available Ext JS events that associated with TUniButton. On the top left corner, you will see Ext.button.Button which is the Ext JS component used in the TUniButton uniGUI control. If you double click on each of those events, a new event handler will open in the editor. You can start typing your custom JavaScript code to perform any desired task you want to do on the client.

 

To access UniButton1, you must use a special syntax. Any uniGUI object is accessible using the owner's name and its name (<owner name>.<object name>). The names must be the same defined in Delphi (but case sensitive). In our example, we have the object UniButton1 owned by MainForm; the correct syntax to access it client-side is MainForm.UniButton1.

 

Once you have access to your object, you can use all Ext JS methods available for the Ext.button.Button component. So, while UniButton1 is an instance of the server-side TUniButton class,  MainForm.UniButton1 is an instance of the client-side Ext.button.Button Ext JS component.

 

setText() method of Ext.button.Button class

 

The picture above shows the JavaScript setText() method for the Ext.button.Button class. This method can be called at runtime to change the caption of the button.

 

In JavaScript editor choose 'click' event and double click.

 

As demonstrated above, the setText() method can used to change the caption of button. Again, let's emphasize that JavaScript is case-sensitive and control names must be typed with the exact case they were declared in Delphi.

 

Run the application and click on the button

---

## 93. Adding Custom Ext JS Events

### Developer's Guide > Client-side Scripting > Adding Custom Ext JS Events

来源: https://www.unigui.com/doc/online_help/adding-custom-ext-js-events.htm

#### 章节标题

  - Adding Custom Ext JS Events
  - Adding Custom Ext JS Events

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Client-side Scripting >
   
      Adding Custom Ext JS Events |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Adding Custom Ext JS Events
	  

There are cases that you may need to define your own client event functions. One case is when some of the Ext JS may not be available in uniGUI Event Editor. This may happen when a newer Ext JS version is available and not all new events are imported into uniGUI JS Event Editor. You may also add your own event handlers to an Ext JS class and want to use them in uniGUI. In both cases uniGUI provides an easy method to add a custom event handler.

 

 

Example:

 

Ext JS client side event focusenter is no included in the Event Editor:

 

 

 

It can be added by following below steps:

 

 

Use Add Custom Event button to create a new event function:

 

 

Enter event name focusenter in the prompt dialog.

 

You will notice that a new event is added to the events list:

 

 

Now use you can double click on the event name to create an event function in the editor:

 

 

As you can observe a new function with a default parameter list is created. These parameters are added by default and will not reflect the exact parameter list and parameter names of the event function. You can freely edit the function to match the correct parameters.

 

 

 

function focusenter( sender, event, eOpts ) 
{
   sender.setText("Enter");   
}

 

 

You can use above code to change the button caption when it receives focus either when it is clicked or it is selected by the Tab key.

 

 

 

 

 

 

 

 

 

 

 

 

 

 

---

## 94. Deployment

### Developer's Guide > Deployment

来源: https://www.unigui.com/doc/online_help/deployment.htm

#### 章节标题

  - Deployment
  - Deployment

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide >
   
      Deployment |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Deployment
	  

Currently, there are three options available for deploying your uniGUI project to the Web .

 

Standalone Server

ISAPI Module

Windows Service

---

## 95. Sencha Ext JS License Considerations

### Developer's Guide > Deployment > Sencha Ext JS License Considerations

来源: https://www.unigui.com/doc/online_help/licesnsing_considerations.htm

#### 章节标题

  - Sencha Ext JS License Considerations
  - Sencha Ext JS License Considerations

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Deployment >
   
      Sencha Ext JS License Considerations |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Sencha Ext JS License Considerations
	  

FMSoft Co. Ltd. is an official partner of Sencha Inc. and is granted the right to distribute OEM copies of Sencha Ext JS and Sencha Touch. UniGUI distributes a partial copy of OEM Sencha Ext JS. Your uniGUI license grants you the right to use and deploy Sencha Ext JS. However, your OEM copy of Sencha Ext JS can only be used in combination with uniGUI. You shall not use or distribute OEM Sencha Ext JS for any other purpose other than using it to develop and deploy uniGUI projects. This library cannot be treated as a standalone library and cannot be used to create independent software products based on it. Sencha Ext JS/Sencha Touch is distributed as an integrated part of the uniGUI package. Sencha Ext JS/Sencha Touch is not distributed as a separate product and you are not granted a separate license for it.

 

---

## 96. uniGUI Runtime Package

### Developer's Guide > Deployment > uniGUI Runtime Package

来源: https://www.unigui.com/doc/online_help/unigui-runtime-package.htm

#### 章节标题

  - uniGUI Runtime Package
  - uniGUI Runtime Package

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Deployment >
   
      uniGUI Runtime Package |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

uniGUI Runtime Package
	  

uniGUI Runtime Package is an easy way to distribute the uniGUI runtime files to the server hosting uniGUI web applications. The Runtime Package is available as a download from FMSoft Customer Portal. This package is not available for uniGUI Trial Edition. After installing the Runtime Package, your web application will be able to find the files required by Ext JS and Sencha Touch to run your application. It also includes other JavaScript library files needed at runtime.

 

You must make sure that the installed Runtime Package matches the version of the uniGUI package you have used to compile your web application. For instance, if you have used FMSoft_uniGUI_Complete_Pro_0.99.80.1267 to build your application, you must also make sure that FMSoft_uniGUI_Complete_runtime_0.99.80.1267 is installed on your server. You can install multiple versions of the Runtime Package on your server, so that web applications compiled with different versions of uniGUI can co-exits on the same server.

 

Deploying with the Runtime Package requires all path settings with their default values. ExtRoot, TouchRoot, UniMobileRoot and UniRoot must be set at their default settings. See below:

 

 

---

## 97. uniGUI Runtime Package in tar.gz format

### Developer's Guide > Deployment > uniGUI Runtime Package > uniGUI Runtime Package in tar.gz format

来源: https://www.unigui.com/doc/online_help/unigui-runtime-package-in-tar_.htm

#### 章节标题

  - uniGUI Runtime Package in tar.gz format
  - uniGUI Runtime Package in tar.gz format

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Deployment > uniGUI Runtime Package >
   
      uniGUI Runtime Package in tar.gz format |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

uniGUI Runtime Package in tar.gz format
	  

Starting from build 1591 uniGUI deploys runtime files in portable tar.gz (or tar.xz) format. Though this file is specifically deployed for Linux platform, there is nothing that may keep you from using it for Windows platform as well. Simply extract this file into uniGUI runtime folder. This file contains all JavaScript libraries, built-in themes plus uniGUI custom themes.

 

Under Linux use below command to extract the archive:

 

tar -xf fmsoft_unigui_complete_runtime_1.95.0.1594.tar.xz

 

 

This file can be downloaded from customer portal:

 

---

## 98. Adjusting Paths

### Developer's Guide > Deployment > Adjusting Paths

来源: https://www.unigui.com/doc/online_help/adjusting_paths.htm

#### 章节标题

  - Adjusting Paths
  - Adjusting Paths

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Deployment >
   
      Adjusting Paths |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Adjusting Paths
	  

If you don't plan to deploy your app using the uniGUI Runtime Package because you want to deploy the runtime files yourself, then the path settings must be adjusted accordingly. There are some essential paths for a uniGUI application which must be adjusted before you can run it on the server.

 

First of all, you must be sure that your Web Application knows where Ext JS files are located. For this, in your Application ServerModule your must assign the correct path to ExtRoot. The default value of ExtRoot is "[ext]\" which means that Ext JS files are located where uniGUI Runtime Package is installed: <InstallFolder>\FMSoft\Framework\uniGUI\ext-x.y.z.build

 

 

 

If you do not install uniGUI Runtime Package on the target PC, you must assign a full or relative path to ExtRoot. If you assign a relative path it will be relative to ServerRoot and you can use the "..\..\..\myfolder" partial path notation.

 

The easiest method is to set the ExtRoot to ".\[ext]\" and copy the "ext-x.y.x.build" folder to the root folder of your web application (where application executable or DLL module resides).  However, for security reasons, it is better to put the "ext-x.y.x.build" folder in another folder and deploy all "ext-x.y.x.build" files as read-only. Under IIS, you must be sure that your application has enough credentials for a read-only access to the "ext-x.y.x.build" folder and its files.

 

Some examples.

 

ExtJS Files are in:

 

ExtRoot = "[ext]\"                <Runtime Package InstallFolder>\FMSoft\Framework\uniGUI/ext-x.y.z.build\  (*Recommended )

ExtRoot = ".\[ext]\"                <server root>\ext-x.y.z.build\

ExtRoot = "C:\ExtJS\[ext]\"        C:\ExtJS\ext-x.y.z.build\

ExtRoot = ".\ExtJS\[ext]\"        <server root>\ExtJS\ext-x.y.z.build\

ExtRoot = ".\ExtJS\ext\"        <server root>\ExtJS\ext\

 

In all cases, ext-x.y.x.build is translated into a string which represents the correct folder for your Ext JS version. For example, if your uniGUI version is based on Ext JS version 4.2.5.1736 then it will be translated to folder name: .\<path>\ext-4.2.5.1763\

 

The same principle applies to uniRoot, uniMobileRoot and TouchRoot properties.

 

More examples.

 

uniGUI JS Files are in:

 

UniRoot = "[uni]\"                <Runtime Package InstallFolder>\FMSoft\Framework\uniGUI/uni-x.y.z.build\  (*Recommended )

UniMobileRoot = "[unim]\"        <Runtime Package InstallFolder>\FMSoft\Framework\uniGUI/unim-x.y.z.build\  (*Recommended )

UniRoot = ".\[uni]\"                <server root>\uni-x.y.z.build\  

UniMobileRoot = ".\[unim]\"        <server root>\unim-x.y.z.build\  

 

Note: In the above cases, if "path\uni-x.y.z.build\" folder does not exist, "path\uni\" folder will be used instead.

 

The string uni-x.y.z.build correspond to the uniGUI version. If your uniGUI version is 0.99.80.1260, the translated folder name will be uni-0.99.80.1260.

 

If you deploy custom uniGUI themes to your server, you can also set a custom folder for theme files. You can use the UniPackagesRoot property for this.

The default value for UniPackagesRoot is "[unipack]\" which means that custom themes are placed in the default location used by the installer. You can change this location by assigning a different value to the UniPackagesRoot property. Make sure that the "themes" folder from the default installation is completely copied to the target folder:

 

Themes are in:

 

UniPackagesRoot = "C:\ext\[unipack]\"        "C:\ext\unipackages\themes\" folder

UniPackagesRoot = ".\themefiles\"        "<server root>\themefiles\themes\" folder

UniPackagesRoot = ".\[unipack]\"        "<server root>\unipackages\themes\" folder

 

In ServerModule there are two other path parameters: ServerRoot and CacheFolder.

 

 

ServerRoot:

 

ServerRoot defines the root path for all relative paths. A blank value points to the application startup folder.

 

CacheFolder

 

A uniGUI server needs a folder to create temporary files. Normally, it is a folder named Cache created under the same folder your module exists. You can change this default location by assigning a different path to the CacheFolder parameter. Under IIS, you must be sure that your application has enough credentials for a full access to CacheFolder.

 

If you want to change these properties at runtime, do it on the event handler OnBeforeInit of UniServerModule.

 

procedure TUniServerModule.UniGUIServerModuleBeforeInit(Sender: TObject);
begin
  ExtRoot := 'C:\deploy\[ext]\';
  UniRoot := 'C:\deploy\[uni]\';
end;

 

 

---

## 99. Standalone Server

### Developer's Guide > Deployment > Standalone Server

来源: https://www.unigui.com/doc/online_help/standalone_server.htm

#### 章节标题

  - Standalone Server
  - Standalone Server

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Deployment >
   
      Standalone Server |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Standalone Server
	  

Standalone Server mode is very similar to a VCL Application with some differences which makes it a better option for Web deployment. In this mode, your application main form is no longer visible on the desktop, instead an icon is placed in Windows taskbar.

 

uniGUI Standalone Server

 

Double-clicking on this icon will open the application control panel. Below you see an initial version of the control panel.

 

 

You can shutdown a running server by right-clicking the icon and selecting Shutdown, or you can open the server control panel and select Manage->Shutdown from the top menu.        .

 

 

 

One of the advanced features in uniGUI is that the Control Panel is accessible from the web.  You can access the control panel using this URL:

 

http://mysite:port/server

 

 

The default icon can be replaced by either changing the Delphi Application Icon or assigning a new Icon to ServerModule->Favicon.

 

Standalone Server is a good option for debugging your application or when you need a web server when server availability is not very important. To automatically start the server ,you must place a shortcut to the server executable in the Windows Startup folder. In this mode, the server will not start until a Windows user logs in. For serious deployment you must choose either ISAPI Module or Windows Service deployment options.

 

 

---

## 100. Windows Service

### Developer's Guide > Deployment > Windows Service

来源: https://www.unigui.com/doc/online_help/windows_service.htm

#### 章节标题

  - Windows Service
  - Windows Service

#### 属性/方法表格

**表格 1:**

| << Click to Display Table of Contents >>
      Navigation: 
      
      Developer's Guide > Deployment >
   
      Windows Service |  |
| --- | --- |

#### 详细内容

<< Click to Display Table of Contents >>

Windows Service
	  

The Windows Service is created and deployed like any regular Service application created using Delphi.

 

To install the service type the following command at the command line*:

 

MyServiceApp -install

 

You can start the service from Windows Service Manager or type the following command:

 

net start ServiceName

 

When you create a new project, the default value for the service name is: UniServiceModule

You can change it from ServiceModule.pas->UniServiceModule->Name

 

To uninstall the service:

 

MyServiceApp -uninstall

 

*Please note that command line prompt must be started with Administrative rights in order to be able to run the previous commands.

 

---

