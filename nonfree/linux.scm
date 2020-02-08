(define-module (nonfree)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system trivial)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages linux)
  #:use-module (srfi srfi-1))

(define-public linux-nonfree
  (package
    (inherit linux-libre)
    (name "linux-nonfree")
    (version (package-version linux-libre))
    (source
     (origin
      (method url-fetch)
      (uri
       (string-append
	"https://www.kernel.org/pub/linux/kernel/v4.x/"
	"linux-" version ".tar.xz"))
      (sha256
       (base32
	"1lm2s9yhzyqra1f16jrjwd66m3jl43n5k7av2r9hns8hdr1smmw4"))))
    (native-inputs
     `(("kconfig" ,(local-file "./linux-custom.conf"))
       ,@(alist-delete "kconfig" (package-native-inputs linux-libre))))))

(define (linux-firmware-version) "9d40a17beaf271e6ad47a5e714a296100eef4692")
(define (linux-firmware-source version)
  (origin
    (method git-fetch)
    (uri (git-reference
	  (url (string-append "https://git.kernel.org/pub/scm/linux/kernel"
			      "/git/firmware/linux-firmware.git"))
	  (commit version)))
    (file-name (string-append "linux-firmware-" version "-checkout"))
    (sha256
     (base32
      "099kll2n1zvps5qawnbm6c75khgn81j8ns0widiw0lnwm8s9q6ch"))))

(define-public linux-firmware-iwlwifi
  (package
    (name "linux-firmware-iwlwifi")
    (version (linux-firmware-version))
    (source (linux-firmware-source version))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder (begin
		   (use-modules (guix build utils))
		   (let ((source (assoc-ref %build-inputs "source"))
			 (fw-dir (string-append %output "/lib/firmware/")))
		     (mkdir-p fw-dir)
		     (for-each (lambda (file)
				 (copy-file file
					    (string-append fw-dir (basename file))))
			       (find-files source
					   "iwlwifi-.*\\.ucode$|LICENSE\\.iwlwifi_firmware$"))
		     #t))))
    (home-page "https://wireless.wiki.kernel.org/en/users/drivers/iwlwifi")
    (synopsis "Non-free firmware for Intel wifi chips")
    (description "Non-free iwlwifi firmware")
    (license (license:non-copyleft
	      "https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/tree/LICENCE.iwlwifi_firmware?id=HEAD"))))