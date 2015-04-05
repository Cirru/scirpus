doctype

html
  head
    title "Scirpus"
    meta (:charset utf-8)
    @if (@ dev)
      script (:defer) $ :src http://localhost:8080/build/main.js
      script (:defer) $ :src (@ main)
  body
