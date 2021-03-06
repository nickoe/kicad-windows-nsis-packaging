; Installation script for KiCad generated by Alastair Hoyle
;
; This installation script requires NSIS (Nullsoft Scriptable Install System)
; version 3.x http://nsis.sourceforge.net/Main_Page
;
; This script is provided as is with no warranties.
;
; Copyright (C) 2006 Alastair Hoyle <ahoyle@hoylesolutions.co.uk>
; Copyright (C) 2015 Nick Østergaard
; Copyright (C) 2015 Brian Sidebotham <brian.sidebotham@gmail.com>
;
; This program is free software; you can redistribute it and/or modify it
; under the terms of the GNU General Public License as published by the Free
; Software Foundation. This program is distributed in the hope that it will be
; useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
; Public License for more details.
;
; This script should be in a subdirectory of the full build directory
; (Kicad/NSIS by default). When the build is updated the product and installer
; versions should be updated before recompiling the installation file
;
; This script expects the install.ico, uninstall.ico, language and license
; files to be in the same directory as this script

; General Product Description Definitions
!define PRODUCT_NAME "KiCad"
!define ALT_DOWNLOAD_WEB_SITE "http://iut-tice.ujf-grenoble.fr/kicad/"
!define LIBRARIES_WEB_SITE "https://github.com/KiCad/"
!define KICAD_MAIN_SITE "www.kicad-pcb.org/"
!define COMPANY_NAME ""
!define TRADE_MARKS ""
!define COPYRIGHT "Kicad Developers Team"
!define COMMENTS ""
!define HELP_WEB_SITE "http://groups.yahoo.com/group/kicad-users/"
!define DEVEL_WEB_SITE "https://launchpad.net/kicad/"
!define WINGS3D_WEB_SITE "http://www.wings3d.com"

!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define UNINST_ROOT "HKLM"

!define gflag ;Needed to use ifdef and such
;Define on command line //DPRODUCT_VERSION=42
!ifndef PRODUCT_VERSION
  !define PRODUCT_VERSION "unknown"
!endif

!ifndef OPTION_STRING
  !define OPTION_STRING "unknown"
!endif

;Comment out the following SetCompressor command while testing this script
;SetCompressor /final /solid lzma

CRCCheck force
;XPStyle on
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

!ifndef OUTFILE
  !define OUTFILE "kicad-product-${PRODUCT_VERSION}-${OPTION_STRING}.exe"
!endif
OutFile ${OUTFILE}

; Request that we are executed as admin rights so we can install into
; PROGRAMFILES without ending up in the virtual store
RequestExecutionLevel admin

!if ${ARCH} == 'x86_64'
  InstallDir "$PROGRAMFILES64\KiCad"
!else
  InstallDir "$PROGRAMFILES\KiCad"
!endif

ShowInstDetails show
ShowUnInstDetails show
BrandingText "KiCad installer for windows"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "install.ico"
!define MUI_UNICON "uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "kicad-header.bmp" ; optional
!define MUI_WELCOMEFINISHPAGE_BITMAP "kicad-welcome.bmp"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${UNINST_ROOT}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Installer pages
!define MUI_CUSTOMFUNCTION_GUIINIT myGuiInit
!define MUI_CUSTOMFUNCTION_UNGUIINIT un.myGuiInit
!define MUI_WELCOMEPAGE_TEXT $(WELCOME_PAGE_TEXT)
;!define MUI_WELCOMEPAGE_TEXT "test"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE $(MUILicense)
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_SHOWREADME ${WINGS3D_WEB_SITE}
!define MUI_FINISHPAGE_SHOWREADME_TEXT "text"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_PAGE_CUSTOMFUNCTION_PRE ModifyFinishPage
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
; - To add another language; add an insert macro line here and include a language file as below
; - This must be after all page macros have been inserted
!insertmacro MUI_LANGUAGE "English" ;first language is the default language
;!insertmacro MUI_LANGUAGE "French"
;!insertmacro MUI_LANGUAGE "Italian"
;!insertmacro MUI_LANGUAGE "Polish"
;!insertmacro MUI_LANGUAGE "Portuguese"
;!insertmacro MUI_LANGUAGE "Dutch"
;!insertmacro MUI_LANGUAGE "Russian"
;!insertmacro MUI_LANGUAGE "Japanese"

!include "English.nsh"
;!include "French.nsh"
;!include "Dutch.nsh"
;!include "Italian.nsh"
;!include "Japanese.nsh"
;!include "Polish.nsh"
;!include "Portuguese.nsh"
;!include "Russian.nsh"

; MUI end ------

