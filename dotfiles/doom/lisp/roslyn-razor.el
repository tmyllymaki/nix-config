;;; roslyn-razor.el --- Razor cohosting for Roslyn + eglot -*- lexical-binding: t; -*-

;; Implements the razor cohosting protocol that Roslyn uses to provide
;; HTML intellisense in .razor files. Roslyn sends virtual HTML content
;; and forwards HTML LSP requests through the C# server.

;;; Code:

(require 'jsonrpc)
(require 'cl-lib)

;;; --- HTML Language Server ---

(defvar roslyn-razor--html-server nil
  "The jsonrpc connection to the HTML language server.")

(defvar roslyn-razor--html-initialized nil
  "Whether the HTML LS has completed initialization.")

(defvar roslyn-razor--html-server-path
  (expand-file-name "~/.local/share/nvim/mason/bin/vscode-html-language-server")
  "Path to vscode-html-language-server binary.")

(defvar roslyn-razor--documents (make-hash-table :test 'equal)
  "Hash table of virtual HTML URI -> plist (:checksum :content :version).")

(defvar roslyn-razor--virtual-html-suffix "__virtual.html"
  "Suffix appended to razor URIs for virtual HTML documents.")

(defun roslyn-razor--ensure-html-server ()
  "Start the HTML language server if not already running."
  (when (or (null roslyn-razor--html-server)
            (not (jsonrpc-running-p roslyn-razor--html-server)))
    (setq roslyn-razor--html-initialized nil)
    (let ((server
           (make-instance
            'jsonrpc-process-connection
            :name "html-ls"
            :process (make-process
                      :name "html-ls"
                      :command (list roslyn-razor--html-server-path "--stdio")
                      :connection-type 'pipe
                      :coding 'utf-8-emacs-unix
                      :noquery t
                      :stderr (get-buffer-create "*html-ls stderr*"))
            :events-buffer-scrollback-size nil)))
      (setq roslyn-razor--html-server server)
      (jsonrpc-request server :initialize
                       `(:processId ,(emacs-pid)
                         :rootUri nil
                         :capabilities
                         (:textDocument
                          (:hover (:contentFormat ["markdown" "plaintext"])
                           :completion (:completionItem (:snippetSupport t))
                           :signatureHelp (:signatureInformation
                                           (:parameterInformation
                                            (:labelOffsetSupport t)))))
                         :workspaceFolders nil))
      (jsonrpc-notify server :initialized (make-hash-table))
      (setq roslyn-razor--html-initialized t)
      (message "[Razor] HTML language server started"))))

(defun roslyn-razor--virtual-uri (razor-uri)
  "Return the virtual HTML URI for RAZOR-URI."
  (if (string-suffix-p roslyn-razor--virtual-html-suffix razor-uri)
      razor-uri
    (concat razor-uri roslyn-razor--virtual-html-suffix)))

(defun roslyn-razor--sync-document (uri checksum content)
  "Sync document CONTENT for razor URI to the HTML language server.
URI is the razor file URI, CHECKSUM is Roslyn's checksum, CONTENT is HTML text."
  (roslyn-razor--ensure-html-server)
  (let* ((virtual-uri (roslyn-razor--virtual-uri uri))
         (existing (gethash virtual-uri roslyn-razor--documents))
         (version (if existing (1+ (plist-get existing :version)) 1)))
    (puthash virtual-uri
             (list :checksum checksum :content content :version version)
             roslyn-razor--documents)
    (if (and existing (plist-get existing :content))
        ;; didChange - full document sync
        (jsonrpc-notify roslyn-razor--html-server
                        :textDocument/didChange
                        `(:textDocument (:uri ,virtual-uri :version ,version)
                          :contentChanges [(:text ,content)]))
      ;; didOpen
      (jsonrpc-notify roslyn-razor--html-server
                      :textDocument/didOpen
                      `(:textDocument (:uri ,virtual-uri
                                       :languageId "html"
                                       :version ,version
                                       :text ,content))))))

;;; --- Notification handlers ---

(defun roslyn-razor--handle-update-html (_server params)
  "Handle razor/updateHtml notification from Roslyn.
PARAMS is a plist with :textDocument, :checksum, and :text."
  (let* ((td (plist-get params :textDocument))
         (uri (plist-get td :uri))
         (checksum (plist-get params :checksum))
         (text (plist-get params :text)))
    (if (and uri checksum text)
        (progn
          (message "[Razor] updateHtml: %s checksum=%s (%d chars)"
                   (file-name-nondirectory (or uri "?")) (or checksum "nil") (length text))
          (roslyn-razor--sync-document uri checksum text))
      (message "[Razor] updateHtml: missing fields! uri=%s checksum=%s text=%s"
               uri checksum (if text (format "%d chars" (length text)) "nil")))))

(defun roslyn-razor--handle-log (_server params)
  "Handle razor/log notification from Roslyn.
PARAMS is a plist with :type and :message."
  (let* ((msg-type (plist-get params :type))
         (msg (plist-get params :message)))
    ;; Only show errors and warnings; suppress verbose info/log/debug
    (when (<= msg-type 2)
      (message "[Razor/%s] %s"
               (if (= msg-type 1) "Error" "Warning")
               msg))))

;;; --- Request forwarding to HTML LS ---

(defun roslyn-razor--forward-to-html (method params)
  "Forward a request with METHOD string and inner PARAMS plist to the HTML LS.
Returns the result, or nil on failure."
  (when (and roslyn-razor--html-server
             (jsonrpc-running-p roslyn-razor--html-server)
             roslyn-razor--html-initialized)
    ;; Rewrite textDocument URI to virtual HTML URI
    (let* ((td (plist-get params :textDocument))
           (uri (plist-get td :uri))
           (virtual-uri (roslyn-razor--virtual-uri uri)))
      (plist-put td :uri virtual-uri)
      (condition-case err
          (jsonrpc-request roslyn-razor--html-server
                          (intern (concat ":" method))
                          params
                          :timeout 10)
        (jsonrpc-error
         (message "[Razor] HTML LS error for %s: %s" method (cdr err))
         nil)))))

;;; --- Shutdown ---

(defun roslyn-razor--shutdown ()
  "Shut down the HTML language server and clean up."
  (when (and roslyn-razor--html-server
             (jsonrpc-running-p roslyn-razor--html-server))
    (condition-case nil
        (jsonrpc-request roslyn-razor--html-server :shutdown nil :timeout 3)
      (error nil))
    (condition-case nil
        (jsonrpc-notify roslyn-razor--html-server :exit nil)
      (error nil))
    (message "[Razor] HTML language server stopped"))
  (setq roslyn-razor--html-server nil
        roslyn-razor--html-initialized nil)
  (clrhash roslyn-razor--documents))

(provide 'roslyn-razor)
;;; roslyn-razor.el ends here
