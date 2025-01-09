;; extends

;; GitHub Actions: inject variables

; ((ERROR) @_error @injection.content
;   (word)
;   (#lua-match? @_error "^${{")
;   (#set! injection.language "githubactions")
;   )

; (block_mapping_pair
;   key: _
;   value:
;     (flow_node
;       (plain_scalar
;         (string_scalar) @_val @injection.content)
;         (#lua-match? @_val "^${{")
;         (#set! injection.language "githubactions")))
