:: reg add "HKLM\System\ControlSet001\Control\Session Manager\Debug Print" /V DEFAULT /t REG_DWORD /d 0xff
:: reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Debug Print" /V DEFAULT /t REG_DWORD /d 0xff
reg add "HKLM\System\ControlSet001\Control\Session Manager\Debug Print Filter" /V DEFAULT /t REG_DWORD /d 0xff /f
::reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Debug Print Filter" /V DEFAULT /t REG_DWORD /d 0xff