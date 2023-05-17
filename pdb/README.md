# Some PDB scripts
Last updated: 28.01.2023  

## Contents
- [loadPdb](#loadPdb)



## loadPdb
Python script to download the PDBs of one or more files from the MS servers.

### Usage
```bash
$ python loadPdb.py [-t <dir>] [-f <type>] [-r] files...
```

Options:
* -t Target dir to store the downloaded files. Defaults to "~/Downloads".
* -f Filetype filter for a directory.. Defaults to "*" i.e. all files.
* -r Iterate the files of a directory recursively.
* files... A list of files or directory paths.
