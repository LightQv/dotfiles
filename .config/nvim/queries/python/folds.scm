;; Fold functions and classes
((function_definition) @fold)
((class_definition) @fold)

;; Fold docstrings (string at top of function/class/module)
((expression_statement (string)) @fold
 (#match? @fold "^\"\"\""))
