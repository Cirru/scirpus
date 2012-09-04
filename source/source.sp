
= http (require 'http')
= handler
  fn (req res) (res.end 'nothing')
= app
  . http (createServer handler)
. app (listen 8000)