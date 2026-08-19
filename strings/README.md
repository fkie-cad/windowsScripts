# Some string handling scripts
Last updated: 19.08.2026  

## Contents
- [FindAndReplace](#findandreplace)




## FindAndReplace
Finds and replaces a string in a file with another one.

### Usage
```bash
ps> FindAndReplace.ps1 -SearchString <value> -ReplaceString <value> -Path <path> [-AllowedExtensions <extensions>] [-CaseInsensitive] [-DryRun]
```

**Options:**  
* -SearchString The string to search.
* -ReplaceString The replacement string.
* -Path The parent directory.
* -AllowedExtensions List of white listed extensions.
* -CaseInsensitive Run case insensitive.
* -DryRun Just show what would be replaced, don't actually change the files.
