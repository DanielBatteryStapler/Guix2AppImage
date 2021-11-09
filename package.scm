(use-modules (guix packages)
	(guix gexp)
	((guix licenses) #:prefix license:)
	(guix build-system copy))

(package
	(name "Guix2AppImage")
	(version "13.0")
	(inputs '())
	(native-inputs '())
	(propagated-inputs '())
	(source (local-file "./src" #:recursive? #t))
	(build-system copy-build-system)
	(arguments 
		'(#:install-plan
			'(("guix2appimage.scm" "bin/guix2appimage"))))
	(synopsis "Guix2Appimage: create appimages with guix")
	(description
		"Create appimages from Guix manifests.")
	(home-page "https://github.com/danielbatterystapler/not_publically_released")
	(license license:gpl3+))

