
require("calabash").do "watch and compile",
  # "coffee -o src/ -wbc coffee/"
  "node-dev test/prehearse.coffee"