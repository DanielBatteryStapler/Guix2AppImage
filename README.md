# Guix2AppImage

A utility for converting any manifest of Guix packages into an executable AppImage.

Using a definition of the AppImage defined in Scheme, e.g. appdir.example.scm, it creates an AppImage that lets you run that/those Guix programs on any system that can run AppImages.

## Example Usage

Create a shell with -- or install -- Guix2AppImage.
```
$ ls
AppDir.example  appdir.example.scm  appimagetool-x86_64.AppImage  package.scm  README.md  src
$ guix shell -f package.scm

```

Invoke `guix2appimage` to build the AppImage defined by a Scheme file.
```
$ guix2appimage appdir.example.scm
```

Your new AppImage will be available as `myapp.AppImage`.
```
$ ls
AppDir.example  appdir.example.scm  appimagetool-x86_64.AppImage  myapp.AppImage  package.scm  README.md  src
```

Though this utility uses Guix, it does **not** currently run on a Guix System alone and only works with Guix installed on a foreign distribution. The reason for this is that the AppImageTool utility from [AppImageKit](https://github.com/AppImage/AppImageKit) to create AppImages from an AppDir does not work with Guix. It seemes to only be buildable by Docker and assumes file paths that do not hold for a Guix System. I attempted to package AppImageKit for Guix, but I was unable to do so. For this reason, the appimagetool-x86\_64.AppImage executable must be provided in the same working directory as the invocation of Guix2AppImage. I have included the appimagetool-x86\_64.AppImage executable within this repository for convenience, but any file named the same thing from the [AppImageKit repo](https://github.com/AppImage/AppImageKit) will work.

Guix2AppImage reads the definition for an AppDir, an example of which is given in the appdir.example.scm file. Using this information it will construct a relocatable AppDir and then use the local appimagetool executable to create the .AppImage file. The AppDir is created in the Guix store, and so it is cached, but because appimagetool does not run in a purely Guix environment, the executable is just invoked locally and therefore does not cache. The resulting .AppImage file is written to the working directory.

