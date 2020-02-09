(define-module (nonfree linux)
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
	"https://www.kernel.org/pub/linux/kernel/v5.x/"
	"linux-" version ".tar.xz"))
      (sha256
       (base32
        "12ad4fnxag16ar2afiljv4nnv15i4f493sz6m7i9qgjld7yz3scj"	))))
    ;; (native-inputs
    ;;  `(("kconfig" ,(local-file "./linux-custom.conf"))
    ;;    ,@(alist-delete "kconfig" (package-native-inputs linux-libre))

    ;;    ))

    ))

(define (linux-firmware-version) "04e0b4cf4caee531448671c8a836223f05b72ba6")
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
      "15nkz8hp17gyxx365aq048nmcvyzhi18avqbywhglrbwvi9b5hgs"))))

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
