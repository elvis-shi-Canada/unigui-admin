# uniGUI Developer Manual

来源: https://www.unigui.com/doc/online_help/index.html

---

## 文档目录

1. [Introduction](#section-1)
2. [System Requirements](#section-2)
3. [Installation Instructions](#section-3)
4. [Installing uniGUI Using The New Installer](#section-4)
5. [Trial Edition](#section-5)
6. [Commercial Edition](#section-6)
7. [Trial Edition (C++ Builder)](#section-7)
8. [Commercial Edition (C++ Builder)](#section-8)
9. [C++ Builder (Without RAD Studio)](#section-9)
10. [Bypassing Installer BDS check](#section-10)
11. [Building 64-bit library files](#section-11)
12. [Silent Installation of Runtime Packages](#section-12)
13. [Sencha Touch Installation](#section-13)
14. [Running Demos](#section-14)
15. [Technology Overview](#section-15)
16. [Unified GUI](#section-16)
17. [uniGUI Application Architecture](#section-17)
18. [Deployment Options](#section-18)
19. [Forms and Modules](#section-19)
20. [ServerModule](#section-20)
21. [MainModule](#section-21)
22. [LoginForm](#section-22)
23. [MainForm](#section-23)
24. [Other Forms](#section-24)
25. [Application Form](#section-25)
26. [Free Form](#section-26)
27. [DataModules](#section-27)
28. [Application DataModule](#section-28)
29. [Free DataModule](#section-29)
30. [Frames](#section-30)
31. [ServiceModule](#section-31)
32. [Components](#section-32)
33. [Standard](#section-33)
34. [Additional](#section-34)
35. [Data Controls](#section-35)
36. [Extra](#section-36)
37. [UniApplication Object](#section-37)
38. [UniSession Object](#section-38)
39. [UniServerInstance Object](#section-39)
40. [Creating a New uniGUI Application](#section-40)
41. [Standalone Server Project](#section-41)
42. [Standalone Server (Console Application)](#section-42)
43. [Standalone Server / ISAPI Module Project](#section-43)
44. [ISAPI Module Project](#section-44)
45. [Windows Service Project](#section-45)
46. [Apache Module](#section-46)
47. [Application Design Considerations](#section-47)
48. [General Design Concept](#section-48)
49. [Web Application Scalability](#section-49)
50. [Create Resources on Demand](#section-50)

---

## 1. Introduction

### Introduction

来源: https://www.unigui.com/doc/online_help/introduction.htm

#### 小节标题

  - Introduction
  - Introduction

#### 内容

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

#### 小节标题

  - System Requirements
  - System Requirements

#### 内容

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

#### 小节标题

  - Installation Instructions
  - Installation Instructions
    - Introduction to New Installer
      - 
      - Installing uniGUI using New Installer
      - 
    - Installing using uniGUI Legacy Installer
      - 

#### 内容

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

#### 小节标题

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

#### 内容

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

#### 小节标题

  - Trial Edition
  - Trial Edition

#### 内容

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

#### 小节标题

  - Commercial Edition
  - Commercial Edition

#### 内容

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

#### 小节标题

  - Trial Edition (C++ Builder)
  - Trial Edition (C++ Builder)

#### 内容

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

#### 小节标题

  - Commercial Edition (C++ Builder)
  - Commercial Edition (C++ Builder)

#### 内容

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

#### 小节标题

  - C++ Builder (Without RAD Studio)
  - C++ Builder (Without RAD Studio)

#### 内容

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

#### 小节标题

  - Bypassing Installer BDS check
  - Bypassing Installer BDS check

#### 内容

<< Click to Display Table of Contents >>

Bypassing Installer BDS check
	  

Normally uniGUI installer will check for a running instance Delphi before starting installation. If a Delphi instance is running the installer will not allow to go the next step unless BDS instance(s) are closed.

You cay bypass this by using -BDS switch and running the installer from a command line. This will allow you to install uniGUI even if a BDS (Delphi) instance is running.

 

Warning: uniGUI installer will apply several changes to Delphi registry settings. Those setting won't become effective unless Delphi is re-started. Use this switch at your own risk.

---

## 11. Building 64-bit library files

### Installation > Installation Instructions > Building 64-bit library files

来源: https://www.unigui.com/doc/online_help/building-64-bit-library-files.htm

#### 小节标题

  - Building 64-bit library files
  - Building 64-bit library files

#### 内容

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

#### 小节标题

  - Silent Installation of Runtime Packages
  - Silent Installation of Runtime Packages

#### 内容

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

#### 小节标题

  - Sencha Touch Installation
  - Sencha Touch Installation

#### 内容

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

#### 小节标题

  - Running Demos
  - Running Demos

#### 内容

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

#### 小节标题

  - Technology Overview
  - Technology Overview

#### 内容

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

#### 小节标题

  - Unified GUI
  - Unified GUI

#### 内容

<< Click to Display Table of Contents >>

Unified GUI
	  

uniGUI stands for Unified Graphical User Interface or Unified GUI in short. It is called unified because it provides the same UI experience in all devices with a Web browser. Regardless of the device, OS, CPU, and display, the user experience will be the same on all devices with a compatible Web browser. It allows great freedom in choosing client devices. Client devices can be Windows PC, OSX devices, Linux PC, smart phones, tablets, or even a Raspberry Pi!

 

Of course, this feature is not something unique to uniGUI. This level of platform independence is something that any Web application can provide, except that uniGUI enables you to create Web applications which are very close to desktop applications in their look and feel.

 

---

## 17. uniGUI Application Architecture

### Technology Overview > uniGUI Application Architecture

来源: https://www.unigui.com/doc/online_help/unigui_application_architecture.htm

#### 小节标题

  - uniGUI Application Architecture
  - uniGUI Application Architecture

#### 内容

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

#### 小节标题

  - Deployment Options
  - Deployment Options

#### 内容

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

#### 小节标题

  - Forms and Modules
  - Forms and Modules

#### 内容

<< Click to Display Table of Contents >>

Forms and Modules
	  

Every uniGUI application is created with a specialized form named MainForm and two data modules, MainModule and ServerModule. The LoginForm has also a special meaning in uniGUI .

---

## 20. ServerModule

### Technology Overview > Forms and Modules > ServerModule

来源: https://www.unigui.com/doc/online_help/server_module.htm

#### 小节标题

  - ServerModule
  - ServerModule

#### 内容

<< Click to Display Table of Contents >>

ServerModule
	  

uniGUI ServerModule

 

Each uniGUI application contains a special data module named ServerModule, which is the core module of the application. It is a singleton, which means that it is created only once per application. It is mainly used to configure various server settings. ServerModule will be covered in more detail in other sections.

 

 

---

## 21. MainModule

### Technology Overview > Forms and Modules > MainModule

来源: https://www.unigui.com/doc/online_help/main_module.htm

#### 小节标题

  - MainModule
  - MainModule

#### 内容

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

#### 小节标题

  - LoginForm
  - LoginForm

#### 内容

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

#### 小节标题

  - MainForm
  - MainForm

#### 内容

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

#### 小节标题

  - Other Forms
  - Other Forms

#### 内容

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

#### 小节标题

  - Application Form
  - Application Form
  - Using Application Form's global function

#### 内容

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

#### 小节标题

  - Free Form
  - Free Form

#### 内容

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

#### 小节标题

  - DataModules
  - DataModules

#### 内容

<< Click to Display Table of Contents >>

DataModules
	  

uniGUI supports adding DataModules to the project. It allows developers to design their app like a standard VCL application, dividing the application business logic among several DataModules. The important thing to remember is that while uniGUI DataModules are identical to standard VCL DataModules in nature, when they are created using the uniGUI wizard, they will be managed automatically for each session (its lifetime will be the same as the session itself). If the DataModule is created using the standard IDE, it is the responsibility of the developer to create and release it when appropriate.

 

Using uniGUI wizard to create a new DataModule

 

There are two types of DataModules in uniGUI. Application DataModule and Free DataModule.

---

## 28. Application DataModule

### Technology Overview > Forms and Modules > DataModules > Application DataModule

来源: https://www.unigui.com/doc/online_help/application-datamodule.htm

#### 小节标题

  - Application DataModule
  - Application DataModule

#### 内容

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

#### 小节标题

  - Free DataModule
  - Free DataModule

#### 内容

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

#### 小节标题

  - Frames
  - Frames

#### 内容

<< Click to Display Table of Contents >>

Frames
	  

uniGUI has complete support for frames. Frames must be created using the uniGUI IDE wizard.

 

Using uniGUI wizard to create a new Frame

 

An empty uniGUI Frame

---

## 31. ServiceModule

### Technology Overview > Forms and Modules > ServiceModule

来源: https://www.unigui.com/doc/online_help/servicemodule.htm

#### 小节标题

  - ServiceModule
  - ServiceModule

#### 内容

<< Click to Display Table of Contents >>

ServiceModule
	  

A ServiceModule is only created when the project type is Windows Service. It is a descendant of Delphi's standard TService class. It allows to configure Windows Service related parameters including service name, service type, etc.

---

## 32. Components

### Technology Overview > Forms and Modules > Components

来源: https://www.unigui.com/doc/online_help/components.htm

#### 小节标题

  - Components
  - Components

#### 内容

<< Click to Display Table of Contents >>

Components
	  

As Delphi itself, uniGUI offers a similar set of non-visual and visual components. Some of the Delphi components are compatible or supported by uniGUI, making unnecessary to include them as part of the uniGUI packages. For example, many data access controls are the same for VCL and uniGUI applications. Other components, like the TActionList, are supported by uniGUI.

 

uniGUI visual controls are Ext JS controls (or are made with), which typically offer a superset of the equivalent VCL controls. Sometimes, the functionality of the uniGUI control is closer to a powerful 3rd-party control (like a DevExpress or TMS control) than to the original VCL control.

 

The next sections will help developers to choose the correct uniGUI controls based on their previous experience with Delphi and the VCL control palette.

---

## 33. Standard

### Technology Overview > Forms and Modules > Components > Standard

来源: https://www.unigui.com/doc/online_help/standard.htm

#### 小节标题

  - Standard
  - Standard

#### 内容

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

#### 小节标题

  - Additional
  - Additional

#### 内容

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

#### 小节标题

  - Data Controls
  - Data Controls

#### 内容

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

#### 小节标题

  - Extra
  - Extra

#### 内容

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

#### 小节标题

  - UniApplication Object
  - UniApplication Object

#### 内容

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

#### 小节标题

  - UniSession Object
  - UniSession Object

#### 内容

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

#### 小节标题

  - UniServerInstance Object
  - UniServerInstance Object

#### 内容

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

#### 小节标题

  - Creating a New uniGUI Application
  - Creating a New uniGUI Application

#### 内容

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

#### 小节标题

  - Standalone Server Project
  - Standalone Server Project
      - Delphi:
      - C++ Builder:

#### 内容

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

#### 小节标题

  - Standalone Server (Console Application)
  - Standalone Server (Console Application)

#### 内容

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

#### 小节标题

  - Standalone Server / ISAPI Module Project
  - Standalone Server / ISAPI Module Project

#### 内容

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

#### 小节标题

  - ISAPI Module Project
  - ISAPI Module Project

#### 内容

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

#### 小节标题

  - Windows Service Project
  - Windows Service Project

#### 内容

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

#### 小节标题

  - Apache Module
  - Apache Module

#### 内容

<< Click to Display Table of Contents >>

Apache Module
	  

Enter topic text here.

---

## 47. Application Design Considerations

### Developer's Guide > Application Design Considerations

来源: https://www.unigui.com/doc/online_help/application-design-considerati.htm

#### 小节标题

  - Application Design Considerations
  - Application Design Considerations

#### 内容

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

#### 小节标题

  - General Design Concept
  - General Design Concept

#### 内容

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

#### 小节标题

  - Web Application Scalability
  - Web Application Scalability

#### 内容

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

#### 小节标题

  - Create Resources on Demand
  - Create Resources on Demand

#### 内容

<< Click to Display Table of Contents >>

Create Resources on Demand
	  

This is an approach which must be followed when designing a scalable web application. The general rule here is to create resource sensitive objects when they are needed, not before, and destroy them when they are no longer needed. One example is database tables. As described in the previous section, database tables can load many rows at once, which can increase memory usage with increased number of rows. It is true especially with memory datasets. Delphi's built-in TClientDataset is an example of memory dataset. In order to make sure a dataset is created and loaded with data when it is needed, it is good to place the dataset on a form or frame where db-aware controls exist. Each time the user needs to visit that form, it will be created and shown along with tables and db-aware controls. When the user closes the form, the dataset will be freed and its memory is sent back to the application memory pool.

 

The  method can be applied to reporting tools. Instead of putting report components on MainModule, it can be created just before generating the report and destroyed right after the report is generated and saved in a temporary file.

---

