(use-modules (guix packages)
             (guix download)
             (guix build-system gnu)
             (guix licenses))

(package
 (name "leiningen")
 (version "2.9.1")
 (source (origin
          (method url-fetch)
          (uri (string-append
                "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein"))
          (sha256
           (base32
            "32acacc8354627724d27231bed8fa190d7df0356972e2fd44ca144c084ad4fc7"))))
 (build-system trivial-build-system)
(arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let ((source (assoc-ref %build-inputs "source"))
               (out    (assoc-ref %outputs "out")))
           (mkdir-p (string-append out "/bin/"))
           (copy-file (string-append source "/screenfetch-dev")
                      (string-append out "/bin/screenfetch"))
           (install-file (string-append source "/screenfetch.1")
                         (string-append out "/man/man1/"))
           (install-file (string-append source "/COPYING")
                         (string-append out "/share/doc/" ,name "-" ,version))
           (substitute* (string-append out "/bin/screenfetch")
             (("/usr/bin/env bash")
              (string-append (assoc-ref %build-inputs "bash")
                             "/bin/bash")))
           (wrap-program
               (string-append out "/bin/screenfetch")
             `("PATH" ":" prefix
               (,(string-append (assoc-ref %build-inputs "bc") "/bin:"
                                (assoc-ref %build-inputs "scrot") "/bin:"
                                (assoc-ref %build-inputs "xdpyinfo") "/bin"
                                (assoc-ref %build-inputs "xprop") "/bin"))))
           (substitute* (string-append out "/bin/screenfetch")
             (("#!#f")
              (string-append "#!" (assoc-ref %build-inputs "bash")
                             "/bin/bash")))))))
 (synopsis "Hello, Guix world: An example custom Guix package")
 (description
  "GNU Hello prints the message \"Hello, world!\" and then exits.  It
serves as an example of standard GNU coding practices.  As such, it supports
command-line arguments, multiple languages, and so on.")
 (home-page "https://www.gnu.org/software/hello/")
 (license gpl3+))