Function .onInit
  ; Request that we get elevated rights to install so that we don't end up in
  ; the virtual store
  ClearErrors
  UserInfo::GetName
  IfErrors Win9x
  Pop $0
  UserInfo::GetAccountType
  Pop $1
  UserInfo::GetOriginalAccountType
  Pop $2
  StrCmp $1 "Admin" 0 AdminQuit
    Goto LangDisplay
  
  AdminQuit:
    MessageBox MB_OK "Admin rights are required to install KiCad!"
    Quit

  LangDisplay:    
    ReserveFile "install.ico"
    ReserveFile "uninstall.ico"
    ReserveFile "${NSISDIR}\Plugins\x86-unicode\InstallOptions.dll"
    ReserveFile "${NSISDIR}\Plugins\x86-unicode\LangDLL.dll"
    ReserveFile "${NSISDIR}\Plugins\x86-unicode\System.dll"
    ReserveFile "${NSISDIR}\Contrib\Modern UI\ioSpecial.ini"
    !insertmacro MUI_LANGDLL_DISPLAY
    Goto done

  Win9x:
    MessageBox MB_OK "Error! This can't run under Windows 9x!"
    Quit

  done:
FunctionEnd

Function myGuiInit
  Call PreventMultiInstances
  Call CheckAlreadyInstalled
FunctionEnd

Function ModifyFinishPage
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Text" $(WINGS3D_PROMPT)
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 4" "Bottom" 168                 ;make more space for prompt
  !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Settings" "CancelShow" "0"            ;hide cancel button - already installed!!
FunctionEnd

Section $(TITLE_SEC_MAIN) SEC01
  SectionIn RO
  SetOverwrite try
  SetOutPath "$INSTDIR"
  File /nonfatal "..\AUTHORS.txt"
  File /nonfatal "..\COPYRIGHT.txt"
  File /nonfatal "..\license_for_documentation.txt"
  SetOutPath "$INSTDIR\share\kicad\template"
  File /nonfatal /r "..\share\kicad\template\*"
  SetOutPath "$INSTDIR\bin"
  File /r "..\bin\*"
  SetOutPath "$INSTDIR\lib"
  File /r "..\lib\*"
  SetOutPath "$INSTDIR\share\kicad\internat"
  File /nonfatal /r "..\share\kicad\internat\*"
SectionEnd

Section $(TITLE_SEC_SCHLIB) SEC02
  SetOverwrite try
  SetOutPath "$INSTDIR\share\kicad\library"
  File /nonfatal /r "..\share\kicad\library\*"
SectionEnd

Section $(TITLE_SEC_FPLIB) SEC03
  SetOverwrite try
  SetOutPath "$INSTDIR\share\kicad\modules"
  File /nonfatal /r "..\share\kicad\modules\*"
SectionEnd

Section $(TITLE_SEC_DEMOS) SEC04
  SetOverwrite try
  SetOutPath "$INSTDIR\share\kicad\demos"
  File /nonfatal /r "..\share\kicad\demos\*"
  SetOutPath "$INSTDIR\share\doc\kicad\tutorials"
  File /nonfatal /r "..\share\doc\kicad\tutorials\*"
SectionEnd

Section $(TITLE_SEC_DOCS) SEC05
  SetOverwrite try
  SetOutPath "$INSTDIR\share\doc\kicad\help"
  File /nonfatal /r "..\share\doc\kicad\help\*"
SectionEnd

Section -CreateShortcuts
  SetOutPath $INSTDIR
  WriteIniStr "$INSTDIR\HomePage.url"     "InternetShortcut" "URL" "${KICAD_MAIN_SITE}"
  WriteIniStr "$INSTDIR\UserGroup.url"    "InternetShortcut" "URL" "${HELP_WEB_SITE}"
  WriteIniStr "$INSTDIR\DevelGroup.url"   "InternetShortcut" "URL" "${DEVEL_WEB_SITE}"
  WriteIniStr "$INSTDIR\LibrariesGroup.url" "InternetShortcut" "URL" "${LIBRARIES_WEB_SITE}"
  WriteIniStr "$INSTDIR\Wings3D.url"      "InternetShortcut" "URL" "${WINGS3D_WEB_SITE}"
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\KiCad"
  CreateShortCut "$SMPROGRAMS\KiCad\Home Page.lnk" "$INSTDIR\HomePage.url"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad Alternate Download.lnk" "$INSTDIR\AltDownloadSite.url"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad Libraries.lnk" "$INSTDIR\LibrariesGroup.url"
  CreateShortCut "$SMPROGRAMS\KiCad\Wings3D.lnk" "$INSTDIR\Wings3D.url"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad User Group.lnk" "$INSTDIR\UserGroup.url"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad Devel Group.lnk" "$INSTDIR\DevelGroup.url"
  CreateShortCut "$SMPROGRAMS\KiCad\Uninstall.lnk" "$INSTDIR\uninstaller.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\KiCad.lnk" "$INSTDIR\bin\kicad.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Eeschema.lnk" "$INSTDIR\bin\eeschema.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Pcbnew.lnk" "$INSTDIR\bin\pcbnew.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Gerbview.lnk" "$INSTDIR\bin\gerbview.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Bitmap2component.lnk" "$INSTDIR\bin\bitmap2component.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\PCB calculator.lnk" "$INSTDIR\bin\pcb_calculator.exe"
  CreateShortCut "$SMPROGRAMS\KiCad\Pagelayout editor.lnk" "$INSTDIR\bin\pl_editor.exe"
  CreateShortCut "$DESKTOP\KiCad.lnk" "$INSTDIR\bin\kicad.exe"
