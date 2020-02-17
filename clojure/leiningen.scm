(define-module (clojure leiningen)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system trivial)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages java))


;; (define lein-pkg
;;   (origin
;;    (method url-fetch)
;;    (uri "https://raw.github.com/technomancy/leiningen/2.9.1/bin/lein-pkg")
;;    (sha256
;;     (base32
;;      "1h0gpzpr7xk6hvmrrq41bcp2k9aai348baf8ad9bxvci01n4zb12"))))


;; (define builder.sh
;;   (origin
;;    (method url-fetch)
;;    (uri "https://raw.githubusercontent.com/NixOS/nixpkgs/0761f81da71fc6a940c7f51129b6c7717db78e87/pkgs/development/tools/build-managers/leiningen/builder.sh")
;;    (sha256
;;     (base32
;;      "10qsz16pnhccwdl34w043kl3c3prkpi1cv4rpzfjfmcqa8kjcny8"))))


;; (package
;;  (name "leiningen")
;;  (version "2.9.1")
;;  (source (origin
;;           (method url-fetch)
;;           ;; supposedly the .zip is actually a .jar but github
;;           ;; doesnt allow jar releases or something?
;;           ;; i saw that mentioned somewhere but dont recall the source
;;           ;; if you java -jar it seems to work so maybe it's true?
;;           ;; let me know if you know
;;           (uri (string-append
;;                 "https://github.com/technomancy/leiningen/releases/download/"
;;                 version "/leiningen-" version "-standalone.zip"))
;;           (sha256
;;            (base32
;;             "1y2mva5s2w2szzn1b9rhz0dvkffls4ravii677ybcf2w9wd86z7a"))))
;;  (build-system gnu-build-system)
;;  (arguments
;;   `(#:tests? #f ; no "check" target
;;     #:phases
;;     (modify-phases %standard-phases

;;                    (replace 'build
;;                             (lambda* (#:key inputs outputs #:allow-other-keys)
;;                               (setenv "JAVA_HOME"
;;                                       (assoc-ref inputs "icedtea"))
;;                               ;; Disable tests to avoid dependency on hamcrest-core, which needs
;;                               ;; Ant to build.  This is necessary in addition to disabling the
;;                               ;; "check" phase, because the dependency on "test-jar" would always
;;                               ;; result in the tests to be run.
;;                               (invoke "bash" "builder.sh"
;;                                       (string-append "-Ddist.dir="
;;                                                      (assoc-ref outputs "out")))))
;;                    (delete 'configure)
;;                    (delete 'unpack)
;;                    (delete 'install))))
;;  (native-inputs
;;   `(("builder.sh" ,builder.sh)
;;     ("lein-pkg" ,lein-pkg)))
;;  (inputs
;;   ;; first is label, second is package and origin
;;   `(("jdk" ,icedtea-8 "jdk")))
;;  (home-page "http://leiningen.org/")
;;  (synopsis "Project automation for Clojure")
;;  (description "")
;;  (license license:epl1.0))

;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2019 Pierre Neidhardt <mail@ambrevar.xyz>
;;; Copyright © 2020 Jelle Licht <jlicht@fsfe.org>
;;;
;;; This file is not part of GNU Guix.
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

;; This is a hidden package, as it does not really serve a purpose on its own.
(define leiningen-jar
  (package
   (name "leiningen-jar")
   (version "2.9.1")
   (source (origin
            (method url-fetch)
            (uri (string-append "https://github.com/technomancy/leiningen/releases/download/"
                                version "/leiningen-2.9.1-standalone.zip"))
            (file-name "leiningen-standalone.jar")
            (sha256
             (base32
              "1y2mva5s2w2szzn1b9rhz0dvkffls4ravii677ybcf2w9wd86z7a"))))
   (build-system trivial-build-system)
   (arguments
    `(#:modules ((guix build utils))
      #:builder (begin
                  (use-modules (guix build utils))
                  (let ((source (assoc-ref %build-inputs "source"))
                        (jar-dir (string-append %output "/share/")))
                    (mkdir-p jar-dir)
                    (copy-file source
                               (string-append jar-dir "leiningen-standalone.jar"))))))
   (home-page "https://leiningen.org")
   (synopsis "Automate Clojure projects without setting your hair on fire")
   (description "Leiningen is a Clojure tool with a focus on project
automation and declarative configuration.  It gets out of your way and
lets you focus on your code.")
   (license license:epl1.0)))

(define-public leiningen
  (package
   (inherit leiningen-jar)
   (name "leiningen")
   (version "2.9.1")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/technomancy/leiningen.git")
                  (commit version)))
            (file-name (git-file-name name version))
            (sha256
             (base32
              "0qv9vp6ypdilwv818fpwknr9sj40sz2vdcqxbd42m1l0ljjggiy1"))))
   (build-system gnu-build-system)
   (arguments
    `(#:tests? #f
      #:phases (modify-phases %standard-phases
                              (delete 'configure)
                              (delete 'build)
                              (replace 'install
                                       (lambda _
                                         (let* ((lein-pkg (string-append (assoc-ref %build-inputs "source") "/bin/lein-pkg"))
                                                (lein-jar (string-append (assoc-ref  %build-inputs "leiningen-jar")
                                                                         "/share/leiningen-standalone.jar"))
                                                (bin-dir (string-append %output "/bin"))
                                                (lein (string-append bin-dir "/lein")))
                                           (mkdir-p bin-dir)
                                           (copy-file lein-pkg lein)
                                           (patch-shebang lein)
                                           (chmod lein #o555)
                                           (substitute* lein
                                                        (("LEIN_JAR=.*") (string-append "LEIN_JAR=" lein-jar)))
                                           #t))))))
   (inputs
    `(("leiningen-jar" ,leiningen-jar)))))
