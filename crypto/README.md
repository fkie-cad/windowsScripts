# Some crypto related scripts
Last updated: 19.08.2026  

## Contents
- [createOpensslCert](#createopensslcert)
- [sha256sum](#sha256sum)




## createOpensslCert
Creates .der and .pem ssl keys and certificates in one command, 
  i.e. public key, private key, certificate, pfx.

**Requirements**  
Requires an openssl.exe found in the `%PATH%` or `%ProgramFiles%\Git\usr\bin\openssl.exe`.

**Remarks**  
It is not possible to create a .pfx file directly from a .der file. 
To achieve this, a .pem certificate and a private key are temporarily created in /d mode in order to generate the .pfx file.

### Usage
```bash
$ createOpensslCert.bat /n <name> [/rsa|/ed25519] [/b <bits>] [/subj ^<value^>] [/pass ^<value^>|/nopass] [/d] [/c] [/t] [/h]
```
**Options:**  
* /n : Base name of the files.
* /rsa : Create rsa key pair.
* /ed25519, /ec : Create ed25519 key pair (default).
* /b : Bits for RSA. Default: 4096.
* /crt : Create self signed certificate out of the keys.
    * /subj : Subject for certificate, e.g. "/CN=bla". Default: /CN=^<name^>.
* /pfx : Create pfx out of the priv key and cert.
    * /pass : Password for pfx. Suppresses prompt.
    * /nopass : No password for pfx. Suppresses prompt.
* /d, /der : Create .der formatted files. Default is .pem.
* /c : Convert the created files to other type (pem=>der, der=>pem)
* /t : Check the created files.
* /h : Print this.



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
