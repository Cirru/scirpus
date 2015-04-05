
= _ $ require :lodash

= assert $ require :./assert
= dataType $ require :./data-type
= listUtil $ require :./list-util

= transformOperation $ \ (ast environment)
  assert.array ast :transform
  = head $ _.first ast
  = contructor $ . dictionary head
  if
    and
      _.isString head
      _.isFunction contructor
    do
      = args $ ast.slice 1
      contructor args environment
    do
      = contructor $ . dictionary :__call_expression__
      contructor ast environment

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
      return $ transformOperation x :expression
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

  :- $ \ (args environment)
    assert.array args ":args for -"
    assert.result (> args.length 0) ":args for - should no be empty"

    if (is args.length 1)
      do $ return
        decideSolution (. args 0) :expression

    = self $ . dictionary :-
    object
      :type :BinaryExpression
      :operator :-
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :/ $ \ (args environment)
    assert.array args ":args for /"
    assert.result (> args.length 0) ":args for / should no be empty"

    if (is args.length 1)
      do $ return
        decideSolution (. args 0) :expression

    = self $ . dictionary :/
    object
      :type :BinaryExpression
      :operator :/
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :% $ \ (args environment)
    assert.array args ":args for %"
    assert.result (> args.length 0) ":args for % should no be empty"

    if (is args.length 1)
      do $ return
        decideSolution (. args 0) :expression

    = self $ . dictionary :%
    object
      :type :BinaryExpression
      :operator :%
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :\ $ \ (args environment)
    assert.array args :function

    = params $ . args 0
    = body $ args.slice 1
    assert.array params :params

    object
      :type :FunctionExpression
      :id null
      :params $ params.map $ \ (item)
        assert.string item ":one of params"
        makeIdentifier item
      :defaults $ array
      :generator false
      :expression false
      :body $ object
        :type :BlockStatement
        :body $ body.map $ \ (line)
          decideSolution line :statement

  :return $ \ (args environment)
    assert.array args :return
    = argument $ . args 0
    object
      :type :ReturnStatement
      :argument $ decideSolution argument :expression

  :\\ $ \ (args environment)
    assert.array args :function

    = params $ . args 0
    = body $ args.slice 1
    assert.array params :params

    object
      :type :ArrowFunctionExpression
      :id null
      :params $ params.map $ \ (item)
        assert.string item ":one of params"
        makeIdentifier item
      :defaults $ array
      :generator false
      :expression true
      :body $ object
        :type :BlockStatement
        :body $ body.map $ \ (line)
          decideSolution line :statement

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

  :. $ \ (args environment)
    assert.array args ":args for member"

    = object $ . args 0
    = property $ . args 1

    object
      :type :MemberExpression
      :computed true
      :object $ decideSolution object :expression
      :property $ decideSolution property :expression

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

  :if $ \ (args environment)
    assert.array args ":if"

    = test $ . args 0
    = consequent $ . args 1
    = alternate $ . args 2

    object
      :type :IfStatement
      :test $ decideSolution test :expression
      :consequent $ decideSolution consequent :expression
      :alternate $ if (? alternate)
        decideSolution consequent :expression
        , null

  :do $ \ (args environment)
    assert.array args ":do"

    object
      :type :BlockStatement
      :body $ args.map $ \ (line)
        decideSolution line :statement

  :cond $ \ (args environment)
    assert.array args :cond

    = test $ . args 0
    = consequent $ . args 1
    = alternate $ . args 2

    assert.defined test ":test of cond"
    assert.defined consequent ":test of consequent"
    assert.defined alternate ":test of alternate"

    object
      :type :ConditionalExpression
      :test $ decideSolution test :expression
      :consequent $ decideSolution consequent :expression
      :alternate $ decideSolution alternate :expression

  :-- $ \ (args environment)
    object
      :type :Identifier
      :name :undefined

  :__call_expression__ $ \ (args environment)
    assert.array args :__call_expression__
    = callee $ . args 0
    = arguments $ args.slice 1

    object
      :type :CallExpression
      :callee $ decideSolution callee :expression
      :arguments $ arguments.map $ \ (item)
        decideSolution item :expression

  :is $ \ (args environment)
    assert.array args :is
    object
      :type :BinaryExpression
      :operator :===
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :> $ \ (args environment)
    assert.array args :>
    object
      :type :BinaryExpression
      :operator :>=
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :>= $ \ (args environment)
    assert.array args :>=
    object
      :type :BinaryExpression
      :operator :>=
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :< $ \ (args environment)
    assert.array args :<
    object
      :type :BinaryExpression
      :operator :<
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :<= $ \ (args environment)
    assert.array args :<=
    object
      :type :BinaryExpression
      :operator :<=
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :debugger $ \ (args environment)
    object
      :type :DebuggerStatement

  :continue $ \ (args environment)
    object
      :type :ContinueStatement
      :label null

  :break $ \ (args environment)
    object
      :type :BreakStatement
      :label null

  :new $ \ (args environment)
    assert.array args :new
    = callee $ . args 0
    = arguments $ args.slice 1
    object
      :type :NewExpression
      :callee $ decideSolution callee :expression
      :arguments $ arguments.map $ \ (item)
        decideSolution item :expression

  :throw $ \ (args environment)
    assert.array args :throw
    = argument $ . args 0
    assert.defined argument ":argument of throw"
    object
      :type :ThrowStatement
      :argument $ decideSolution argument :expression

  :while $ \ (args environment)
    assert.array args :while
    = test $ . args 0
    = body $ args.slice 1
    object
      :type :WhileStatement
      :test $ decideSolution test :expression
      :body $ object
        :type :BlockStatement
        :body $ body.map $ \ (item)
          decideSolution item :statement

  :for $ \ (args environment)
    assert.array args :for
    = names $ . args 0
    = body $ args.slice 1

    assert.array names
    = right $ . names 0
    = left $ . names 1
    = valueName $ . names 2
    assert.string left ":left of for"
    assert.string valueName ":valueName of for"
    = leftCode $ array :var (array left)
    = bodyCode $ listUtil.prepend body
      array :var
        array valueName $ array :. right left

    object
      :type :ForInStatement
      :left $ decideSolution leftCode :expression
      :right $ makeIdentifier right
      :body $ object
        :type :BlockStatement
        :body $ bodyCode.map $ \ (item)
          decideSolution item :expression
      :each false

  :? $ \ (args environment)
    assert.array args :?
    = value $ . args 0
    object
      :type :BinaryExpression
      :operator :!=
      :left $ decideSolution value :expression
      :right $ object
        :type :Literal
        :value null
        :raw :null

  :in $ \ (args environment)
    assert.array args :in
    = collection $ . args 0
    = value $ . args 1
    = code $ array :>=
      array (array :. collection ::indexOf) value
      , :0
    decideSolution code :expression

  :try $ \ (args environment)
    assert.array args :try
    = block $ . args 0
    = handler $ . args 1
    assert.array args ":handler of try"
    = param $ . handler 0
    = body $ handler.slice 1
    assert.string param ":param of try"
    assert.array body ":body of try"
    object
      :type :TryStatement
      :block $ decideSolution block :expression
      :handler $ object
        :type :CatchClause
        :param $ makeIdentifier param
        :body $ object
          :type :BlockStatement
          :body $ body.map $ \ (item)
            decideSolution item :statement

= exports.transform $ \ (tree)
  = environment :statement
  = list $ tree.map $ \ (line)
    decideSolution line environment
  object
    :type :Program
    :body list

