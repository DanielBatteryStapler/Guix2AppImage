#!/usr/bin/env -S guix repl -- 
!#
(use-modules
	(guix gexp)
	(guix ui)
	(guix store)
	(guix monads)
	(guix modules)
	(guix packages)
	(guix profiles)
	(guix derivations)
	(gnu packages gnupg)
	(srfi srfi-26))

(define wrapped-manifest-entry (@@ (guix scripts pack) wrapped-manifest-entry))
(define manifest->friendly-name (@@ (guix scripts pack) manifest->friendly-name))

;copied from guix/scripts/pack.scm (with minor edits)
(define (import-module? module)
	;; Since we don't use deduplication support in 'populate-store', don't
	;; import (guix store deduplication) and its dependencies, which includes
	;; Guile-Gcrypt.  That way we can run tests with '--bootstrap'.
	(not (equal? '(guix store deduplication) module)))

(define arguments (cdr (command-line)))
(if (not (equal? (length arguments) 1))
	(begin
		(display "guix2appimage: invalid number of arguments")
		(newline)
		(display "guxi2appimage: Usage:  guix2appimage appdir-scm-file")
		(newline)
		(exit 1)))
(define appdir-definition-file (list-ref arguments 0))
(define appdir-definition (load* appdir-definition-file (make-user-module '((guix profiles) (gnu)))))

(define app-manifest (car (assoc-ref appdir-definition 'app-manifest)))
(define entry-point (car (assoc-ref appdir-definition 'entry-point)))
(define desktop-file (car (assoc-ref appdir-definition 'desktop-file)))
(define small-icon-file (car (assoc-ref appdir-definition 'small-icon-file)))
(define big-icon-file (car (assoc-ref appdir-definition 'big-icon-file)))

(define app-manifest-wrapped
	(map-manifest-entries
		(cut wrapped-manifest-entry <> #:proot? #t)
		app-manifest))

(define my-store-monad (open-connection))
;I don't entirely understand the whole state monad thing, but I believe this is a thing I need to do. That is, actually obtain the monad by opening a connection

(define app-profile
	(run-with-store my-store-monad
		(profile-derivation
			app-manifest-wrapped
			#:relative-symlinks? #t;needs to be relocatable
			#:hooks '();this is set to empty set in guix pack, so copying it here
			#:locales? #t)));ditto, but it was true

(define appdir-gexp
	(with-extensions (list guile-gcrypt)
	(with-imported-modules
		(source-module-closure
			`((guix build store-copy)
			#:select? import-module?))
		#~(begin
			(use-modules (guix build store-copy))
			
			(mkdir #$output)
			(populate-store '("profile") #$output #:deduplicate? #f);copy all of the store objects that the profile uses, and the profile itself, into the directory
			(copy-file #$desktop-file (string-append #$output "/myapp.desktop"))
			(copy-file #$small-icon-file (string-append #$output "/.DirIcon"))
			(copy-file #$big-icon-file (string-append #$output "/myapp.png"))
			(with-output-to-file
				(string-append #$output "/AppRun")
				(lambda ()
					(display "#!/bin/sh") (newline)
					(display "SELF=$(readlink -f \"$0\")") (newline)
					(display "HERE=${SELF%/*}") (newline)
					(display (string-append "export PATH=\"${HERE}" #$app-profile "/bin/:$PATH\"")) (newline)
					(display (string-append "exec " #$entry-point " \"$@\"")) (newline)))
			(chmod (string-append #$output "/AppRun") #o755)))))

(define appdir-derivation
	(run-with-store my-store-monad
		(gexp->derivation
			(string-append (manifest->friendly-name app-manifest) ".AppDir")
			appdir-gexp
			#:references-graphs `(("profile" ,app-profile)))))

(build-derivations my-store-monad (list appdir-derivation))

(system* "./appimagetool-x86_64.AppImage" (derivation->output-path appdir-derivation) "myapp.AppImage")

(display (derivation->output-path appdir-derivation))
(newline)









