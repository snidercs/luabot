; SPDX-FileCopyrightText: Michael Fisher @mfisher31
; SPDX-License-Identifier: MIT

; LuaBot LuaJIT Installer
; NSIS Modern User Interface

!include "MUI2.nsh"

; General
Name "LuaBot"
OutFile "luabot-win64-0.0.1-setup.exe"
Unicode True

; Default installation folder
InstallDir "$PROGRAMFILES64\LuaBot"

; Request application privileges
RequestExecutionLevel admin

; Interface Settings
!define MUI_ABORTWARNING

; Pages
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"

; Installer Section
Section "Install"
    SetOutPath "$INSTDIR"
    
    ; Install all files recursively from dist\windows
    File /r "dist\*"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ; Add to Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LuaBot" \
                     "DisplayName" "LuaBot LuaJIT"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LuaBot" \
                     "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LuaBot" \
                     "Publisher" "LuaBot"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LuaBot" \
                     "DisplayIcon" "$INSTDIR\bin\luajit.exe"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LuaBot" \
                       "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LuaBot" \
                       "NoRepair" 1
SectionEnd

; Uninstaller Section
Section "Uninstall"
    ; Remove all files and directories recursively
    RMDir /r "$INSTDIR"
    
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\LuaBot"
SectionEnd
