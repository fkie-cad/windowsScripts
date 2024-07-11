#!python3

import argparse
from pathlib import Path
import pefile
import requests
import sys

SYMBOLS_SERVER = 'https://msdl.microsoft.com/download/symbols'
SYSTEM32 = 'C:\\Windows\\System32'
DRIVERS = 'C:\\Windows\\System32\\drivers'

PROGRAM_DESCRIPTION = 'A PDB file download tool.'
PROGRAM_NAME = 'loadPdb'
PROGRAM_VERSION = '1.0.0'


def loadPdb(file_path, target_dir):

    file_path = Path(file_path).expanduser()
    print("path: %s" % file_path);
    print("target_dir: %s" % file_path);
    
    if not file_path.is_file():
        return -1
    
    file_stem = Path(file_path).stem
    
    print("stem: %s" % file_stem);

    pe = pefile.PE(file_path, fast_load=True)
    pe.parse_data_directories()
    for directory in pe.DIRECTORY_ENTRY_DEBUG:
        debug_entry = directory.entry
        if hasattr(debug_entry, 'PdbFileName'):
            pdb_file = debug_entry.PdbFileName[:-1].decode('ascii')
            guid = f'{debug_entry.Signature_Data1:08x}'
            guid += f'{debug_entry.Signature_Data2:04x}'
            guid += f'{debug_entry.Signature_Data3:04x}'
            guid += f'{int.from_bytes(debug_entry.Signature_Data4, byteorder="big"):016x}'
            guid = guid.upper()
            url = f'{SYMBOLS_SERVER}/{pdb_file}/{guid}{debug_entry.Age:x}/{pdb_file}'
            print("url: %s" % url);
            
            target_path = f'{target_dir}/{guid}-{debug_entry.Age:x}-{file_stem}.pdb'
            print("  target_path: %s" % target_path);
            r = requests.get(url)
            if r.status_code != 200:
                print("  [e] url not found! (%u)" % r.status_code);
                break
                
            f = open(target_path, 'wb')
            f.write(pdb_file.content)
            f.close()
            
            break
            
    return 0


def dump(lm_path, target_dir):
    lm_path = Path(lm_path).expanduser()
    print("lm_path: %s" % lm_path);
    print("target_dir: %s" % lm_path);
    
    # Using readlines()
    sm_file = open(lm_path, 'r')
    sm_lines = sm_file.readlines()
      
    count = 0
    # Strips the newline character
    for line in sm_lines:
        count += 1
        # ~ print("Line{}: {}".format(count, line.strip()))
        
        x = line.split()
        # ~ print("%s" % str(x))
        if len(x) == 4:
            print("path: %s" % x[3])
            file_path = f'{DRIVERS}\\{x[3]}'
            s = loadPdb(file_path, target_dir)
            if s != 0:
                file_path = f'{SYSTEM32}\\{x[3]}'
                s = loadPdb(file_path, target_dir)
            if s != 0:
                print("[e] Did not pdb for %s" % file_path)


def check_arguments():
    parser = argparse.ArgumentParser()
    parser.description = PROGRAM_DESCRIPTION
    parser.usage = 'python %(prog)s [options] file1 [file2 ...]'
    parser.add_argument('-v', '--version', action='version', version='{} {}'.format(PROGRAM_NAME, PROGRAM_VERSION))
    parser.add_argument('-t', '--target', help='Target dir to store the downloaded files.', default="~/Downloads", type=str, required=False)
    parser.add_argument('-i', '--input', help='Input file with modules from a "windbg> lm sm f" command.', default="", type=str, required=True)

    return parser.parse_args()


if __name__ == '__main__':
    args = check_arguments()
    if args is None:
        sys.exit()

    lm_file = args.input
    
    target_dir = args.target
    target_dir = Path(target_dir).expanduser()
    
    if not target_dir.is_dir():
        raise IOError('IOError: Target dir does not exist: %s' % target_dir)
        
    dump(lm_file, target_dir)
    

    sys.exit()

