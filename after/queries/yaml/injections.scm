;; extends

;; GitHub Actions: inject variables

(((string_scalar) @_val @injection.content)
(#lua-match? @_val "${{")
(#set! injection.language "githubactions"))

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "run")
  value:
    (flow_node
      (plain_scalar
        (string_scalar) @injection.content)
      (#set! injection.language "githubbash")))

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "run")
  value:
    (block_node
      (block_scalar) @injection.content
      (#set! injection.language "githubbash")
      (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "run")
  value:
    (block_node
      (block_sequence
        (block_sequence_item
          (flow_node
            (plain_scalar
              (string_scalar) @injection.content))
          (#set! injection.language "githubbash")))))

(block_mapping_pair
  key: (flow_node) @_if
  (#any-of? @_if "if")
  value:
    (flow_node
      (plain_scalar
        (string_scalar) @injection.content)
      (#set! injection.language "githubactionscondition")))

; (block_mapping_pair
;   key: _
;   value:
;     (flow_node
;       (plain_scalar
;         (string_scalar) @_val @injection.content)
;         (#lua-match? @_val "^${{")
;         (#set! injection.language "githubactions")))
