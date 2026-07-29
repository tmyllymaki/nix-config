;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
;;
(setq doom-font (font-spec :family "IoskeleyMono Nerd Font SemiCondensed Medium" :size 15))

(face-attribute 'default :font)


;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq projectile-switch-project-action #'projectile-vc)
(setq +workspaces-switch-project-function #'projectile-vc)
(setq insert-directory-program "gls")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;; --- Roslyn LSP for C# / Razor ---

(add-load-path! "lisp")

;; .NET project detection: find project root by looking for .sln/.slnx upward
;; This prevents eglot from starting separate servers for subdirectories
(defun roslyn--project-try-dotnet (dir)
  "Find .NET project root by locating .sln/.slnx files above DIR."
  (when-let* ((root (locate-dominating-file
                     dir
                     (lambda (d)
                       (directory-files d nil "\\.slnx?\\'" t)))))
    (cons 'transient root)))
(add-hook 'project-find-functions #'roslyn--project-try-dotnet)

;; Tree-sitter grammar source for Razor
(after! treesit
  (add-to-list 'treesit-language-source-alist
               '(razor "https://github.com/tris203/tree-sitter-razor"))
  (add-to-list 'treesit-language-source-alist
               '(html "https://github.com/tree-sitter/tree-sitter-html")))

;; razor-ts-mode: tree-sitter mode for .razor files
(require 'razor-ts-mode)
(add-to-list 'auto-mode-alist '("\\.razor\\'" . razor-ts-mode))

;; Ensure eglot attaches to razor buffers (Doom only hooks csharp-mode)
(add-hook 'razor-ts-mode-hook #'eglot-ensure)

(after! eglot
  (require 'roslyn-razor)

  ;; --- Server class ---
  (defclass eglot-roslyn (eglot-lsp-server) ()
    :documentation "Roslyn Language Server for C# and Razor.")

  ;; --- Paths ---
  ;; Use the globally-installed `roslyn-language-server' dotnet tool
  ;; (`dotnet tool install -g roslyn-language-server'). It is a native launcher
  ;; for Microsoft.CodeAnalysis.LanguageServer.
  (defvar roslyn--server-exe
    (or (executable-find "roslyn-language-server")
        (expand-file-name "~/.dotnet/tools/roslyn-language-server"))
    "Path to the roslyn-language-server executable.")

  ;; --- Server command ---
  (defun roslyn--build-command ()
    "Build the command to start the Roslyn language server.

Do NOT add `--extension .../Microsoft.VisualStudioCode.RazorExtension.dll'.
The server auto-loads that extension from its own base directory (see
`LanguageServerExportProviderBuilder.CreateExportProviderAsync'). Passing it
explicitly double-loads Razor in a separate assembly-load context and breaks
the Razor source generator wiring with the error \"Razor source generator is
not referenced or no run result found for project ...\". This matches how
roslyn.nvim launches the server (just `--stdio')."
    (let ((log-dir (expand-file-name "roslyn" temporary-file-directory)))
      (unless (file-directory-p log-dir)
        (make-directory log-dir t))
      `(,roslyn--server-exe
        "--logLevel=Information"
        ,(concat "--extensionLogDirectory=" log-dir)
        "--stdio")))

  ;; --- Register server for C# and Razor modes ---
  ;; Function contact: eglot calls this when starting the server.
  ;; Returns (CLASS-NAME PROGRAM ARGS...) for custom server class.
  (add-to-list 'eglot-server-programs
               `((csharp-mode csharp-ts-mode razor-ts-mode)
                 . ,(lambda (_interactive)
                      (cons 'eglot-roslyn (roslyn--build-command)))))

  ;; --- Workspace settings (matching neovim config) ---
  ;; Uses string-keyed alist for pipe-separated section names
  (cl-defmethod eglot-workspace-configuration ((_server eglot-roslyn))
    "Return workspace settings for the Roslyn server."
    `(("csharp|completion"
       . (:dotnet_provide_regex_completions t
          :dotnet_show_name_completion_suggestions t
          :dotnet_show_completion_items_from_unimported_namespaces t))
      ("csharp|code_lens"
       . (:dotnet_enable_references_code_lens t))
      ("csharp|formatting"
       . (:dotnet_organize_imports_on_format t))
      ("csharp|background_analysis"
       . (:dotnet_analyzer_diagnostics_scope "fullSolution"
          :dotnet_compiler_diagnostics_scope "fullSolution"))
      ("csharp|inlay_hints"
       . (:csharp_enable_inlay_hints_for_implicit_object_creation t
          :csharp_enable_inlay_hints_for_implicit_variable_types t
          :csharp_enable_inlay_hints_for_lambda_parameter_types t
          :csharp_enable_inlay_hints_for_types t
          :dotnet_enable_inlay_hints_for_indexer_parameters t
          :dotnet_enable_inlay_hints_for_literal_parameters t
          :dotnet_enable_inlay_hints_for_object_creation_parameters t
          :dotnet_enable_inlay_hints_for_other_parameters t
          :dotnet_enable_inlay_hints_for_parameters t
          :dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix t
          :dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name t
          :dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent t))
      ("razor"
       . (:language_server (:cohosting_enabled t)))))

  ;; --- Solution/project discovery ---
  (defun roslyn--find-solutions (root)
    "Find .sln and .slnx files under ROOT directory (non-recursive)."
    (let ((files nil))
      (dolist (ext '("*.sln" "*.slnx"))
        (setq files (append files (file-expand-wildcards
                                   (expand-file-name ext root)))))
      files))

  (defun roslyn--find-csproj-files (root)
    "Find .csproj files under ROOT recursively."
    (directory-files-recursively root "\\.csproj\\'"))

  (defun roslyn--uri-from-path (path)
    "Convert file PATH to a file:// URI."
    (concat "file://" (expand-file-name path)))

  (defun roslyn--open-solution-or-project (server)
    "Send solution/open or project/open to the Roslyn SERVER."
    (when-let* ((root (project-root (eglot--project server))))
      (let ((solutions (roslyn--find-solutions root)))
        (cond
         ;; Single solution found
         ((= (length solutions) 1)
          (let ((sln (car solutions)))
            (jsonrpc-notify server :solution/open
                           `(:solution ,(roslyn--uri-from-path sln)))
            (message "[Roslyn] Opened solution: %s" (file-name-nondirectory sln))))
         ;; Multiple solutions - prompt user
         ((> (length solutions) 1)
          (let* ((choices (mapcar #'file-name-nondirectory solutions))
                 (choice (completing-read "Select solution: " choices nil t))
                 (sln (seq-find (lambda (s) (string= (file-name-nondirectory s) choice))
                                solutions)))
            (when sln
              (jsonrpc-notify server :solution/open
                             `(:solution ,(roslyn--uri-from-path sln)))
              (message "[Roslyn] Opened solution: %s" choice))))
         ;; No solutions - try csproj files
         (t
          (let ((projects (roslyn--find-csproj-files root)))
            (when projects
              (jsonrpc-notify server :project/open
                             `(:projects ,(vconcat
                                          (mapcar #'roslyn--uri-from-path projects))))
              (message "[Roslyn] Opened %d project(s)" (length projects)))))))))

  ;; Send solution/open once per server on connect
  (add-hook 'eglot-connect-hook
            (lambda (server)
              (when (eglot-roslyn-p server)
                (roslyn--open-solution-or-project server))))

  ;; --- Pull diagnostics support ---
  ;; Roslyn uses dynamic registration for textDocument/diagnostic.
  ;; When it registers this capability, inject :diagnosticProvider into
  ;; the server's capabilities so eglot's built-in pull diagnostics activate.
  ;; Also re-enable pull in flycheck-eglot buffers (it checks capabilities
  ;; at setup time before Roslyn sends the dynamic registration).
  (cl-defmethod eglot-register-capability
    ((server eglot-roslyn) (_method (eql textDocument/diagnostic)) _id &rest _params)
    (setf (eglot--capabilities server)
          (plist-put (eglot--capabilities server) :diagnosticProvider t))
    (message "[Roslyn] Registered pull diagnostics")
    ;; Re-enable pull diagnostics in flycheck-eglot buffers
    (dolist (buf (eglot--managed-buffers server))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (when (boundp 'flycheck-eglot--can-run-flymake-backend-p)
            (setq flycheck-eglot--can-run-flymake-backend-p t))))))

  (defun roslyn--refresh-diagnostics (server)
    "Force-enable pull diagnostics for SERVER, then refresh all its buffers.
Roslyn registers `textDocument/diagnostic' dynamically, *after* flycheck-eglot
has already decided at buffer-setup time that the server cannot pull -- which
latches `flycheck-eglot--can-run-flymake-backend-p' off for that buffer and
leaves diagnostics permanently disabled.  Rather than depend on catching that
late registration, unconditionally re-assert `:diagnosticProvider', re-arm the
flycheck-eglot pull flag, and re-run the checker.  Called on
`workspace/projectInitializationComplete' (always fires after the solution is
loaded) and on the server's `workspace/diagnostic/refresh' requests."
    (setf (eglot--capabilities server)
          (plist-put (eglot--capabilities server) :diagnosticProvider t))
    (dolist (buf (eglot--managed-buffers server))
      (when (buffer-live-p buf)
        (with-current-buffer buf
          (when (boundp 'flycheck-eglot--can-run-flymake-backend-p)
            (setq flycheck-eglot--can-run-flymake-backend-p t))
          (cond
           ((bound-and-true-p flycheck-mode)
            (flycheck-buffer))
           ((bound-and-true-p flymake-mode)
            (flymake-start)))))))

  ;; --- Handle server notifications ---

  ;; workspace/projectInitializationComplete
  (cl-defmethod eglot-handle-notification
    ((server eglot-roslyn) (_method (eql workspace/projectInitializationComplete)) &rest _params)
    (message "[Roslyn] Project initialization complete")
    ;; Refresh diagnostics in all open buffers (like roslyn.nvim does)
    (run-with-timer 0.5 nil #'roslyn--refresh-diagnostics server))

  ;; workspace/diagnostics/refresh - Roslyn asks us to re-pull diagnostics
  (cl-defmethod eglot-handle-request
    ((server eglot-roslyn) (_method (eql workspace/diagnostic/refresh)) &rest _params)
    (roslyn--refresh-diagnostics server)
    nil)

  ;; razor/updateHtml - forward to razor cohosting
  ;; Handle as BOTH notification and request (Roslyn may send either way)
  (cl-defmethod eglot-handle-notification
    ((server eglot-roslyn) (_method (eql razor/updateHtml)) &rest params)
    (roslyn-razor--handle-update-html server params))

  (cl-defmethod eglot-handle-request
    ((server eglot-roslyn) (_method (eql razor/updateHtml)) &rest params)
    (roslyn-razor--handle-update-html server params)
    nil)

  ;; razor/log - handle as both notification and request
  (cl-defmethod eglot-handle-notification
    ((server eglot-roslyn) (_method (eql razor/log)) &rest params)
    (roslyn-razor--handle-log server params))

  (cl-defmethod eglot-handle-request
    ((server eglot-roslyn) (_method (eql razor/log)) &rest params)
    (roslyn-razor--handle-log server params)
    t)

  ;; --- Handle server->client requests (razor forwarding) ---
  ;; Roslyn sends these as requests (expecting a response) for razor files.
  ;; The payload has {textDocument, checksum, request} - we forward `request` to HTML LS.

  (defmacro roslyn--define-razor-request-handler (method-symbol)
    "Define an eglot-handle-request method for METHOD-SYMBOL on eglot-roslyn.
If the request has razor forwarding fields, forward to HTML LS.
Otherwise return a safe empty response.
PARAMS from eglot is a plist (JSON object spread via apply).
Return nil for JSON null, (vector) for JSON []."
    (let ((method-string (symbol-name method-symbol)))
      `(cl-defmethod eglot-handle-request
         ((_server eglot-roslyn) (_method (eql ,method-symbol)) &rest params)
         (let* ((td (plist-get params :textDocument))
                (checksum (plist-get params :checksum))
                (inner-request (plist-get params :request)))
           (if (and td checksum inner-request)
               ;; Razor forwarded request
               (let* ((uri (plist-get td :uri))
                      (virtual-uri (roslyn-razor--virtual-uri uri))
                      (doc (gethash virtual-uri roslyn-razor--documents)))
                 (cond
                  ((null doc)
                   (message "[Razor] No document stored for %s (request: %s)" uri ,method-string)
                   nil)
                  ((not (equal (plist-get doc :checksum) checksum))
                   (message "[Razor] Checksum mismatch for %s on %s (have: %s, want: %s)"
                            ,method-string uri (plist-get doc :checksum) checksum)
                   nil)
                  (t
                   (roslyn-razor--forward-to-html ,method-string inner-request))))
             ;; Not a razor forwarded request
             nil)))))

  (roslyn--define-razor-request-handler textDocument/hover)
  (roslyn--define-razor-request-handler textDocument/completion)
  (roslyn--define-razor-request-handler textDocument/references)
  (roslyn--define-razor-request-handler textDocument/definition)
  (roslyn--define-razor-request-handler textDocument/implementation)
  (roslyn--define-razor-request-handler textDocument/signatureHelp)
  (roslyn--define-razor-request-handler textDocument/formatting)
  (roslyn--define-razor-request-handler textDocument/onTypeFormatting)
  (roslyn--define-razor-request-handler textDocument/foldingRange)
  (roslyn--define-razor-request-handler textDocument/documentColor)
  (roslyn--define-razor-request-handler textDocument/colorPresentation)
  (roslyn--define-razor-request-handler textDocument/documentHighlight)

  ;; --- Disable eglot file watching for Roslyn ---
  ;; Roslyn does its own file watching; eglot's watchers exhaust macOS
  ;; file descriptors on large projects (file-notify-error "no fd left").
  (cl-defmethod eglot-register-capability
    ((_server eglot-roslyn) (_method (eql workspace/didChangeWatchedFiles)) _id &rest _params)
    (message "[Roslyn] Ignoring file watch registration (Roslyn handles its own)"))

  ;; --- Capabilities ---
  (cl-defmethod eglot-initialization-options ((_server eglot-roslyn))
    "Return initialization options for Roslyn."
    nil)

  (cl-defmethod eglot-client-capabilities :around ((_server eglot-roslyn))
    "Augment client capabilities for Roslyn."
    (let ((caps (cl-call-next-method)))
      ;; Roslyn needs dynamicRegistration for diagnostics
      (let* ((td (plist-get caps :textDocument))
             (diag (or (plist-get td :diagnostic) '())))
        (setq diag (plist-put diag :dynamicRegistration t))
        (setq td (plist-put td :diagnostic diag))
        (setq caps (plist-put caps :textDocument td)))
      caps))

  ;; --- Shutdown: clean up HTML LS when Roslyn stops ---
  (advice-add 'eglot-shutdown :before
              (lambda (server &rest _args)
                (when (eglot-roslyn-p server)
                  (roslyn-razor--shutdown))))

  ;; --- Fix TMPDIR for macOS (decompiled files navigation) ---
  (when (eq system-type 'darwin)
    (let ((tmpdir (getenv "TMPDIR")))
      (when tmpdir
        (setenv "TMPDIR" (file-truename tmpdir)))))

  ;; Ensure Configuration env var for Roslyn
  (unless (getenv "Configuration")
    (setenv "Configuration" "Debug")))

;;; --- Popup Terminal (ghostel) ---

;; vterm kept as a fallback; reach it via M-x +vterm/toggle.
(after! vterm
  (setq vterm-shell "/opt/homebrew/bin/fish")
  (set-popup-rule! "^\\*doom:vterm" :side 'bottom :size 0.4 :select t
    :quit nil :ttl nil :modeline t))

(defun +ghostel/toggle ()
  "Toggle a project-scoped ghostel terminal popup.
Inside a project each project gets its own terminal buffer; outside a
project a single global terminal is used.  If the terminal is visible,
hide its window; if it exists but is hidden, show it; otherwise create
a new one (in the project root when inside a project)."
  (interactive)
  (require 'ghostel)
  (if (project-current nil)
      (let* ((bufs (ghostel--project-buffers))
             (win  (seq-some #'get-buffer-window bufs)))
        (cond (win  (delete-window win))
              (bufs (pop-to-buffer (car bufs)))
              (t    (ghostel-project))))
    (let* ((buf (ghostel--find-buffer-by-identity ghostel-buffer-name))
           (win (and buf (get-buffer-window buf))))
      (cond (win (delete-window win))
            (buf (pop-to-buffer buf))
            (t   (ghostel))))))

(use-package! ghostel
  :defer t
  ;; NB: do NOT list +ghostel/toggle here — :commands would create an
  ;; autoload stub that clobbers the defun above (it lives in this file,
  ;; not in the ghostel package).
  :commands (ghostel ghostel-project ghostel-other)
  :init
  (setq ghostel-shell "/opt/homebrew/bin/fish")
  ;; Keep stable buffer names (*ghostel*, *<project>-ghostel*) so the popup
  ;; rule keeps matching after the shell sets a window title.  Set back to
  ;; #'ghostel-buffer-name-by-title to restore dynamic title-based names.
  (setq ghostel-buffer-name-function nil)
  :config
  ;; Matches both the global *ghostel* and per-project *<proj>-ghostel*.
  (set-popup-rule! "ghostel\\*$" :side 'bottom :size 0.4 :select t
    :quit nil :ttl nil :modeline t)
  ;; Bind C-' in the real keymaps (not via evil state) so it toggles from
  ;; every input mode and evil state without first leaving the terminal's
  ;; input state.  ghostel never sends C-' to the terminal, so this is safe.
  ;; The base map is inherited by semi-char/emacs/line/readonly modes; char
  ;; mode has no parent, so bind it explicitly.
  (define-key ghostel-mode-map      (kbd "C-'") #'+ghostel/toggle)
  (define-key ghostel-char-mode-map (kbd "C-'") #'+ghostel/toggle))

;; Evil integration: ghostel buffers start in insert state, and insert-state
;; readline Ctrl keys (C-w word-erase, C-u, C-r, C-a, C-e, C-k, ...) are
;; forwarded to the terminal via an evil aux keymap instead of being eaten by
;; evil's window-map / insert-state editing commands.  ESC is 'auto: sent to
;; the terminal when a full-screen TUI (nvim/htop/less) owns the screen,
;; otherwise it switches to normal state for cursor-synced navigation.
(use-package! evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

;; Global C-' toggle across all Evil states
(map! :n "C-'" #'+ghostel/toggle
      :i "C-'" #'+ghostel/toggle
      :v "C-'" #'+ghostel/toggle)

;;; --- Agent Shell (Claude Code) ---
;; NOTE: agent-shell config preserved as fallback. Replaced by claude-code-ide.
;; To restore: uncomment this section and rebind C-, to +agent-shell/toggle

;; (defun +agent-shell/toggle ()
;;   "Toggle agent-shell popup for the current project. Create if none exists."
;;   (interactive)
;;   (require 'agent-shell)
;;   (let ((project (agent-shell--project-name)))
;;     (if-let* ((buf (seq-find
;;                     (lambda (b)
;;                       (and (with-current-buffer b
;;                              (derived-mode-p 'agent-shell-mode))
;;                            (string-match-p (regexp-quote project)
;;                                            (buffer-name b))))
;;                     (buffer-list))))
;;         (if-let* ((win (get-buffer-window buf t)))
;;             (if (+popup-window-p win)
;;                 (+popup/close win t)
;;               (delete-window win))
;;           (pop-to-buffer buf))
;;       (agent-shell))))

;; (defun +agent-shell/load-session ()
;;   "Start agent-shell and load a previous session with full conversation history."
;;   (interactive)
;;   (let ((agent-shell-session-strategy 'prompt)
;;         (agent-shell-prefer-session-resume nil))
;;     (agent-shell)))

;; (use-package! agent-shell
;;   :defer t
;;   :commands (agent-shell agent-shell-toggle)
;;   :init
;;   (setq agent-shell-session-strategy 'prompt)
;;   (setq agent-shell-preferred-agent-config 'claude-code)
;;   (setq agent-shell-anthropic-claude-acp-command '("claude-agent-acp"))
;;   (setq agent-shell-prefer-viewport-interaction nil)
;;   (setq agent-shell-display-action nil)
;;
;;   :config
;;   (require 'acp)
;;   (require 'agent-shell)
;;   (setq agent-shell-anthropic-authentication
;;      (agent-shell-anthropic-make-authentication :login t))
;;
;;   (set-popup-rule! "^\\*Claude Code"
;;     :side 'bottom :size 0.4 :select t
;;     :quit nil :ttl nil :modeline t)
;;
;;   (add-hook 'agent-shell-mode-hook #'evil-insert-state)
;;
;;   (evil-define-key 'insert agent-shell-mode-map
;;     (kbd "S-<return>") #'newline
;;     (kbd "RET")        #'shell-maker-submit
;;     (kbd "s-v")        #'yank
;;     (kbd "C-v")        #'agent-shell-yank-dwim
;;     (kbd "C-,")        #'+agent-shell/toggle
;;     (kbd "<backtab>")  #'agent-shell-cycle-session-mode)
;;
;;   (evil-define-key 'normal agent-shell-mode-map
;;     (kbd "RET") #'shell-maker-submit
;;     (kbd "C-,") #'+agent-shell/toggle
;;     (kbd "<backtab>") #'agent-shell-cycle-session-mode
;;     "n" #'evil-search-next
;;     "p" #'evil-paste-after
;;     "i" (lambda () (interactive) (goto-char (point-max)) (evil-insert-state))
;;     "A" (lambda () (interactive) (goto-char (point-max)) (evil-append 1))
;;     "]s" #'agent-shell-next-item
;;     "[s" #'agent-shell-previous-item))

;; Global C-, toggle across all Evil states — now uses claude-code-ide
(defun claude-code-ide-open-or-toggle ()
  "Toggle claude-code-ide window, starting a new session if none exists."
  (interactive)
  (require 'claude-code-ide)
  (let ((buffer-name (claude-code-ide--get-buffer-name)))
    (if (get-buffer buffer-name)
        (claude-code-ide-toggle)
      (claude-code-ide))))
(map! :n "C-," #'claude-code-ide-open-or-toggle
      :i "C-," #'claude-code-ide-open-or-toggle
      :v "C-," #'claude-code-ide-open-or-toggle)

;;; --- Custom Keybindings ---

(map! :leader
      :desc "Explorer (dirvish)" "e" #'dired-jump)

(require 'mise)
(add-hook 'after-init-hook #'global-mise-mode)

;;; --- Mise Task Runner ---

(require 'mise-tasks)

(after! marginalia
  (add-to-list 'marginalia-command-categories '(mise-tasks/run . mise-task))
  (add-to-list 'marginalia-annotators '(mise-task mise-tasks--annotate builtin none)))

(set-popup-rule! "^\\*mise:" :side 'bottom :size 0.35 :select t :quit 'current :ttl nil)

(map! :leader
      (:prefix ("c" . "code")
       :desc "Mise run task"   "m" #'mise-tasks/run
       :desc "Mise rerun last" "M" #'mise-tasks/rerun
       :desc "Mise stop task"  "x" #'mise-tasks/stop))

(add-hook! (toml-ts-mode conf-toml-mode)
  (when (and buffer-file-name (string-match-p "mise\\.toml\\'" buffer-file-name))
    (local-set-key (kbd "C-c C-c") #'mise-tasks/run)))

(after! elfeed
  (setq elfeed-use-curl t)
  (elfeed-set-timeout 36000)

  ;; Initialize the protocol
  (require 'elfeed-protocol)
  (elfeed-protocol-enable)

  ;; Configure your FreshRSS endpoint
  ;; Format: "fever+https://[user]@[your-domain]"
  (setq elfeed-protocol-feeds
        '(("fever+https://user@rss.example.com"
           :api-url "https://rss.example.com/api/fever.php"
           :password (lambda ()
                        (string-trim
                         (shell-command-to-string
                          "op read \"op://Private/Freshrss/Other Fields/api token\" --account my.1password.eu"))))))

  ;; Optional: Sync read/unread status more aggressively
  (setq elfeed-protocol-fever-update-unread-only t)
  (setq elfeed-search-filter "@2-weeks-ago +unread !youtube")
  )

(defun ar/misc-pick-font ()
  (interactive)
  (let ((font-name (completing-read "Select font:"
                                    (font-family-list))))
    (if (member font-name (font-family-list))
        (set-face-attribute 'default nil :font font-name)
      (error "'%s' font not found" font-name))))

;;; --- SQL Mode + Org-Babel: Database Connections with 1Password ---

(after! sql
  (setq sql-ms-program "sqlcmd")

  ;; 1Password helper
  (defun my/op-read (ref &optional account)
    "Read a secret from 1Password. REF is an op:// reference."
    (string-trim
     (shell-command-to-string
      (format "op read %s%s"
              (shell-quote-argument ref)
              (if account (format " --account %s" (shell-quote-argument account)) "")))))

  ;; Per-connection 1Password vault/account overrides.
  ;; Falls back to vault "Private" and default account when not specified.
  (defvar my/sql-1password-map '()
    "Alist mapping connection names to 1Password (:vault :account) plists.
Example: ((my-work-db :vault \"Work\" :account \"company.1password.eu\"))")

  (defun my/sql-resolve-password (connection-name)
    "Resolve password for CONNECTION-NAME from 1Password."
    (let* ((meta (cdr (assq connection-name my/sql-1password-map)))
           (vault (or (plist-get meta :vault) "Private"))
           (account (plist-get meta :account))
           (op-ref (format "op://%s/%s/password" vault (symbol-name connection-name))))
      (my/op-read op-ref account)))

  ;; Named connections — no passwords stored.
  ;; Convention: 1Password item named same as connection symbol.
  (setq sql-connection-alist
        '((example-pg
           (sql-product 'postgres)
           (sql-server "localhost")
           (sql-port 5432)
           (sql-database "mydb")
           (sql-user "myuser"))
          (example-mssql
           (sql-product 'ms)
           (sql-server "myserver.database.windows.net")
           (sql-port 1433)
           (sql-database "mydb")
           (sql-user "myuser"))))

  ;; sql-mode interactive: inject password at connect time
  (defun my/sql-connect-with-1password (orig-fn connection &rest args)
    "Around advice for `sql-connect' that injects 1Password password."
    (let ((sql-password (condition-case err
                            (my/sql-resolve-password connection)
                          (error (message "1Password: %s" (error-message-string err)) nil))))
      (apply orig-fn connection args)))

  (advice-add 'sql-connect :around #'my/sql-connect-with-1password)

  ;; org-babel: inject password into ob-sql execution
  (defun my/ob-sql-inject-1password (orig-fn body params)
    "Around advice for `org-babel-execute:sql' that injects 1Password password
when :dbconnection is used and :dbpassword is missing."
    (let* ((dbconn (cdr (assq :dbconnection params)))
           (dbpass (cdr (assq :dbpassword params))))
      (when (and dbconn (not dbpass))
        (condition-case err
            (let ((password (my/sql-resolve-password (intern dbconn))))
              (setq params (cons (cons :dbpassword password) params)))
          (error (message "1Password (ob-sql): %s" (error-message-string err)))))
      (funcall orig-fn body params)))

  (with-eval-after-load 'ob-sql
    (advice-add 'org-babel-execute:sql :around #'my/ob-sql-inject-1password))

  (set-popup-rule! "^\\*SQL:" :side 'bottom :size 0.35 :select t :quit 'current :ttl nil))

(use-package! grease
  :commands (grease-open grease-toggle grease-here)
  :init
  (setq grease-sort-method 'type
        grease-show-hidden nil
        grease-preview-window-width 0.4)
  :config
  (map! :leader
        (:prefix ("o g" . "Grease")
         :desc "Toggle Grease"           "g" #'grease-toggle
         :desc "Open Grease (current)"   "o" #'grease-open
         :desc "Open at project root"    "h" #'grease-here)))

(use-package! claude-code-ide
  :defer t
  :commands (claude-code-ide claude-code-ide-toggle claude-code-ide-menu
             claude-code-ide-continue claude-code-ide-resume)
  :init
  (setq claude-code-ide-cli-path (expand-file-name "~/.local/bin/sandboxed-claude"))
  (setq claude-code-ide-terminal-backend 'ghostel)

  :config
  (claude-code-ide-emacs-tools-setup)

  ;; Doom popup rule for Claude Code IDE buffers
  (set-popup-rule! "^\\*claude-code"
    :side 'bottom :size 0.6 :select t
    :quit nil :ttl nil :modeline t)

  (setq claude-code-ide-window-side 'right
        claude-code-ide-window-width 140)

  ;; Evil: start in insert state
  (add-hook 'claude-code-ide-mode-hook #'evil-insert-state)

 ;; Insert a literal newline in the prompt without submitting.
 ;; The built-in `claude-code-ide-insert-newline' sends "\\" + delay + RET,
 ;; which forces a mid-edit repaint that the ghostel backend renders as
 ;; duplicated ("copied") text. Sending a raw line feed (the same byte
 ;; `/terminal-setup` binds Shift+Enter to) avoids the glitch.
 ;;
 ;; The terminal buffer's major mode is `ghostel-mode', NOT a
 ;; `claude-code-ide-mode', and the package binds S-<return> with a
 ;; buffer-local `local-set-key' at buffer creation. So we override it the
 ;; same way, via :after advice on the package's setup function — this runs
 ;; in the new terminal buffer right after the package installs its binding.
 (defun +claude-code-ide-newline ()
   "Insert a newline in the Claude Code prompt without submitting."
   (interactive)
   (claude-code-ide--terminal-send-string "\n"))

 (defun +claude-code-ide-rebind-newline ()
   "Rebind S-<return> to send a raw newline in the current terminal buffer."
   (local-set-key (kbd "S-<return>") #'+claude-code-ide-newline))
 (advice-add 'claude-code-ide--setup-terminal-keybindings
             :after #'+claude-code-ide-rebind-newline))
