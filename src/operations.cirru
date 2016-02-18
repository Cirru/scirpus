
var
  type $ require :type-of

  assert $ require :./assert
  dataType $ require :./data-type
  listUtil $ require :./list-util
  category $ require :./category

var bind $ \ (v k) (k v)
var first $ \ (list) (. list 0)
var tail $ \ (list) (list.slice 1)
var getLast $ \ (list)
  . list (- list.length 1)
var initial $ \ (list)
  list.slice 0 (- list.length 1)

var $ transformOperation $ \ (ast environment)
  assert.array ast :transform
  var
    head $ first ast
    ctor $ . dictionary head
  if
    and
      is (type head) :string
      is (type ctor) :function
    do
      var
        args $ ast.slice 1
      return $ ctor args environment
    do
      = ctor $ . dictionary :__call_expression__
      return $ ctor ast environment
  , undefined

var $ readToken $ \ (text)
  if (is text :super) $ do
    return $ object (:type :Super)
  if
    or (is text :this) (is text :@)
    do $ return $ object
      :type :ThisExpression
  = text $ text.replace /^@ :this.
  if (in ([] :true :false) text) $ do $ return $ {}
    :type :BooleanLiteral
    :value $ cond (is text :true) true false
  if (is text :null) $ do $ return $ {}
    :type :NullLiteral
  if
    and (text.match /^\w) (not (text.match /^\d))
    do $ if (text.match /\.)
      do
        var
          names $ text.split :.
        return $ buildMembers names
      do
        return $ object
          :type :Identifier
          :name text
    do
      var $ value $ dataType.decode text
      switch true
        (is (type value) :regexp)
          return $ object
            :type :RegExpLiteral
            :extra $ {}
              :raw $ String value
            :pattern $ text.substr 1
            :flags :
        (is (type value) :number)
          return $ {}
            :type :NumericLiteral
            :extra $ {}
              :rawValue value
              :raw $ String value
            :value value
        (is (type value) :string)
          return $ {}
            :type :StringLiteral
            :extra $ {}
              :rawValue value
              :raw $ JSON.stringify value
            :value value
        else
          return $ object
            :type :Literal
            :value value
            :raw $ String value
  , undefined

var $ decideSolution $ \ (x environment)
  assert.oneOf environment
    array :statement :expression
    , ":environment"

  if (is (type x) :array) $ do
    var
      result $ transformOperation x :expression
  if (is (type x) :string) $ do
    var
      result $ readToken x
  if (not (? result))
    do
      var inStr $ JSON.stringify x
      throw $ new Error $ + ":Unknown chunk: " inStr

  if (is environment :statement) $ do
    if (is (type x) :string) $ do $ return $ {}
      :type :ExpressionStatement
      :expression result
    if (is (type x) :array) $ do
      var $ head $ . x 0
      if
        or
          not (is (type head) :string)
          and (is (type head) :string) (not $ in category.statement head)
        do
          var names $ [] :ObjectExpression :FunctionExpression
          if (in names result.type) $ do
            = result.extra $ {}
              :parenthesized true
          return $ {}
            :type :ExpressionStatement
            :expression result

  return result

var $ makeIdentifier $ \ (name)
  return $ object
    :type :Identifier
    :name name

var $ buildMembers $ \ (names)
  if (< names.length 1)
    do
      throw $ new Error ":Cannot build MemberExpression with nothing"
  if (is names.length 1) $ do
    return $ decideSolution (first names) :expression

  return $ object
    :type :MemberExpression
    :computed false
    :object $ buildMembers (initial names)
    :property $ makeIdentifier (getLast names)

var $ buildChain $ \ (names)
  if (is names.length 1)
    do $ return $ decideSolution (first names) :expression

  var
    listInitial $ initial names
    last $ getLast names
  assert.array last ":last of buildChain"
  var
    method $ first last
    args $ tail last
  assert.string method ":method of buildChain"

  return $ object
    :type :CallExpression
    :callee $ object
      :type :MemberExpression
      :computed false
      :object $ buildChain listInitial
      :property $ makeIdentifier method
    :arguments $ args.map $ \ (item)
      return $ decideSolution item :expression

