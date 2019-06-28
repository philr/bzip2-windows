# Changes

## Release v1.0.7.0 - 28-Jun-2019

- [bzip2 version 1.0.7](<https://sourceware.org/ml/bzip2-devel/2019-q2/msg00022.html>):
  - Fix undefined behaviour in the macros `SET_BH`, `CLEAR_BH`  and `ISSET_BH`.
  - bzip2: Fix return value when combining `--test`, `-t` and `-q`.
  - bzip2recover: Fix buffer overflow for large `argv[0]`.
  - bzip2recover: Fix use after free issue with `outFile` (CVE-2016-3189).
  - Make sure `nSelectors` is not out of range (CVE-2019-12900).


## Release v1.0.6.1 - 21-May-2019

- Visual Studio 2015 is now used to build (instead of Visual Studio 2013).
- The build script has been updated to download from the new bzip2 project home
  page at <https://www.sourceware.org/bzip2>.
- The downloaded file is verified against an expected SHA-256 hash.
- A patch has been applied to allow files larger than 2³² - 1 bytes to be
  handled (fixes a 'not a normal file' error). Resolves #3.


## Release v1.0.6 - 1-Feb-2015

- Initial version of the patches and build script.
- bzip2 version 1.0.6.
