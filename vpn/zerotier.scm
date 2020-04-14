(define-module (vpn zerotier)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux))

;; TODO: Remove bundled dependencies in the "ext" directory.
(define-public zerotier-one
  (package
    (name "zerotier-one")
    (version "1.4.6")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url (string-append "https://github.com/zerotier/zerotierone.git"))
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32  "1jbn593iqxkna318h60mjw7vrcrhn1fvvi85i4fk49zs2g3phdn6"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags (list (string-append "DESTDIR=" (assoc-ref %outputs "out")))
       #:tests? #f
       #:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'patch-source
           (lambda* (#:key inputs #:allow-other-keys)
             (substitute* "make-linux.mk"
               (("\\$\\(DESTDIR\\)/usr") "$(DESTDIR)")
               (("/usr/sbin/") "/sbin/"))
             (let ((ip (string-append (assoc-ref inputs "iproute") "/sbin/ip")))
               (substitute* "osdep/ManagedRoute.cpp"
                 (("/sbin/ip") ip)
                 (("/usr/sbin/ip") ip)))
             #t))
         (delete 'configure))))
    (inputs
     `(("iproute" ,iproute)))
    (home-page "https://www.zerotier.com")
    (synopsis "Virtual Ethernet network of almost unlimited size")
    (description "ZeroTier is a smart programmable Ethernet switch for planet
Earth.  It allows networked devices and applications to be managed as if the
entire world is one data center or cloud region.")
    (license license:gpl3+)))
