(null) @constant.builtin

(boolean) @boolean

(type) @type

(string) @string

[
  (int)
  (float)
  (hex)
  (exp)
] @number

(context) @variable

(property) @property

[
  (call ",")
  (property_deref)
] @punctuation.delimiter

; env variables
((context
  (identifier) @_env)
(property
  (property_deref)
  (identifier) @constant
  (#eq? @_env "env")))

[
  (operator)
  (not)
] @operator

[
  (logical_group ["(" ")"])
  (variable ["{{" "}}"])
  (index ["[" "]"])
] @punctuation.bracket

[
  (variable "$")
  (property (asterisk))
] @punctuation.special

(call function: (identifier) @function.builtin.call)
