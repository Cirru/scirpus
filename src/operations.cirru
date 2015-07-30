
var
  _ $ require :lodash

  assert $ require :./assert
  dataType $ require :./data-type
  listUtil $ require :./list-util
  category $ require :./category

var $ transformOperation $ \ (ast environment)
  assert.array ast :transform
  var
    head $ _.first ast
    contructor $ . dictionary head
  if
    and
      _.isString head
      _.isFunction contructor
    do
      var
        args $ ast.slice 1
      return $ contructor args environment
    do
      = contructor $ . dictionary :__call_expression__
      return $ contructor ast environment

var $ readToken $ \ (text)
  if (is text :super) $ do
    return $ object (:type :Super)
  if (is text :this) $ do
    return $ object
      :type :ThisExpression
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
      if (_.isRegExp value)
        do $ return $ object
          :type :Literal
          :value value
          :raw $ String value
          :regex $ object
            :pattern $ text.substr 1
            :flags :
        do $ return $ object
          :type :Literal
          :value value
          :raw $ String value

var $ decideSolution $ \ (x environment)
  assert.oneOf environment
    array :statement :expression
    , ":environment"

  if (_.isArray x) $ do
    var
      result $ transformOperation x :expression
  if (_.isString x) $ do
    var
      result $ readToken x
  if (not (? result))
    do
      var inStr $ JSON.stringify x
      throw $ new Error $ + ":Unknown chunk: " inStr

  if (is environment :statement) $ do
    if (_.isArray x) $ do
      var $ head $ . x 0
      if
        and (_.isString head)
          not $ in category.statement head
        do
          return $ object
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
    return $ decideSolution (_.first names) :expression

  return $ object
    :type :MemberExpression
    :computed false
    :object $ buildMembers (_.initial names)
    :property $ makeIdentifier (_.last names)

var $ buildChain $ \ (names)
  if (is names.length 1)
    do $ return $ decideSolution (_.first names) :expression

  var
    initial $ _.initial names
    last $ _.last names
  assert.array last ":last of buildChain"
  var
    method $ _.first last
    args $ _.rest last
  assert.string method ":method of buildChain"

  return $ object
    :type :CallExpression
    :callee $ object
      :type :MemberExpression
      :computed false
      :object $ buildChain initial
      :property $ makeIdentifier method
    :arguments $ args.map $ \ (item)
      return $ decideSolution item :expression

