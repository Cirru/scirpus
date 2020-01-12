
-- "File to generate AST from templates"

var
  fs $ require :fs
  babelParser $ require :@babel/parser
  generator $ require :@babel/generator
  Immutable $ require :immutable

var files $ require :./files-index

-- var files $ [] :empty

var purifyTree $ \ (tree)
  case true
    (Immutable.Map.isMap tree) $ ... tree
      filter $ \ (item key)
        if (is key :start) $ do $ return false
        if (is key :end) $ do $ return false
        if (is key :loc) $ do $ return false
        if (is key :parenStart) $ do $ return false
        , true
      map $ \ (item)
        purifyTree item
    (Immutable.List.isList tree) $ tree.map $ \ (item)
      purifyTree item
    else tree

var re $ \ (x)
  JSON.parse $ JSON.stringify x

files.forEach $ \ (file)
  console.log :file: file
  var
    filename $ + :template/ file :.js
    jsCode $ fs.readFileSync filename :utf8
    result $ babelParser.parse jsCode
    res $ purifyTree $ Immutable.fromJS (re result)
  = res $ re $ ... res (delete :tokens) (delete :comments)
  fs.writeFileSync (+ :ast/ file :.json) (JSON.stringify res null 2)
  -- var generated $ generator.default res
  -- fs.writeFileSync (+ :generated/ file :.js) generated.code
