# Changes

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