SectionEnd

Section -CreateAddRemoveEntry
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "Publisher" "${COMPANY_NAME}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstaller.exe"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${KICAD_MAIN_SITE}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\bin\kicad.exe"
  WriteRegDWORD ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "NoModify" "1"
  WriteRegDWORD ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "NoRepair" "1"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "Comments" "${COMMENTS}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "HelpLink" "${HELP_WEB_SITE}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "URLUpdateInfo" "${KICAD_MAIN_SITE}"
  WriteRegStr ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "InstallLocation" "$INSTDIR"

  WriteUninstaller "$INSTDIR\uninstaller.exe"
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} $(DESC_SEC_MAIN)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} $(DESC_SEC_SCHLIB)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} $(DESC_SEC_FPLIB)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC04} $(DESC_SEC_DEMOS)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC05} $(DESC_SEC_DOCS)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd

Function un.myGuiInit
  Call un.PreventMultiInstances
  MessageBox MB_ICONEXCLAMATION|MB_YESNO|MB_DEFBUTTON2 $(UNINST_PROMPT) /SD IDYES IDYES +2
  Abort
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK $(UNINST_SUCCESS) /SD IDOK
FunctionEnd

Section Uninstall
  ;delete uninstaller first
  Delete "$INSTDIR\uninstaller.exe"

  ;remove start menu shortcuts and web page links
  SetShellVarContext all
  Delete "$SMPROGRAMS\KiCad\Home Page.lnk"
  Delete "$SMPROGRAMS\KiCad\Kicad Libraries.lnk"
  Delete "$SMPROGRAMS\KiCad\Kicad Alternate Download.lnk"
  Delete "$SMPROGRAMS\KiCad\Devel Group.lnk"
  Delete "$SMPROGRAMS\KiCad\User Group.lnk"
  Delete "$SMPROGRAMS\KiCad\Uninstall.lnk"
  Delete "$SMPROGRAMS\KiCad\KiCad.lnk"
  Delete "$SMPROGRAMS\KiCad\Wings3D.lnk"
  Delete "$DESKTOP\KiCad.lnk"
  Delete "$INSTDIR\Wings3D.url"
  Delete "$INSTDIR\HomePage.url"
  Delete "$INSTDIR\UserGroup.url"
  Delete "$INSTDIR\AltDownloadSite.url"
  Delete "$INSTDIR\DevelGroup.url"
  Delete "$INSTDIR\LibrariesGroup.url"
  RMDir "$SMPROGRAMS\KiCad"

  ;remove all program files now
  RMDir /r "$INSTDIR\bin"
  RMDir /r "$INSTDIR\lib"
  RMDir /r "$INSTDIR\library"
  RMDir /r "$INSTDIR\modules"
  RMDir /r "$INSTDIR\template"
  RMDir /r "$INSTDIR\internat"
  RMDir /r "$INSTDIR\demos"
  RMDir /r "$INSTDIR\tutorials"
  RMDir /r "$INSTDIR\help"
  RMDir /r "$INSTDIR\share\library"
  RMDir /r "$INSTDIR\share\modules"
  RMDir /r "$INSTDIR\share\kicad\template"
  RMDir /r "$INSTDIR\share\kicad\internat"
  RMDir /r "$INSTDIR\share\kicad\demos"
  RMDir /r "$INSTDIR\share\doc\kicad\tutorials"
  RMDir /r "$INSTDIR\share\doc\kicad\help"
  RMDir /r "$INSTDIR\share\doc\kicad"
  RMDir /r "$INSTDIR\share\doc"
  RMDir /r "$INSTDIR\share"
  RMDir /r "$INSTDIR\wings3d"
  ;don't remove $INSTDIR recursively just in case the user has installed it in c:\ or
  ;c:\program files as this would attempt to delete a lot more than just this package
  Delete "$INSTDIR\*.txt"
  RMDir "$INSTDIR"

  ;Note - application registry keys are stored in the users individual registry hive (HKCU\Software\kicad".
  ;It might be possible to remove these keys as well but it would require a lot of testing of permissions
  ;and access to other people's registry entries. So for now we will leave the application registry keys.

  ;remove installation registary keys
  DeleteRegKey ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd

Function PreventMultiInstances
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
  MessageBox MB_OK|MB_ICONEXCLAMATION $(INSTALLER_RUNNING) /SD IDOK
  Abort
FunctionEnd

Function un.PreventMultiInstances
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
  MessageBox MB_OK|MB_ICONEXCLAMATION $(UNINSTALLER_RUNNING) /SD IDOK
  Abort
FunctionEnd

Function CheckAlreadyInstalled
  ReadRegStr $R0 ${UNINST_ROOT} "${PRODUCT_UNINST_KEY}" "DisplayName"
  StrCmp $R0 "" +3
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION $(ALREADY_INSTALLED) /SD IDOK IDOK +2
  Abort
FunctionEnd
