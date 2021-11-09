(use-modules (gnu packages bash)
	(gnu packages games))

`(
	(app-manifest
		,(packages->manifest
			(list
				bash
				cowsay
				fortune-mod)))
	(entry-point ,"bash")
	(desktop-file ,(local-file "AppDir.example/myapp.desktop"))
	(small-icon-file ,(local-file "AppDir.example/myapp.png"))
	(big-icon-file ,(local-file "AppDir.example/myapp.png")))
