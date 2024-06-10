::
:: WinPe start script, located in
:: X:\Windows\System32\startnet.cmd
::
:: Runs wpeinit and opens a new console with keyboard layout set to utf8
::
:: Version: 1.0.0
:: Last changed: 03.11.2021
::

@echo off

:: set /p confirm="Run wpeinit? (Y/n): "

::if [%confirm%]==[y] (
    wpeinit
::)

color 40
mode con cols=80 lines=5
prompt $$$S
wpeutil setkeyboardlayout 0407:00000407
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE" /v version
title Don't exit me! 
 
start cmd /t:0a /k "CHCP 65001 && prompt $$$S"
