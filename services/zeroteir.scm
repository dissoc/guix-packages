(define-module (services zeroteir)
  ;;#:use-module (vpn zerotier)
  )



;; (define (zerotier-shepherd-service)
;;   (lambda ()
;;     (let* ((log-file "/var/log/zerotier.log")
;;            (zerotier-package (package zerotier-one)))
;;       (list (shepherd-service
;;              (documentation "Run zerotier service")
;;              (provision '(zerotier-one))
;;              (requirement '(networking))
;;              (start #~(make-forkexec-constructor
;;                        (list (string-append #$zerotier-package "/sbin/zerotier-one"))))
;;              (stop #~(make-kill-destructor)))))))

;; (define %zerotier-accounts
;;   (list (user-group (name "zerotier") (system? #t))
;;         (user-account
;;          (name "zerotier")
;;          (group "zerotier")
;;          (system? #t)
;;          (comment "zerotier daemon user")
;;          (home-directory "/var/empty")
;;          (shell (file-append shadow "/sbin/nologin")))))


;; ;; maybe dont need
;; (define %zerotier-activation
;;   #~(begin
;;       (use-modules (guix build utils))
;;       (mkdir-p "/var/run/zerotier")))

;; (define zerotier-service-type
;;   (service-type (name 'zerotier-client)
;;                 (extensions
;;                  (list (service-extension shepherd-root-service-type
;;                                           (zerotier-shepherd-service))
;;                        (service-extension account-service-type
;;                                           (const %zerotier-accounts))
;;                        (service-extension activation-service-type
;;                                           (const %zerotier-activation))))))
