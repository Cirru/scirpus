
-- "File to generate AST from templates"

var
  fs $ require :fs
  babelParser $ require :@babel/parser
  generator $ require :@babel/generator
  bind $ \ (v f) (f v)
  type $ require :type-of

var files $ require :./files-index

-- var files $ [] :empty

var purifyTree $ \ (tree)
  var nodeType $ type tree
  case true
    (is :array nodeType) $ tree.forEach $ \ (item)
      purifyTree item
    (is :string nodeType) tree
    (is :number nodeType) tree
    (is :object nodeType) $ bind tree $ \ (item)
      = item.start undefined
      = item.end undefined
      = item.loc undefined
      = item.parenStart undefined
      (. (Object.values item) :forEach) $ \ (x)
        purifyTree x
    else tree

files.forEach $ \ (file)
  console.log :file: file
  var
    filename $ + :template/ file :.js
    jsCode $ fs.readFileSync filename :utf8
    sourceType $ case true
      (? (jsCode.match /\nimport\s)) :module
      else :script
    result $ babelParser.parse jsCode
      {}
        :sourceType sourceType

  purifyTree result
  = result.tokens undefined
  = result.comments undefined
  fs.writeFileSync (+ :ast/ file :.json) (JSON.stringify result null 2)
  -- var generated $ generator.default result
  -- fs.writeFileSync (+ :generated/ file :.js) generated.code
