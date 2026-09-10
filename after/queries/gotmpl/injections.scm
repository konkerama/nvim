; extends

; CUSTOM: helm/gotmpl files are YAML with template holes. The combined injection stitches every
; `text` node into one yaml tree, so keys/values/strings get the same captures as plain yaml.
((text) @injection.content
  (#set! injection.language "yaml")
  (#set! injection.combined))
