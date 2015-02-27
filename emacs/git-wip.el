(add-to-list 'exec-path "~/git-wip")

(defun git-wip-wrapper ()
  (interactive)
  (let* ((file-name (buffer-file-name))
         (msg (format "[%s] WIP from emacs: %s"
                      (format-time-string "%Y-%m-%d %T") file-name)))
    (start-process "git-wip" nil "git-wip"
                   "save" msg "--editor" "--" file-name)
    (message (format "Wrote and git-wip'd %s." file-name))))

(defun git-wip-if-git ()
  (interactive)
  (when (string= (vc-backend (buffer-file-name)) "Git")
    (git-wip-wrapper)))

(add-hook 'after-save-hook 'git-wip-if-git)
