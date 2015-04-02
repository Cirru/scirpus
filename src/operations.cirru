
= assert $ require :./assert
= dataType $ require :./data-type

= transformOperation $ \ (ast environment)
  assert.array ast :transform
  = head $ _.first ast
  assert.string head :operation
  = contructor $ . dictionary head
  assert.func contructor ":operation in dictionary"
  = args $ ast.slice 1
  contructor args environment

= readToken $ \ (text)
  = value $ dataType.decode text
  object
    :type :Literal
    :value value
    :raw $ String text

= decideSolution $ \ (x environment)

  if (is environment :expression) $ do
    if (_.isArray x) $ do
      return $ transformOperation x
    if (_.isString x) $ do
      return $ readToken x
  if (is environment :statement) $ do
    if (_.isArray x) $ do
      return $ object
        :type :ExpressionStatement
        :expression $ transformOperation x :expression
    if (_.isString x) $ do
      return $ object
        :type :ExpressionStatement
        :expression $ readToken x

  console.log x
  throw $ new Error ":cannot decide a solution"
  return

= makeIdentifier $ \ (name)
  object
    :type :Identifier
    :name name

= dictionary $ object
  := $ \ (args environment)
    = name $ . args 0
    = value $ . args 1
    assert.string name :variable
    object
      :type :AssignmentExpression
      :operator :=
      :left $ makeIdentifier name
      :right $ decideSolution value :expression

  :var $ \ (args environment)
    assert.array args ":variable declarations"
    object
      :type :VariableDeclaration
      :kind :var
      :declarations $ args.map $ \ (pair)
        = name $ . pair 0
        assert.string name :variable
        = init $ . pair 1
        object
          :type :VariableDeclarator
          :id $ makeIdentifier name
          :init $ if init
            decideSolution init :expression
            , null

  :+ $ \ ()
  :* $ \ ()
  :- $ \ ()
  :when $ \ ()
  :\ $ \ ()
  :\\ $ \ ()
  :object $ \ ()
  :. $ \ ()
  :and $ \ ()
  :or $ \ ()
  :not $ \ ()
  :if $ \ ()
  :-- $ \ ()

= exports.transform $ \ (tree)
  = environment :statement
  = list $ tree.map $ \ (line)
    decideSolution line environment
  object
    :type :Program
    :body list