var $ dictionary $ object
  :__assgin__ $ \ (args environment)
    var
      name $ . args 0
      value $ . args 1
    return $ object
      :type :AssignmentExpression
      :operator :=
      :left $ decideSolution name :expression
      :right $ decideSolution value :expression

  :var $ \ (args environment)
    assert.array args ":variable declarations"
    var
      first $ . args 0
      init $ . args 1
    if (is (type first) :string) $ do
      return $ object
        :type :VariableDeclaration
        :declarations $ array
          object
            :type :VariableDeclarator
            :id $ makeIdentifier first
            :init $ cond init
              bind (decideSolution init :expression) $ \ (result)
                if (is result.type :FunctionExpression) $ do
                  = result.id $ makeIdentifier first
                return result
              , null
        :kind :var
    return $ object
      :type :VariableDeclaration
      :declarations $ args.map $ \ (pair)
        assert.array pair ":declarations in var"
        var
          name $ . pair 0
        var
          init $ . pair 1
        return $ object
          :type :VariableDeclarator
          :id $ decideSolution name :expression
          :init $ cond init
            decideSolution init :expression
            , null
      :kind :var

  :array $ \ (args environment)
    assert.array args ":array args"
    return $ object
      :type :ArrayExpression
      :elements $ args.map $ \ (item)
        return $ decideSolution item :expression

  :array~ $ \ (args environment)
    assert.array args :ArrayPattern
    return $ object
      :type :ArrayPattern
      :elements $ args.map $ \ (item)
        if (is (type item) :string) $ do
          return $ decideSolution item :expression
        , undefined
        assert.array item ":item in ArrayPattern"
        assert.result (is item.length 1) ":an only item in array"
        assert.string (. item 0) ":simple string in ArrayPattern"
        return $ object
          :type :RestElement
          :argument $ makeIdentifier (. item 0)

  :+ $ \ (args environment)
    assert.array args ":args for +"
    assert.result (> args.length 0) ":args for + should no be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    var
      self $ . dictionary :+
    return $ object
      :type :BinaryExpression
      :left $ self (initial args) :expression
      :operator :+
      :right $ decideSolution (getLast args) :expression

  :* $ \ (args environment)
    assert.array args ":args for *"
    assert.result (> args.length 0) ":args for * should not be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    var
      self $ . dictionary :*
    return $ object
      :type :BinaryExpression
      :operator :*
      :left $ self (initial args) :expression
      :right $ decideSolution (getLast args) :expression

  :- $ \ (args environment)
    assert.array args ":args for -"
    assert.result (> args.length 0) ":args for - should no be empty"

    if (is args.length 1)
      do $ return
        decideSolution (. args 0) :expression

    var
      self $ . dictionary :-
    return $ object
      :type :BinaryExpression
      :operator :-
      :left $ self (initial args) :expression
      :right $ decideSolution (getLast args) :expression

  :/ $ \ (args environment)
    assert.array args ":args for /"
    assert.result (> args.length 0) ":args for / should no be empty"

    if (is args.length 1)
      do $ return
        decideSolution (. args 0) :expression

    var
      self $ . dictionary :/
    return $ object
      :type :BinaryExpression
      :operator :/
      :left $ self (initial args) :expression
      :right $ decideSolution (getLast args) :expression

  :% $ \ (args environment)
    assert.array args ":args for %"
    assert.result (> args.length 0) ":args for % should no be empty"

    if (is args.length 1)
      do $ return
        decideSolution (. args 0) :expression

    var
      self $ . dictionary :%
    return $ object
      :type :BinaryExpression
      :operator :%
      :left $ self (initial args) :expression
      :right $ decideSolution (getLast args) :expression

  :\ $ \ (args environment)
    assert.array args :function

    var
      params $ . args 0
      body $ args.slice 1
    assert.array params :params

    return $ object
      :body $ object
        :type :BlockStatement
        :body $ body.map $ \ (line index)
          if
            and
              is index (- body.length 1)
              isnt (. line 0) :return
            do
              = line $ [] :return line
          return $ decideSolution line :statement
        :directives $ array
      :params $ params.map $ \ (item)
        if (is (type item) :string)
          do
            return $ makeIdentifier item
          do
            var $ param $ . item 0
            assert.string param ":rest of params"
            return $ object
              :type :RestElement
              :argument $ makeIdentifier param
        , undefined
      :generator false
      :expression false
      :type :FunctionExpression
      :id null

  :return $ \ (args environment)
    assert.array args :return
    var
      argument $ . args 0
    return $ object
      :type :ReturnStatement
      :argument $ cond (? argument)
        decideSolution argument :expression
        , null

  :\\ $ \ (args environment)
    assert.array args :function

    var
      params $ . args 0
      body $ args.slice 1
    assert.array params :params

    return $ object
      :type :ArrowFunctionExpression
      :id null
      :params $ params.map $ \ (item)
        if (is (type item) :string)
          do
            return $ makeIdentifier item
          do
            var
              param $ . item 0
            assert.string param ":rest of params"
            return $ object
              :type :RestElement
              :argument $ makeIdentifier param
        , undefined
      :generator false
      :expression (is body.length 1)
      :body $ cond (is body.length 1)
        decideSolution (. body 0) :expression
        object
          :type :BlockStatement
          :body $ body.map $ \ (line index)
            if
              and
                is index (- body.length 1)
                isnt (. line 0) :return
              do
                = line $ [] :return line
            decideSolution line :statement
          :directives $ []
        :directives $ []

  :object $ \ (args environment)
    assert.array args ":args for object"
    if (is (type (. args 0)) :string) $ do
      = args $ listUtil.foldPair args
    return $ object
      :type :ObjectExpression
      :properties $ args.map $ \ (pair)
        assert.array pair ":object property"
        var
          name $ . pair 0
          init $ . pair 1
        assert.string name ":object property key"
        return $ object
          :type :ObjectProperty
          :key $ cond (? $ name.match /^:\w[\w\d_$]*$)
            object
              :type :Identifier
              :name $ name.substr 1
            object
              :type :StringLiteral
              :extra $ object
                :rawValue $ name.substr 1
                :raw $ JSON.stringify (name.substr 1)
              :value $ name.substr 1
          :computed false
          :value $ decideSolution init :expression
          :method false
          :shorthand false

  :object~ $ \ (args environment)
    assert.array args ":args for ObjectPattern"
    return $ object
      :type :ObjectPattern
      :properties $ args.map $ \ (property)
        assert.string property ":property in ObjectPattern"
        var $ pattern $ makeIdentifier property
        return $ object
          :method false
          :shorthand true
          :computed false
          :extra $ {}
            :shorthand true
          :value pattern
          :type :ObjectProperty
          :key pattern

  :. $ \ (args environment)
    assert.array args ":args for member"

    var
      object $ . args 0
      property $ . args 1

    cond
      and (is (type property) :string) (is (. property 0) ::)
        ? $ ... (property.slice 1) (match /^\w[\w\d_]*$)
      {}
        :type :MemberExpression
        :computed false
        :object $ decideSolution object :expression
        :property $ {}
          :type :Identifier
          :name $ property.substr 1
      {}
        :type :MemberExpression
        :computed true
        :object $ decideSolution object :expression
        :property $ decideSolution property :expression

  :and $ \ (args environment)
    assert.array args ":args for and"
    assert.result (> args.length 0) ":args for and should not be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    var
      self $ . dictionary :and
    return $ object
      :type :LogicalExpression
      :operator :&&
      :left $ self (initial args) :expression
      :right $ decideSolution (getLast args) :expression

  :or $ \ (args environment)
    assert.array args ":args for or"
    assert.result (> args.length 0) ":args for or should not be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    var
      self $ . dictionary :or
    return $ object
      :type :LogicalExpression
      :operator :||
      :left $ self (initial args) :expression
      :right $ decideSolution (getLast args) :expression

  :not $ \ (args environment)
    assert.array args ":not"

    return $ object
      :type :UnaryExpression
      :operator :!
      :prefix true
      :extra $ object
        :parenthesizedArgument false
      :argument $ decideSolution (first args) :expression

  :if $ \ (args environment)
    assert.array args ":if"

    var
      test $ . args 0
      consequent $ . args 1
      alternate $ . args 2
      consequentBody $ consequent.slice 1

    return $ object
      :type :IfStatement
      :test $ decideSolution test :expression
      :consequent $ {}
        :type :BlockStatement
        :body $ consequentBody.map $ \ (item)
          decideSolution item :statement
        :directives $ []
      :alternate $ cond (? alternate)
        {}
          :type :BlockStatement
          :body $ ... alternate (slice 1) $ map $ \ (item)
            decideSolution item :statement
          :directives $ []
        , null

  :do $ \ (args environment)
    assert.array args ":do"

    return $ object
      :type :BlockStatement
      :body $ args.map $ \ (line)
        decideSolution line :statement
      :directives $ []

  :cond $ \ (args environment)
    assert.array args :cond

    var
      test $ . args 0
      consequent $ . args 1
      alternate $ . args 2

    assert.defined test ":test of cond"
    assert.defined consequent ":test of consequent"

    if (? alternate)
      do $ var alternateAst
        decideSolution alternate :expression
      do $ var alternateAst $ object
        :type :Identifier
        :name :undefined

    return $ object
      :type :ConditionalExpression
      :test $ decideSolution test :expression
      :consequent $ decideSolution consequent :expression
      :alternate alternateAst

  :-- $ \ (args environment)
    return $ object
      :type :Identifier
      :name :undefined

  :__call_expression__ $ \ (args environment)
    assert.array args :__call_expression__
    var
      callee $ . args 0
      args $ args.slice 1

    return $ object
      :type :CallExpression
      :callee $ decideSolution callee :expression
      :arguments $ args.map $ \ (item)
        return $ decideSolution item :expression

  :is $ \ (args environment)
    assert.array args :is
    return $ object
      :type :BinaryExpression
      :operator :===
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :isnt $ \ (args environment)
    assert.array args :isnt
    return $ object
      :type :BinaryExpression
      :operator :!==
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :> $ \ (args environment)
    assert.array args :>
    return $ object
      :type :BinaryExpression
      :operator :>
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :>= $ \ (args environment)
    assert.array args :>=
    return $ object
      :type :BinaryExpression
      :operator :>=
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :< $ \ (args environment)
    assert.array args :<
    return $ object
      :type :BinaryExpression
      :operator :<
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :<= $ \ (args environment)
    assert.array args :<=
    return $ object
      :type :BinaryExpression
      :operator :<=
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :debugger $ \ (args environment)
    return $ object
      :type :DebuggerStatement

  :continue $ \ (args environment)
    return $ object
      :type :ContinueStatement
      :label null

  :break $ \ (args environment)
    return $ object
      :type :BreakStatement
      :label null

  :new $ \ (args environment)
    assert.array args :new
    var
      callee $ . args 0
      args $ args.slice 1
    return $ object
      :type :NewExpression
      :callee $ decideSolution callee :expression
      :arguments $ args.map $ \ (item)
        return $ decideSolution item :expression

  :throw $ \ (args environment)
    assert.array args :throw
    var
      argument $ . args 0
    assert.defined argument ":argument of throw"
    return $ object
      :type :ThrowStatement
      :argument $ decideSolution argument :expression

  :? $ \ (args environment)
    assert.array args :?
    var
      value $ . args 0
    return $ object
      :type :BinaryExpression
      :operator :!=
      :left $ decideSolution value :expression
      :right $ object
        :type :NullLiteral

  :in $ \ (args environment)
    assert.array args :in
    var
      collection $ . args 0
      value $ . args 1
    {}
      :type :BinaryExpression
      :left $ {}
        :type :CallExpression
        :callee $ {}
          :type :MemberExpression
          :object $ decideSolution collection :expression
          :property $ {}
            :type :Identifier
            :name :indexOf
          :computed false
        :arguments $ []
          decideSolution value :expression
      :operator :>=
      :right $ {}
        :type :NumericLiteral
        :extra $ {}
          :rawValue 0
          :raw :0
        :value 0

  :try $ \ (args environment)
    assert.array args :try
    var
      block $ . args 0
      handler $ . args 1
    assert.array args ":handler of try"
    var
      param $ . handler 0
      body $ handler.slice 1
    assert.string param ":param of try"
    assert.array body ":body of try"
    return $ object
      :type :TryStatement
      :block $ decideSolution block :expression
      :finalizer null
      :guardedHandlers $ []
      :handler $ object
        :type :CatchClause
        :param $ makeIdentifier param
        :body $ object
          :type :BlockStatement
          :body $ body.map $ \ (item)
            return $ decideSolution item :statement
          :directives $ []

  :switch $ \ (args environment)
    assert.array args :switch
    var
      discriminant $ . args 0
      cases $ args.slice 1
    assert.array cases ":cases of switch"
    return $ object
      :type :SwitchStatement
      :discriminant $ decideSolution discriminant :expression
      :cases $ cases.map $ \ (item)
        assert.array item ":case of switch"
        var
          test $ . item 0
          consequent $ item.slice 1
          consequentCode $ listUtil.append consequent (array :break)
        return $ object
          :type :SwitchCase
          :consequent $ consequentCode.map $ \ (item)
            decideSolution item :statement
          :test $ cond (is test :else) null
            decideSolution test :expression

  :case $ \ (args environment)
    assert.array args :case
    var
      discriminant $ . args 0
      cases $ args.slice 1
    assert.array cases  ":cases of case"
    return $ object
      :type :CallExpression
      :arguments $ array
      :callee $ object
        :type :ArrowFunctionExpression
        :id null
        :params $ array
        :generator false
        :expression false
        :extra $ {}
          :parenthesized true
        :body $ object
          :type :BlockStatement
          :body $ array
            object
              :type :SwitchStatement
              :discriminant $ decideSolution discriminant :expression
              :cases $ cases.map $ \ (item)
                assert.array item ":case of switch"
                var
                  test $ . item 0
                  consequent $ item.slice 1
                return $ object
                  :type :SwitchCase
                  :test $ cond (is test :else) null
                    decideSolution test :expression
                  :consequent $ consequent.map $ \ (item index)
                    return $ cond (is index (- consequent.length 1))
                      object
                        :type :ReturnStatement
                        :argument $ decideSolution item :expression
                      decideSolution item :expression
          :directives $ array

  :... $ \ (args environment)
    if (is args.length 1)
      do
        assert.array args :spread
        var
          argument $ . args 0
        assert.string :argument ":argument of spread"
        return $ object
          :type :SpreadElement
          :argument $ makeIdentifier argument
      do
        assert.array args ":chain"
        return $ buildChain args
    , undefined

  :class $ \ (args environment)
    assert.array args :class
    var
      className $ first args
      superClass null
      classMethods $ tail args
    if (is (type className) :array) $ do
      assert.result (is className.length 2) ":class declarations"
      = superClass $ getLast className
      = className $ first className
    return $ object
      :type :ClassDeclaration
      :id $ makeIdentifier className
      :superClass $ cond (? superClass)
        makeIdentifier superClass
        , null
      :body $ object
        :type :ClassBody
        :body $ classMethods.map $ \ (pair)
          assert.result (is pair.length 2) ":MethodDefinition"
          var
            keyName $ first pair
            prefix $ array
            definition $ getLast pair
            kind :method
            isStatic false
          if (is (type keyName) :array) $ do
            = prefix $ initial keyName
            = keyName $ getLast keyName
          if (in prefix :get) $ do
            = kind :get
          if (in prefix :set) $ do
            = kind :set
          if (in prefix :static) $ do
            = isStatic true
          if (is keyName :constructor) $ do
            = kind :constructor
          assert.string keyName ":keyName in class"
          assert.array definition ":definition in class"
          return $ object
            :type :MethodDefinition
            :key $ makeIdentifier keyName
            :value $ decideSolution definition :expression
            :kind kind
            :static isStatic
            :computed false

= (. dictionary :[]) dictionary.array
= (. dictionary :[]~) (. dictionary :array~)
= (. dictionary :{}) dictionary.object
= (. dictionary :{}~) (. dictionary :object~)
= (. dictionary :=) (. dictionary :__assgin__)

= exports.transform $ \ (tree)
  var
    environment :statement
    list $ tree.map $ \ (line)
      return $ decideSolution line environment
  {}
    :type :File
    :program $ {}
      :type :Program
      :sourceType :script
      :body list
      :directives ([])
