#!python3

import argparse
from pathlib import Path
import pefile
import requests
import sys

SYMBOLS_SERVER = 'https://msdl.microsoft.com/download/symbols'

PROGRAM_DESCRIPTION = 'A PDB file download tool.'
PROGRAM_NAME = 'loadPdb'
PROGRAM_VERSION = '1.0.1'


def loadPdb(file_path, target_dir):
        
    file_stem = Path(file_path).stem
    
    print("path: %s" % file_path);
    print("  stem: %s" % file_stem);

    try:
        pe = pefile.PE(file_path, fast_load=True)
    except pefile.PEFormatError:
        print("  [e] pe parsing error")
        return -2
        
    pe.parse_data_directories()
    for directory in pe.DIRECTORY_ENTRY_DEBUG:
        debug_entry = directory.entry
        if hasattr(debug_entry, 'PdbFileName'):
            pdb_file = debug_entry.PdbFileName[:-1].decode('ascii')
            guid = f'{debug_entry.Signature_Data1:08x}'
            guid += f'{debug_entry.Signature_Data2:04x}'
            guid += f'{debug_entry.Signature_Data3:04x}'
            guid += f'{debug_entry.Signature_Data4:02x}'
            guid += f'{debug_entry.Signature_Data5:02x}'
            guid += f'{int.from_bytes(debug_entry.Signature_Data6, byteorder="big"):08x}'
            guid = guid.upper()
            url = f'{SYMBOLS_SERVER}/{pdb_file}/{guid}{debug_entry.Age:x}/{pdb_file}'
            print("  url: %s" % url);
            
            target_path = f'{target_dir}/{guid}-{debug_entry.Age:x}-{file_stem}.pdb'
            print("  target_path: %s" % target_path);
            r = requests.get(url)
            
            if r.status_code != 200:
                print("  [e] Url not found! (%u)" % r.status_code);
                break
            
            f = open(target_path, 'wb')
            f.write(r.content)
            f.close()
            print("  [x]  done")
            
            break
            
    return 0


def check_arguments():
    parser = argparse.ArgumentParser()
    parser.description = PROGRAM_DESCRIPTION
    parser.usage = 'python %(prog)s [options] file1 [file2 ...]'
    parser.add_argument('-v', '--version', action='version', version='{} {}'.format(PROGRAM_NAME, PROGRAM_VERSION))
    parser.add_argument('-t', '--target', help='Target dir to store the downloaded files.', default="~/Downloads", type=str, required=False)
    parser.add_argument('-f', '--filetype', help='Filetype filter for a directory.', default="*", type=str, required=False)
    parser.add_argument('-r', '--recursive', help='Iterate the files of a directory recursively.', action='store_true', required=False)
    # parser.add_argument('-d', '--debug-print', help='Show debug prints.', action='store_true', required=False)
    parser.add_argument('files', nargs='+', help='A list of files or direcotry pathes.', default=None, type=str)

    return parser.parse_args()


if __name__ == '__main__':
    args = check_arguments()
    if args is None:
        sys.exit()

    files = args.files
    number_of_files = len(files)
    recursive = args.recursive
    print("recursive: %s" % str(recursive));
    file_type = args.filetype
    print("file_type: %s" % file_type);
    
    target_dir = Path(args.target).expanduser()
    print("target_dir: %s" % target_dir);
    
    if not target_dir.is_dir():
        raise IOError('IOError: Target dir does not exist: %s' % target_dir)
    
    for f in files:
        file_path = Path(f).expanduser()
        
        if file_path.is_file():
            s = loadPdb(file_path, target_dir)
        elif file_path.is_dir():
            if recursive:
                gfilter = '**/*.%s' % file_type
            else:
                gfilter = './*.%s' % file_type
            
            for path in file_path.glob(gfilter):
                s = loadPdb(path, target_dir)
        else:
            print("[e] Did not find %s" % f)
        

    sys.exit()

