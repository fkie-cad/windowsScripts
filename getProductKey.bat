::wmic path softwarelicensingservice get OA3xOriginalProductKey

reg query "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\ClipSVC\Parameters" /v LastBiosKey
::reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ClipSVC\Parameters" /v LastBiosKey
