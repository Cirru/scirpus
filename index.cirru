doctype

html
  head
    title "Scirpus"
    meta (:charset utf-8)
    link (:rel icon)
      :type image/png
      :href http://cirru.qiniudn.com/cirru-32x32.png
    @if (@ dev)
      script (:defer) $ :src http://localhost:8080/build/main.js
      script (:defer) $ :src (@ main)
  body
    textarea#source
    textarea#compiled
