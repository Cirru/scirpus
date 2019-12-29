
var
  cirruScript $ require :cirru-script
  fs $ require :fs
  path $ require :path

  files $ fs.readdirSync :src/ :utf8
  cirruFiles $ files.filter $ \ (x)
    x.includes :.cirru

cirruFiles.forEach $ \ (x)
  var code $ cirruScript.compile $ fs.readFileSync (path.join :src x) :utf8
  var jsFile
    (. (path.join :lib x) :replace) :.cirru :.js
  fs.writeFileSync jsFile code
  console.log ":Write file" jsFile
