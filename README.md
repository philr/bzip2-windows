# Bzip2 – Visual Studio libbz2.dll Build #

Patches and a PowerShell script to build [bzip2](http://www.bzip.org/) with Visual Studio using a dynamic library (libbz2.dll).

## Patches ##

Patches are included in this repository that modify the `makefile.msc` file in the bzip2 distribution to:

- Build cleanly with Visual Studio 2013 and later (replacing deprecated command line options).
- Build libbz2 as a DLL (`libbz2.dll`).
- Dynamically link the executable outputs with `libbz2.dll` (by default the executables are statically linked).
- Add a version resource to the executables and DLL.

## PowerShell Script ##

The PowerShell script, `Build-Bzip2.ps1`, performs the following actions:

1. Downloads the bzip2 source from [http://www.bzip.org](http://www.bzip.org).
2. Extracts the source.
3. Applies the patches (see above).
4. For the x86 and x64 architectures:
   1. Executes `nmake` to build bzip2.
   2. Copies build outputs to a directory named `outputs`.
   3. Creates zipped packages containing build outputs in a directory named `packages`.

`Build-Bzip2.ps1` requires:

- 64-bit Windows.
- Microsoft Visual Studio 2013 or later (set $VisualStudioDir accordingly).
- [PowerShell Community Extensions](https://pscx.codeplex.com/).
- Git (used to apply patches).

## Binaries ##

32-bit and 64-bit Windows binaries can be [downloaded from the releases page](https://github.com/philr/bzip2-windows/releases).

The binary releases depend on the Visual Studio C Runtime Library (please refer to the release notes for details).