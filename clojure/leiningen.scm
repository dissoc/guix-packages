;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2015 Eric Dvorsak <eric@dvorsak.fr>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (clojure leiningen)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages java))

(define lein-pkg
  (origin
   (method url-fetch)
   (uri "https://raw.github.com/technomancy/leiningen/2.9.1/bin/lein-pkg")
   (sha256
    (base32
     "1h0gpzpr7xk6hvmrrq41bcp2k9aai348baf8ad9bxvci01n4zb12"))))

(define builder.sh
  (origin
   (method url-fetch)
   (uri "https://raw.githubusercontent.com/NixOS/nixpkgs/0761f81da71fc6a940c7f51129b6c7717db78e87/pkgs/development/tools/build-managers/leiningen/builder.sh")
   (sha256
    (base32
     "10qsz16pnhccwdl34w043kl3c3prkpi1cv4rpzfjfmcqa8kjcny8"))))

(define-public leiningen
  (package
               (name "leiningen")
               (version "2.9.1")
               (source (origin
                        (method url-fetch)
                        ;; supposedly the .zip is actually a .jar but github
                        ;; doesnt allow jar releases or something?
                        ;; i saw that mentioned somewhere but dont recall the source
                        ;; if you java -jar it seems to work so maybe it's true?
                        ;; let me know if you know
                        (uri (string-append
                              "https://github.com/technomancy/leiningen/releases/download/"
                              version "/leiningen-" version "-standalone.zip"))
                        (sha256
                         (base32
                          "1y2mva5s2w2szzn1b9rhz0dvkffls4ravii677ybcf2w9wd86z7a"))))
               (build-system gnu-build-system)
               (arguments
                `(#:tests? #f ; no "check" target
                  #:phases
                  (modify-phases %standard-phases

                                 (replace 'build
                                          (lambda _
                                            (setenv "JAVA_HOME"
                                                    (assoc-ref %build-inputs "icedtea"))
                                            ;; Disable tests to avoid dependency on hamcrest-core, which needs
                                            ;; Ant to build.  This is necessary in addition to disabling the
                                            ;; "check" phase, because the dependency on "test-jar" would always
                                            ;; result in the tests to be run.
                                            (system* "bash" "builder.sh"
                                                     (string-append "-Ddist.dir="
                                                                    (assoc-ref %outputs "out")))))
                                 (delete 'configure)
                                 (delete 'unpack)
                                 (delete 'install))))
               (native-inputs
                `(("builder.sh" ,builder.sh)
                  ("lein-pkg" ,lein-pkg)))
               (inputs
                ;; first is label, second is package and origin
                `(("icedtea" ,icedtea "jdk")))
               (home-page "http://leiningen.org/")
               (synopsis "Project automation for Clojure")
               (description "")
               (license license:epl1.0)))
