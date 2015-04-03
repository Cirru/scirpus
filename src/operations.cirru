
= _ $ require :lodash

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
  if (text.match /^\w)
    do $ return
      object
        :type :Identifier
        :name text
    do
      = value $ dataType.decode text
      return $ object
        :type :Literal
        :value value
        :raw $ String text

= decideSolution $ \ (x environment)
  assert.oneOf environment
    array :statement :expression
    , ":environment"

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

  :array $ \ (args environment)
    assert.array args ":array args"
    object
      :type :ArrayExpression
      :elements $ args.map $ \ (item)
        decideSolution item :expression

  :+ $ \ (args environment)
    assert.array args ":args for +"
    assert.result (> args.length 0) ":args for + should no be empty"

    if (is args.length 1)
      do $ return
        decideSolution (. args 0) :expression

    = self $ . dictionary :+
    object
      :type :BinaryExpression
      :operator :+
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :* $ \ (args environment)
    assert.array args ":args for *"
    assert.result (> args.length 0) ":args for * should not be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    = self $ . dictionary :*
    object
      :type :BinaryExpression
      :operator :*
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :- $ \ ()
  :when $ \ ()
  :\ $ \ ()
  :\\ $ \ ()

  :object $ \ (args environment)
    assert.array args ":args for object"
    object
      :type :ObjectExpression
      :properties $ args.map $ \ (pair)
        assert.array pair ":object property"
        = name $ . pair 0
        = init $ . pair 1
        assert.string name ":object property key"
        object
          :type :Property
          :key $ object
            :type :Identifier
            :name $ name.substr 1
          :computed false
          :value $ decideSolution init :expression
          :kind :init
          :method false
          :shorthand false

  :. $ \ ()
  :and $ \ (args environment)
    assert.array args ":args for and"
    assert.result (> args.length 0) ":args for and should not be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    = self $ . dictionary :and
    object
      :type :LogicalExpression
      :operator :&&
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :or $ \ (args environment)
    assert.array args ":args for or"
    assert.result (> args.length 0) ":args for or should not be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    = self $ . dictionary :or
    object
      :type :LogicalExpression
      :operator :||
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :not $ \ (args environment)
    assert.array args ":not"

    object
      :type :UnaryExpression
      :operator :!
      :argument $ decideSolution (_.first args) :expression
      :prefix true

  :if $ \ ()
  :-- $ \ ()
    object
      :type :Identifier
      :name :undefined

= exports.transform $ \ (tree)
  = environment :statement
  = list $ tree.map $ \ (line)
    decideSolution line environment
  object
    :type :Program
    :body list

