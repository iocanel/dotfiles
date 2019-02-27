;;; quickmarks.el --- Quickmarks



;; Author: Ioannis Canellos

;; Version: 0.0.1

;; Package-Requires: ((emacs "25.1"))

;;; Commentary:

;;; Code:

(defvar quickmarks-alist '() "A list of labeled links for quick access")
(setq quickmarks-alist '(
                         ;; emacs
                         (markdown . https://en.wikipedia.org/wiki/Markdown)
                         (org-mode . https://orgmode.org)
                         (emacs . http://emacs.org)
                         (spacemacs . http://spacemacs.org)
                         (yasnippets . https://github.com/joaotavora/yasnippet)
                         ;; linux
                         (archlinux . https://archlinux.org)
                         (dotfiles . https://github.com/iocanel/dotfiles)
                         (i3 . https://i3wm.org)
                         (mutt . http://www.mutt.org)
                         (weechat . https://weechat.org)
                         (qutebrowser . https://qutebrowser.org)
                         (ranger . https://github.com/ranger/ranger)
                         ;; work
                         (ap4k . https://github.com/ap4k/ap4k)
                         (arquillian-cube . https://github.com/arquillian/arquillian-cube)
                         (dagger . https://github.com/square/dagger)
                         (docker . https://docker.io)
                         (fabric8 . https://fabric8.io)
                         (fabric8\ maven\ plugin . https://maven.fabric8.io)
                         (fabric8-maven-plugin . https://maven.fabric8.io)
                         (gradle . https://gradle.org)
                         (grails . https://grails.org)
                         (grafana . https://grafana.com)
                         (istio . https://istio.io)
                         (kotlin . https://kotlinlang.org)
                         (kubernetes . https://kubernetes.io)
                         (metaparticle . https://metaparticle.io)
                         (maven . https://maven.apache.org)
                         (microsoft\ sql\ server . https://www.microsoft.com/en-us/sql-server/sql-server-2017)
                         (micronaut . http://micronaut.io)
                         (openshift . https://openshift.com)
                         (open\ service\ broker\ api . https://www.openservicebrokerapi.org)
                         (prometheus . https://prometheus.io)
                         (prometheus\ operator . https://github.com/coreos/prometheus-operator)
                         (service\ catalog . https://svc-cat.io)
                         (service\ catalog\ connector . https://github.com/snowdrop/servicecatalog-connector)
                         (sdkman . https://sdkman.io)
                         (snowdrop . https://snowdrop.me)
                         (spring . https://spring.io)
                         (spring\ cloud . https://cloud.spring.io)
                         (spring\ boot . https://spring.io/projects/spring-boot)
                         (spring\ cloud\ connectors . https://cloud.spring.io/spring-cloud-connectors)
                         (spring\ data . https://projects.spring.io/spring-data/)
                         (thorntail . https://thorntail.io)
                         (jenkins . https://jenkins.io)
                         ;; kubernetes/openshift resources
                         (DeploymentConfig . https://docs.openshift.com/enterprise/3.0/dev_guide/deployments.html)
                         (Route . https://docs.openshift.com/enterprise/3.0/dev_guide/routes.html)
                         ;; People
                         (Brendand\ Burns . https://twitter.com/brendandburns)
                         (Rolland\ Huss . https://ro14nd.de/about)
                         )
      )

(defun quickmarks-get (k)
  "Get the value of the quickmark with the key K."
  (alist-get (intern k) quickmarks-alist)
  )

(provide 'quickmarks)
;;; quickmarks.el ends here
