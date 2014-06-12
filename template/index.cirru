
doctype

html
  head
    title Scirpus
    link (:rel icon) (:type image/png)
      :href http://logo.cirru.org/cirru-32x32.png
    script (:src compiled/variable.js)
    script (:src compiled/control.js)
  body
    a (:href https://github.com/Cirru/scirpus)
      = "Scirpus Project"
    p
      = "Open Console to see more"