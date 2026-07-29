;;; razor-ts-mode.el --- Tree-sitter mode for Razor files -*- lexical-binding: t; -*-

;;; Commentary:
;; Major mode for .razor files using tree-sitter-razor grammar (tris203/tree-sitter-razor).
;; The razor grammar extends C#, producing all C# node types plus Razor-specific ones.

;;; Code:

(require 'treesit)
(require 'c-ts-common)
(eval-when-compile (require 'cl-lib))

;;; Customization

(defcustom razor-ts-mode-indent-offset 4
  "Number of spaces for each indentation step in `razor-ts-mode'."
  :type 'integer
  :group 'razor)

;;; Keywords (same as csharp-ts-mode)

(defvar razor-ts-mode--keywords
  '("using" "namespace" "class" "if" "else" "throw" "new" "for"
    "return" "await" "struct" "enum" "switch" "case"
    "default" "typeof" "try" "catch" "finally" "break"
    "foreach" "in" "yield" "get" "set" "when" "as" "out"
    "is" "while" "continue" "this" "ref" "goto" "interface"
    "from" "where" "select" "lock" "base" "record" "init"
    "with" "let" "static" "var" "do" "public" "private"
    "readonly" "unmanaged")
  "C# keywords for tree-sitter font-locking in Razor buffers.")

;;; HTML parser range management
;;
;; The razor grammar produces `(element)` nodes for HTML regions, but these
;; nest (outer elements contain inner elements), creating overlapping ranges.
;; Emacs's `treesit-range-rules` rejects overlapping ranges. We solve this
;; the same way Neovim's `#set! injection.combined` does: capture all element
;; ranges, merge overlapping ones, and manually set them on the HTML parser.

(defvar-local razor-ts-mode--html-parser nil
  "The HTML tree-sitter parser for this buffer, or nil if unavailable.")

(defun razor-ts-mode--merge-ranges (ranges)
  "Merge overlapping or adjacent RANGES.
RANGES is a list of (BEG . END) cons cells.  Returns a sorted,
non-overlapping list."
  (when ranges
    (let* ((sorted (sort (copy-sequence ranges)
                         (lambda (a b) (< (car a) (car b)))))
           (merged (list (car sorted))))
      (dolist (r (cdr sorted))
        (let ((top (car merged)))
          (if (<= (car r) (cdr top))
              ;; Overlapping or adjacent — extend
              (setcdr top (max (cdr top) (cdr r)))
            ;; Gap — new range
            (push r merged))))
      (nreverse merged))))

(defun razor-ts-mode--sync-html-ranges ()
  "Update the HTML parser's included ranges from the razor tree's element nodes."
  (when razor-ts-mode--html-parser
    (let* ((razor-parser treesit-primary-parser)
           (root (treesit-parser-root-node razor-parser))
           (elements (treesit-query-capture root '((element) @el) nil nil t))
           (ranges (mapcar (lambda (node)
                             (cons (treesit-node-start node)
                                   (treesit-node-end node)))
                           elements))
           (merged (razor-ts-mode--merge-ranges ranges)))
      (when merged
        (treesit-parser-set-included-ranges
         razor-ts-mode--html-parser merged)))))

(defun razor-ts-mode--fontify-region (beg end &optional loudly)
  "Fontify region between BEG and END in razor-ts-mode.
Syncs HTML parser ranges before delegating to `treesit-font-lock-fontify-region'.
LOUDLY is passed through."
  (razor-ts-mode--sync-html-ranges)
  (treesit-font-lock-fontify-region beg end loudly))

;;; Font-lock builder

(defun razor-ts-mode--query-valid-p (lang query)
  "Return non-nil if QUERY compiles successfully for LANG with eager validation."
  (condition-case err
      (progn (treesit-query-compile lang query t) t)
    (error
     (message "[razor-ts-mode] Query failed: %s" (error-message-string err))
     nil)))

(defun razor-ts-mode--build-font-lock-settings ()
  "Build font-lock settings, validating each query against the grammar.
Queries that fail eager compilation are skipped with a message."
  (let ((rules nil))
    (cl-flet ((try-rule (lang feature override query)
                (if (razor-ts-mode--query-valid-p lang query)
                    (setq rules
                          (append rules
                                  (apply #'treesit-font-lock-rules
                                         `(:language ,lang
                                           :feature ,feature
                                           ,@(when override `(:override ,override))
                                           ,query))))
                  (message "[razor-ts-mode] Skipping invalid '%s' query" feature))))

      ;; ===================
      ;; C# rules (language 'razor — the razor grammar extends C#)
      ;; ===================

      (try-rule 'razor 'expression nil
        '((conditional_expression (identifier) @font-lock-variable-use-face)
          (postfix_unary_expression (identifier)* @font-lock-variable-use-face)
          (initializer_expression (assignment_expression left: (identifier) @font-lock-variable-use-face))))

      (try-rule 'razor 'bracket nil
        '((["(" ")" "[" "]" "{" "}"]) @font-lock-bracket-face))

      (try-rule 'razor 'delimiter nil
        '((["," ":" ";"]) @font-lock-delimiter-face))

      (try-rule 'razor 'error nil
        '((ERROR) @font-lock-warning-face))

      (try-rule 'razor 'comment t
        '((comment) @font-lock-comment-face))

      ;; Keywords: split into separate queries so failures are isolated
      (let ((valid-kws (seq-filter
                        (lambda (kw)
                          (razor-ts-mode--query-valid-p
                           'razor (format "\"%s\" @_k" kw)))
                        razor-ts-mode--keywords)))
        (when valid-kws
          (try-rule 'razor 'keyword t
            `([,@valid-kws] @font-lock-keyword-face))))

      (try-rule 'razor 'keyword t
        '((modifier) @font-lock-keyword-face))

      (try-rule 'razor 'keyword t
        '((this_expression) @font-lock-keyword-face))

      (try-rule 'razor 'property t
        '((attribute (identifier) @font-lock-property-use-face (attribute_argument_list))
          (attribute (identifier) @font-lock-property-use-face)))

      (try-rule 'razor 'escape-sequence t
        '((escape_sequence) @font-lock-escape-face))

      (try-rule 'razor 'literal t
        '((integer_literal) @font-lock-number-face
          (real_literal) @font-lock-number-face
          (null_literal) @font-lock-constant-face
          (boolean_literal) @font-lock-constant-face))

      ;; String: core types
      (try-rule 'razor 'string t
        '([(string_literal)
           (verbatim_string_literal)
           (character_literal)]
          @font-lock-string-face))

      ;; String: interpolated (may not exist in all grammar versions)
      (try-rule 'razor 'string t
        '([(interpolated_string_text)
           (interpolated_verbatim_string_text)]
          @font-lock-string-face))

      ;; String: delimiter tokens
      (try-rule 'razor 'string t
        '(["\"" "$\"" "@$\"" "$@\""]
          @font-lock-string-face))

      (try-rule 'razor 'type t
        '((predefined_type) @font-lock-type-face
          (implicit_type) @font-lock-type-face
          (nullable_type) @font-lock-type-face
          (type_parameter
           (identifier) @font-lock-type-face)
          (type_argument_list
           (identifier) @font-lock-type-face)
          (type_argument_list
           (generic_name
            (identifier) @font-lock-type-face))
          (base_list
           (generic_name
            (identifier) @font-lock-type-face))
          (array_type
           (identifier) @font-lock-type-face)
          (cast_expression (identifier) @font-lock-type-face)
          (cast_expression (generic_name (identifier) @font-lock-type-face))
          ["operator"] @font-lock-type-face
          (type_parameter_constraints_clause
           (identifier) @font-lock-type-face)
          (object_creation_expression
           type: (identifier) @font-lock-type-face)
          (object_creation_expression
           type: (generic_name (identifier) @font-lock-type-face))
          (as_expression right: (identifier) @font-lock-type-face)
          (as_expression right: (generic_name (identifier) @font-lock-type-face))))

      ;; Type patterns that may not exist in all grammar versions
      (try-rule 'razor 'type t
        '((type_constraint type: (identifier) @font-lock-type-face)
          (type_constraint type: (generic_name (identifier) @font-lock-type-face))))

      (try-rule 'razor 'type t
        '((type_of_expression (identifier) @font-lock-type-face)))

      (try-rule 'razor 'definition t
        '((qualified_name (identifier) @font-lock-type-face)
          (using_directive (identifier) @font-lock-type-face)
          (enum_declaration (identifier) @font-lock-type-face)
          (enum_member_declaration (identifier) @font-lock-variable-name-face)
          (interface_declaration (identifier) @font-lock-type-face)
          (struct_declaration (identifier) @font-lock-type-face)
          (record_declaration (identifier) @font-lock-type-face)
          (namespace_declaration (identifier) @font-lock-type-face)
          (base_list (identifier) @font-lock-type-face)
          (property_declaration
           type: (nullable_type) @font-lock-type-face
           name: (identifier) @font-lock-variable-name-face)
          (property_declaration
           type: (predefined_type) @font-lock-type-face
           name: (identifier) @font-lock-variable-name-face)
          (property_declaration
           type: (identifier) @font-lock-type-face
           name: (identifier) @font-lock-variable-name-face)
          (class_declaration (identifier) @font-lock-type-face)
          (constructor_declaration name: (_) @font-lock-type-face)
          (method_declaration type: [(identifier) (predefined_type)] @font-lock-type-face)
          (method_declaration type: (generic_name (identifier) @font-lock-type-face))
          (method_declaration name: (_) @font-lock-function-name-face)
          (catch_declaration
           ((identifier) @font-lock-type-face))
          (catch_declaration
           ((identifier) @font-lock-type-face
            (identifier) @font-lock-variable-name-face))
          (variable_declaration (identifier) @font-lock-type-face)
          (variable_declaration (generic_name (identifier) @font-lock-type-face))
          (variable_declarator (identifier) @font-lock-variable-name-face)
          (parameter type: (identifier) @font-lock-type-face)
          (parameter type: (generic_name (identifier) @font-lock-type-face))
          (parameter name: (identifier) @font-lock-variable-name-face)
          (lambda_expression (identifier) @font-lock-variable-name-face)
          (declaration_expression type: (identifier) @font-lock-type-face)
          (declaration_expression name: (identifier) @font-lock-variable-name-face)))

      ;; Definition patterns that may not exist in all grammar versions
      (try-rule 'razor 'definition t
        '((using_directive (name_equals
                            (identifier) @font-lock-type-face))))

      (try-rule 'razor 'function nil
        '((invocation_expression
           function: (member_access_expression
                      name: (identifier) @font-lock-function-call-face))
          (invocation_expression
           function: (identifier) @font-lock-function-call-face)
          (invocation_expression
           function: (member_access_expression
                      name: (generic_name (identifier) @font-lock-function-call-face)))
          (invocation_expression
           function: (generic_name (identifier) @font-lock-function-call-face))))

      ;; C# preprocessor directives (may not exist in razor grammar)
      (try-rule 'razor 'directives t
        '((if_directive
           "if" @font-lock-preprocessor-face
           (identifier) @font-lock-variable-use-face)
          (elif_directive
           "elif" @font-lock-preprocessor-face
           (identifier) @font-lock-variable-use-face)
          (else_directive) @font-lock-preprocessor-face
          (endif_directive) @font-lock-preprocessor-face
          (define_directive
           "define" @font-lock-preprocessor-face
           (identifier) @font-lock-variable-use-face)
          (nullable_directive) @font-lock-preprocessor-face
          (pragma_directive) @font-lock-preprocessor-face
          (region_directive) @font-lock-preprocessor-face
          (endregion_directive) @font-lock-preprocessor-face
          (region_directive
           (preproc_message) @font-lock-variable-use-face)
          (endregion_directive
           (preproc_message) @font-lock-variable-use-face)))

      ;; ===================
      ;; Razor-specific rules
      ;; ===================

      ;; Razor directives — try anonymous string form first, then named node form
      (or (try-rule 'razor 'directives t
            '(["at_page" "at_using" "at_model" "at_rendermode" "at_inject"
               "at_implements" "at_layout" "at_inherits" "at_attribute"
               "at_typeparam" "at_namespace" "at_preservewhitespace"
               "at_block" "at_colon_transition"]
              @font-lock-preprocessor-face))
          (try-rule 'razor 'directives t
            '([(at_page) (at_using) (at_model) (at_rendermode) (at_inject)
               (at_implements) (at_layout) (at_inherits) (at_attribute)
               (at_typeparam) (at_namespace) (at_preservewhitespace)
               (at_block) (at_colon_transition)]
              @font-lock-preprocessor-face)))

      ;; Razor control flow keywords
      (or (try-rule 'razor 'keyword t
            '(["at_if" "at_switch" "at_for" "at_foreach" "at_while" "at_do"
               "at_try" "at_lock" "at_section" "at_await"]
              @font-lock-keyword-face))
          (try-rule 'razor 'keyword t
            '([(at_if) (at_switch) (at_for) (at_foreach) (at_while) (at_do)
               (at_try) (at_lock) (at_section) (at_await)]
              @font-lock-keyword-face)))

      ;; Razor comments
      (try-rule 'razor 'comment t
        '([(razor_comment) (html_comment)] @font-lock-comment-face))
      ;; Try separately if combined fails
      (try-rule 'razor 'comment t
        '((razor_comment) @font-lock-comment-face))
      (try-rule 'razor 'comment t
        '((html_comment) @font-lock-comment-face))

      ;; Razor escape
      (or (try-rule 'razor 'escape-sequence t
            '(["at_at_escape"] @font-lock-escape-face))
          (try-rule 'razor 'escape-sequence t
            '((at_at_escape) @font-lock-escape-face)))

      (try-rule 'razor 'property t
        '((razor_rendermode) @font-lock-property-use-face))

      (try-rule 'razor 'function nil
        '((razor_attribute_name) @font-lock-function-call-face))

      ;; Razor implicit/explicit
      (or (try-rule 'razor 'directives t
            '(["at_implicit" "at_explicit"] @font-lock-variable-name-face))
          (try-rule 'razor 'directives t
            '([(at_implicit) (at_explicit)] @font-lock-variable-name-face)))

      ;; ===================
      ;; HTML rules (language 'html — embedded via manual range sync)
      ;; ===================
      (when (treesit-ready-p 'html t)
        (try-rule 'html 'comment t
          '((comment) @font-lock-comment-face))

        (try-rule 'html 'keyword t
          '("doctype" @font-lock-keyword-face))

        (try-rule 'html 'definition t
          '((tag_name) @font-lock-function-name-face))

        (try-rule 'html 'string t
          '((quoted_attribute_value) @font-lock-string-face))

        (try-rule 'html 'property t
          '((attribute_name) @font-lock-variable-name-face))))

    rules))

;;; Indentation rules

(defvar razor-ts-mode--indent-rules
  `((razor
     ((parent-is "compilation_unit") parent-bol 0)
     ((node-is "}") parent-bol 0)
     ((node-is ")") parent-bol 0)
     ((node-is "]") parent-bol 0)
     ((and (parent-is "comment") c-ts-common-looking-at-star)
      c-ts-common-comment-start-after-first-star -1)
     ((parent-is "comment") prev-adaptive-prefix 0)
     ((parent-is "namespace_declaration") parent-bol 0)
     ((parent-is "class_declaration") parent-bol 0)
     ((parent-is "constructor_declaration") parent-bol 0)
     ((parent-is "initializer_expression") parent-bol razor-ts-mode-indent-offset)
     ((match "{" "anonymous_object_creation_expression") parent-bol 0)
     ((parent-is "anonymous_object_creation_expression") parent-bol razor-ts-mode-indent-offset)
     ((match "{" "object_creation_expression") parent-bol 0)
     ((parent-is "object_creation_expression") parent-bol 0)
     ((parent-is "method_declaration") parent-bol 0)
     ((parent-is "enum_declaration") parent-bol 0)
     ((parent-is "operator_declaration") parent-bol 0)
     ((parent-is "field_declaration") parent-bol 0)
     ((parent-is "struct_declaration") parent-bol 0)
     ((parent-is "declaration_list") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "argument_list") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "interpolation") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "binary_expression") parent 0)
     ((parent-is "block") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "local_function_statement") parent-bol 0)
     ((match "block" "if_statement") parent-bol 0)
     ((match "else" "if_statement") parent-bol 0)
     ((parent-is "if_statement") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "for_statement") parent-bol 0)
     ((parent-is "for_each_statement") parent-bol 0)
     ((parent-is "while_statement") parent-bol 0)
     ((match "{" "switch_expression") parent-bol 0)
     ((parent-is "switch_statement") parent-bol 0)
     ((parent-is "switch_body") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "switch_section") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "switch_expression") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "case_statement") parent-bol 0)
     ((parent-is "do_statement") parent-bol 0)
     ((parent-is "equals_value_clause") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "ternary_expression") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "conditional_expression") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "statement_block") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "type_arguments") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "variable_declarator") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "arguments") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "array") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "formal_parameters") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "template_substitution") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "object_pattern") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "object") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "object_type") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "enum_body") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "arrow_function") parent-bol razor-ts-mode-indent-offset)
     ((parent-is "parenthesized_expression") parent-bol razor-ts-mode-indent-offset)))
  "Tree-sitter indent rules for `razor-ts-mode'.")

;;; Defun name

(defun razor-ts-mode--defun-name (node)
  "Return the defun name of NODE.
Return nil if there is no name or if NODE is not a defun node."
  (pcase (treesit-node-type node)
    ((or "method_declaration"
         "class_declaration"
         "interface_declaration"
         "struct_declaration"
         "enum_declaration"
         "record_declaration"
         "namespace_declaration")
     (treesit-node-text
      (treesit-node-child-by-field-name node "name") t))))

;;; Language-at-point

(defun razor-ts-mode--language-at-point (pos)
  "Return the language at POS: `html' inside elements, `razor' elsewhere."
  (let* ((razor-parser treesit-primary-parser)
         (node (treesit-node-at pos 'razor))
         (type (treesit-node-type node)))
    ;; Walk up looking for an `element' ancestor
    (if (or (string= type "element")
            (let ((parent node)
                  (found nil))
              (while (and (setq parent (treesit-node-parent parent))
                          (not found))
                (when (string= (treesit-node-type parent) "element")
                  (setq found t)))
              found))
        'html
      'razor)))

;;; Mode definition

;;;###autoload
(define-derived-mode razor-ts-mode prog-mode "Razor"
  "Major mode for editing Razor files, powered by tree-sitter.

Uses tree-sitter-razor as the primary parser (extends C#)."
  :group 'razor

  (unless (treesit-ready-p 'razor)
    (error "Tree-sitter for Razor isn't available"))

  ;; Create parsers
  (setq-local treesit-primary-parser (treesit-parser-create 'razor))
  (when (treesit-ready-p 'html t)
    (setq-local razor-ts-mode--html-parser (treesit-parser-create 'html)))

  ;; Comments
  (c-ts-common-comment-setup)
  (setq-local comment-start "// ")
  (setq-local comment-end "")

  ;; Indent
  (setq-local treesit-simple-indent-rules razor-ts-mode--indent-rules)
  (setq-local electric-indent-chars
              (append "{}():;," electric-indent-chars))

  ;; Navigation
  (setq-local treesit-defun-type-regexp "declaration")
  (setq-local treesit-defun-name-function #'razor-ts-mode--defun-name)

  ;; Font-lock — built at mode-init time so grammar is loaded
  (setq-local treesit-font-lock-settings
              (razor-ts-mode--build-font-lock-settings))
  (setq-local treesit-font-lock-feature-list
              '((comment definition)
                (keyword string type directives)
                (constant escape-sequence expression literal property)
                (function bracket delimiter error)))

  ;; Imenu
  (setq-local treesit-simple-imenu-settings
              '(("Class" "\\`class_declaration\\'" nil nil)
                ("Interface" "\\`interface_declaration\\'" nil nil)
                ("Enum" "\\`enum_declaration\\'" nil nil)
                ("Record" "\\`record_declaration\\'" nil nil)
                ("Struct" "\\`struct_declaration\\'" nil nil)
                ("Method" "\\`method_declaration\\'" nil nil)))

  ;; Language-at-point for multi-language support
  (when razor-ts-mode--html-parser
    (setq-local treesit-language-at-point-function
                #'razor-ts-mode--language-at-point))

  (treesit-major-mode-setup)

  ;; Use custom fontify function that syncs HTML ranges before fontification.
  ;; This must be set after treesit-major-mode-setup.
  (setq-local font-lock-defaults
              '(nil nil nil nil
                (font-lock-fontify-region-function
                 . razor-ts-mode--fontify-region)
                (font-lock-fontify-syntactically-function
                 . treesit-font-lock-fontify-region))))

(provide 'razor-ts-mode)
;;; razor-ts-mode.el ends here
