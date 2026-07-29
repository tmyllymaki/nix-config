;;; mise-tasks.el --- Mise task runner with Vertico integration -*- lexical-binding: t; -*-

;;; Code:

(require 'json)
(require 'cl-lib)

;;; --- Task discovery ---

(defvar mise-tasks--last-task nil
  "The name of the last mise task that was run.")

(defvar mise-tasks--cache nil
  "Plist (:dir DIR :tasks TASKS :time TIME) caching the last task list.")

(defvar mise-tasks--cache-ttl 5
  "Seconds before the task cache expires.")

(defun mise-tasks--project-root ()
  "Return the project root directory for mise tasks."
  (or (doom-project-root) default-directory))

(defun mise-tasks--fetch ()
  "Fetch tasks from mise CLI as a list of alists.
Results are cached for `mise-tasks--cache-ttl' seconds per directory."
  (let ((dir (mise-tasks--project-root)))
    (if (and mise-tasks--cache
             (equal dir (plist-get mise-tasks--cache :dir))
             (< (- (float-time) (plist-get mise-tasks--cache :time))
                mise-tasks--cache-ttl))
        (plist-get mise-tasks--cache :tasks)
      (let* ((default-directory dir)
             (json-array-type 'list)
             (json-object-type 'alist)
             (json-key-type 'symbol)
             (output (shell-command-to-string
                      (format "%s tasks ls --json 2>/dev/null"
                              (or (bound-and-true-p mise-executable) "mise"))))
             (tasks (condition-case nil
                        (json-read-from-string output)
                      (error nil))))
        (setq mise-tasks--cache
              (list :dir dir :tasks tasks :time (float-time)))
        tasks))))

(defun mise-tasks--candidates ()
  "Return an alist of (NAME . task-alist) for completing-read."
  (let ((tasks (mise-tasks--fetch)))
    (mapcar (lambda (task)
              (cons (alist-get 'name task) task))
            (seq-remove (lambda (task)
                          (eq (alist-get 'hide task) t))
                        tasks))))

;;; --- Marginalia annotator ---

(defun mise-tasks--annotate (name)
  "Marginalia annotation function for mise task NAME."
  (when-let* ((candidates (mise-tasks--candidates))
              (task (cdr (assoc name candidates))))
    (let* ((desc (alist-get 'description task))
           (dir (alist-get 'dir task))
           (deps (alist-get 'depends task))
           (aliases (alist-get 'aliases task))
           (parts nil))
      (when (and aliases (not (seq-empty-p aliases)))
        (push (propertize (format " [%s]" (string-join (append aliases nil) ", "))
                          'face 'marginalia-type)
              parts))
      (when dir
        (push (propertize (format " dir:%s" dir)
                          'face 'marginalia-file-name)
              parts))
      (when (and deps (not (seq-empty-p deps)))
        (push (propertize (format " deps:%d" (length deps))
                          'face 'marginalia-number)
              parts))
      (when (and desc (not (string-empty-p desc)))
        (push (propertize (format "  %s" desc)
                          'face 'marginalia-documentation)
              parts))
      (apply #'concat (nreverse parts)))))

;;; --- Task execution ---

(defun mise-tasks--run (task-name &optional args)
  "Run mise task TASK-NAME with optional ARGS string."
  (let* ((default-directory (mise-tasks--project-root))
         (cmd (concat "mise run " (shell-quote-argument task-name)
                      (when (and args (not (string-empty-p args)))
                        (concat " -- " args))))
         (buf-name (format "*mise:%s*" task-name)))
    (setq mise-tasks--last-task task-name)
    (compilation-start cmd 'compilation-mode
                       (lambda (_mode-name) buf-name))))

(defun mise-tasks--running-buffers ()
  "Return alist of (NAME . buffer) for running mise compilation buffers."
  (let (result)
    (dolist (buf (buffer-list) result)
      (when (and (string-match "^\\*mise:\\(.+\\)\\*$" (buffer-name buf))
                 (get-buffer-process buf))
        (push (cons (match-string 1 (buffer-name buf)) buf) result)))))

;;; --- Interactive commands ---

;;;###autoload
(defun mise-tasks/run (&optional arg)
  "Select and run a mise task with Vertico completion.
With prefix ARG, prompt for additional arguments."
  (interactive "P")
  (let* ((candidates (mise-tasks--candidates))
         (names (mapcar #'car candidates))
         (name (completing-read "Mise task: " names nil t)))
    (if arg
        (let ((args (read-string (format "Args for '%s': " name))))
          (mise-tasks--run name args))
      (mise-tasks--run name))))

;;;###autoload
(defun mise-tasks/rerun ()
  "Re-run the last mise task."
  (interactive)
  (if mise-tasks--last-task
      (mise-tasks--run mise-tasks--last-task)
    (user-error "No previous mise task to re-run")))

;;;###autoload
(defun mise-tasks/stop ()
  "Stop a running mise task.
If only one task is running, stop it immediately.
Otherwise, prompt to select which task to stop."
  (interactive)
  (let ((running (mise-tasks--running-buffers)))
    (cond
     ((null running)
      (user-error "No mise tasks are running"))
     ((= (length running) 1)
      (let* ((entry (car running))
             (proc (get-buffer-process (cdr entry))))
        (kill-process proc)
        (message "Stopped mise task: %s" (car entry))))
     (t
      (let* ((name (completing-read "Stop mise task: "
                                    (mapcar #'car running) nil t))
             (buf (cdr (assoc name running)))
             (proc (get-buffer-process buf)))
        (kill-process proc)
        (message "Stopped mise task: %s" name))))))

(provide 'mise-tasks)
;;; mise-tasks.el ends here
