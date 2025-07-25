# Some crypto related scripts
Last updated: 12.06.2023  

## Contents
- [createOpensslCert](#createopensslcert)
- [sha256sum](#sha256sum)




## createOpensslCert
Creates .der and .pem ssl keys and certificates in one command, 
  i.e. public key, private key and certificate.

**Requirements**  
Requires an openssl.exe found in the `%PATH%` or `%ProgramFiles%\Git\usr\bin\openssl.exe`.

**Remarks**  
Somehow, it throws an error, when creating a public key out of a .der private key.
Therefor, there is no option to create .der keys directly.
The default is to create the .pem keys and if needed, convert them to .der with the `/c` option.


### Usage
```bash
$ createOpensslCert.bat /n <name> [/a=<algorithm>] [/b=<bits>] [/d] [/c] [/h]
```
**Options:**  
* /a Algorithm: RSA|ED25519. Default: ED25519.
* /b Bits for RSA. Default: 4096.
* /c Check the created files.
* /d Additionally convert to .der format.
* /n Base name of the files.
* /h Print this.



## sha256sum
Calculate sha256 of file.  
Wrapper for `certutil -hashfile <filename> sha256`

### Usage
```bash
$ sha256sum.bat <file> [/h]
```
**Options:**  
* file The file path to sha256.
* /h Print help info.
