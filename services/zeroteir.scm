(define-module (services zeroteir)
  #:use-module (vpn zerotier)
  #:use-module (guix gexp)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services)
  #:use-module (guix packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu system shadow)
  #:export (zerotier-service-type))



(define (zerotier-shepherd-service)
  (lambda (config)
    (let* ((log-file "/var/log/zerotier.log")
           ;;(zerotier-package (package zerotier-one))
           )
      (list (shepherd-service
             (documentation "Run zerotier service")
             (provision '(zerotier-one))
             (requirement '(networking))
             (start #~(make-forkexec-constructor
                       (list (string-append
                              (package zerotier-one)
                              ;;#$zerotier-package
                              "/sbin/zerotier-one"))))
             (stop #~(make-kill-destructor)))))))


(define %zerotier-accounts
  (list (user-group (name "zerotier")
                    (system? #t))
        (user-account
         (name "zerotier")
         (group "zerotier")
         (system? #t)
         (comment "zerotier daemon user")
         (home-directory "/var/empty")
         (shell (file-append shadow "/sbin/nologin")))))


;; maybe dont need
(define %zerotier-activation
  #~(begin
      (use-modules (guix build utils))
      (mkdir-p "/var/run/zerotier")))

(define zerotier-service-type
  (service-type (name 'zerotier-client)
                (extensions
                 (list (service-extension shepherd-root-service-type
                                          (zerotier-shepherd-service))
                       (service-extension account-service-type
                                          (const %zerotier-accounts))
                       (service-extension activation-service-type
                                          (const %zerotier-activation))))))