var $ dictionary $ object
  := $ \ (args environment)
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
    if (_.isString first) $ do
      return $ object
        :type :VariableDeclaration
        :kind :var
        :declarations $ array
          object
            :type :VariableDeclarator
            :id $ makeIdentifier first
            :init $ cond init
              decideSolution init :expression
              , null
    return $ object
      :type :VariableDeclaration
      :kind :var
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
        if (_.isString item) $ do
          return $ decideSolution item :expression
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
      :operator :+
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

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
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

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
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

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
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

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
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :\ $ \ (args environment)
    assert.array args :function

    var
      params $ . args 0
      body $ args.slice 1
    assert.array params :params

    return $ object
      :type :FunctionExpression
      :id null
      :params $ params.map $ \ (item)
        if (_.isString item)
          do
            return $ makeIdentifier item
          do
            var $ param $ . item 0
            assert.string param ":rest of params"
            return $ object
              :type :RestElement
              :argument $ makeIdentifier param
      :defaults $ array
      :generator false
      :expression false
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
        if (_.isString item)
          do
            return $ makeIdentifier item
          do
            var
              param $ . item 0
            assert.string param ":rest of params"
            return $ object
              :type :RestElement
              :argument $ makeIdentifier param
      :defaults $ array
      :generator false
      :expression true
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

  :object $ \ (args environment)
    assert.array args ":args for object"
    return $ object
      :type :ObjectExpression
      :properties $ args.map $ \ (pair)
        assert.array pair ":object property"
        var
          name $ . pair 0
          init $ . pair 1
        assert.string name ":object property key"
        return $ object
          :type :Property
          :key $ object
            :type :Identifier
            :name $ name.substr 1
          :computed false
          :value $ decideSolution init :expression
          :kind :init
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
          :type :Property
          :key pattern
          :computed false
          :value pattern
          :kind :init
          :method false
          :shorthand false

  :. $ \ (args environment)
    assert.array args ":args for member"

    var
      object $ . args 0
      property $ . args 1

    return $ object
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
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

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
      :left $ self (_.initial args) :expression
      :right $ decideSolution (_.last args) :expression

  :not $ \ (args environment)
    assert.array args ":not"

    return $ object
      :type :UnaryExpression
      :operator :!
      :argument $ decideSolution (_.first args) :expression
      :prefix true

  :if $ \ (args environment)
    assert.array args ":if"

    var
      test $ . args 0
      consequent $ . args 1
      alternate $ . args 2

    return $ object
      :type :IfStatement
      :test $ decideSolution test :expression
      :consequent $ decideSolution consequent :expression
      :alternate $ cond (? alternate)
        decideSolution alternate :expression
        , null

  :do $ \ (args environment)
    assert.array args ":do"

    return $ object
      :type :BlockStatement
      :body $ args.map $ \ (line)
        return $ decideSolution line :statement

  :cond $ \ (args environment)
    assert.array args :cond

    var
      test $ . args 0
      consequent $ . args 1
      alternate $ . args 2

    assert.defined test ":test of cond"
    assert.defined consequent ":test of consequent"
    assert.defined alternate ":test of alternate"

    return $ object
      :type :ConditionalExpression
      :test $ decideSolution test :expression
      :consequent $ decideSolution consequent :expression
      :alternate $ decideSolution alternate :expression

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

  :while $ \ (args environment)
    assert.array args :while
    var
      test $ . args 0
      body $ args.slice 1
    return $ object
      :type :WhileStatement
      :test $ decideSolution test :expression
      :body $ object
        :type :BlockStatement
        :body $ body.map $ \ (item)
          return $ decideSolution item :statement

  :for $ \ (args environment)
    assert.array args :for
    var
      names $ . args 0
      body $ args.slice 1

    assert.array names
    var
      right $ . names 0
      left $ . names 1
      valueName $ . names 2
    assert.string left ":left of for"
    assert.string valueName ":valueName of for"
    var
      leftCode $ array :var (array left)
      bodyCode $ listUtil.prepend body
        array :var
          array valueName $ array :. right left

    return $ object
      :type :ForInStatement
      :left $ decideSolution leftCode :expression
      :right $ makeIdentifier right
      :body $ object
        :type :BlockStatement
        :body $ bodyCode.map $ \ (item)
          return $ decideSolution item :expression
      :each false

  :? $ \ (args environment)
    assert.array args :?
    var
      value $ . args 0
    return $ object
      :type :BinaryExpression
      :operator :!=
      :left $ decideSolution value :expression
      :right $ object
        :type :Literal
        :value null
        :raw :null

  :in $ \ (args environment)
    assert.array args :in
    var
      collection $ . args 0
      value $ . args 1
      code $ array :>=
        array (array :. collection ::indexOf) value
        , :0
    return $ decideSolution code :expression

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
      :handler $ object
        :type :CatchClause
        :param $ makeIdentifier param
        :body $ object
          :type :BlockStatement
          :body $ body.map $ \ (item)
            return $ decideSolution item :statement

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
          :test $ cond (is test :else) null
            decideSolution test :expression
          :consequent $ consequentCode.map $ \ (item)
            return $ decideSolution item :statement

  :case $ \ (args environment)
    assert.array args :case
    var
      discriminant $ . args 0
      cases $ args.slice 1
    assert.array cases  ":cases of case"
    return $ object
      :type :ExpressionStatement
      :expression $ object
        :type :CallExpression
        :arguments $ array
        :callee $ object
          :type :ArrowFunctionExpression
          :id null
          :params $ array
          :defaults $ array
          :generator false
          :expression true
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
                    :consequent $ consequent.map $ \ (item)
                      return $ object
                        :type :ReturnStatement
                        :argument $ decideSolution item :expression

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

  :class $ \ (args environment)
    assert.array args :class
    var
      className $ _.first args
      superClass null
      classMethods $ _.tail args
    if (_.isArray className) $ do
      assert.result (is className.length 2) ":class declarations"
      = superClass $ _.last className
      = className $ _.first className
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
            keyName $ _.first pair
            prefix $ array
            definition $ _.last pair
            kind :method
            isStatic false
          if (_.isArray keyName) $ do
            = prefix $ _.initial keyName
            = keyName $ _.last keyName
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

= exports.transform $ \ (tree)
  var
    environment :statement
    list $ tree.map $ \ (line)
      return $ decideSolution line environment
  return $ object
    :type :Program
    :body list
