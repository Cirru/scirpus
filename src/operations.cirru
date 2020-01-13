
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
    return $ {} (:type :Super)
  if
    or (is text :this) (is text :@)
    do $ return $ {}
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
        return $ {}
          :type :Identifier
          :name text
    do
      var $ value $ dataType.decode text
      switch true
        (is (type value) :regexp)
          return $ {}
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
          return $ {}
            :type :Literal
            :value value
            :raw $ String value
  , undefined

var $ decideSolution $ \ (x environment)
  assert.oneOf environment
    [] :statement :expression
    , ":environment"

  var head

  if (is (type x) :array) $ do
    = head $ first x
    var
      result $ transformOperation x :expression
  if (is (type x) :string) $ do
    var
      result $ readToken x
  if (not (? result))
    do
      var inStr $ JSON.stringify x
      throw $ new Error $ + ":Unknown chunk: " inStr

  if (is :import head) $ do
    return result
  if (is :export head) $ do
    return result

  if (is environment :statement) $ do
    if (is (type x) :string) $ do $ return $ {}
      :type :ExpressionStatement
      :expression result
    if (is (type x) :array) $ do
      var $ head $ . x 0
      if (is head :import) $ do
        return result
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
  return $ {}
    :type :Identifier
    :name name

var $ buildMembers $ \ (names)
  if (< names.length 1)
    do
      throw $ new Error ":Cannot build MemberExpression with nothing"
  if (is names.length 1) $ do
    return $ decideSolution (first names) :expression

  return $ {}
    :type :MemberExpression
    :object $ buildMembers (initial names)
    :property $ makeIdentifier (getLast names)
    :computed false

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

  return $ {}
    :type :CallExpression
    :callee $ {}
      :type :MemberExpression
      :object $ buildChain listInitial
      :property $ makeIdentifier method
      :computed false
    :arguments $ args.map $ \ (item)
      return $ decideSolution item :expression

var $ dictionary $ {}
  :__assgin__ $ \ (args environment)
    var
      name $ . args 0
      value $ . args 1
    return $ {}
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
      return $ {}
        :type :VariableDeclaration
        :declarations $ []
          {}
            :type :VariableDeclarator
            :id $ makeIdentifier first
            :init $ cond init
              bind (decideSolution init :expression) $ \ (result)
                if (is result.type :FunctionExpression) $ do
                  = result.id $ makeIdentifier first
                return result
              , null
        :kind :var
    return $ {}
      :type :VariableDeclaration
      :declarations $ args.map $ \ (pair)
        assert.array pair ":declarations in var"
        var
          name $ . pair 0
        var
          init $ . pair 1
        return $ {}
          :type :VariableDeclarator
          :id $ decideSolution name :expression
          :init $ cond init
            decideSolution init :expression
            , null
      :kind :var

  :[] $ \ (args environment)
    assert.array args ":array args"
    return $ {}
      :type :ArrayExpression
      :elements $ args.map $ \ (item)
        return $ decideSolution item :expression

  :[]~ $ \ (args environment)
    assert.array args :ArrayPattern
    return $ {}
      :type :ArrayPattern
      :elements $ args.map $ \ (item)
        if (is (type item) :string) $ do
          return $ decideSolution item :expression
        , undefined
        assert.array item ":item in ArrayPattern"
        assert.result (is item.length 1) ":an only item in array"
        assert.string (. item 0) ":simple string in ArrayPattern"
        return $ {}
          :type :RestElement
          :argument $ makeIdentifier (. item 0)

  :+ $ \ (args environment)
    assert.array args ":args for +"
    assert.result (> args.length 0) ":args for + should no be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    var
      self $ . dictionary :+
    return $ {}
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
    return $ {}
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
    return $ {}
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
    return $ {}
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
    return $ {}
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

    return $ {}
      :body $ {}
        :type :BlockStatement
        :body $ body.map $ \ (line index)
          if
            and
              is index (- body.length 1)
              isnt (. line 0) :return
            do
              = line $ [] :return line
          return $ decideSolution line :statement
        :directives $ []
      :params $ params.map $ \ (item)
        if (is (type item) :string)
          do
            return $ makeIdentifier item
          do
            var $ param $ . item 0
            assert.string param ":rest of params"
            return $ {}
              :type :RestElement
              :argument $ makeIdentifier param
        , undefined
      :generator false
      :type :FunctionExpression
      :id null
      :async false

  :return $ \ (args environment)
    assert.array args :return
    var
      argument $ . args 0
    return $ {}
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

    return $ {}
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
            return $ {}
              :type :RestElement
              :argument $ makeIdentifier param
        , undefined
      :generator false
      :async false
      :body $ cond (is body.length 1)
        decideSolution (. body 0) :expression
        {}
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

  :{} $ \ (args environment)
    assert.array args ":args for object"
    if (is (type (. args 0)) :string) $ do
      = args $ listUtil.foldPair args
    return $ {}
      :type :ObjectExpression
      :properties $ args.map $ \ (pair)
        assert.array pair ":object property"
        var
          name $ . pair 0
          init $ . pair 1
        assert.string name ":object property key"
        return $ {}
          :type :ObjectProperty
          :key $ cond (? $ name.match /^:\w[\w\d_$]*$)
            {}
              :type :Identifier
              :name $ name.substr 1
            {}
              :type :StringLiteral
              :extra $ {}
                :rawValue $ name.substr 1
                :raw $ JSON.stringify (name.substr 1)
              :value $ name.substr 1
          :value $ decideSolution init :expression
          :method false
          :shorthand false
          :computed false

  :{}~ $ \ (args environment)
    assert.array args ":args for ObjectPattern"
    return $ {}
      :type :ObjectPattern
      :properties $ args.map $ \ (property)
        assert.string property ":property in ObjectPattern"
        var $ pattern $ makeIdentifier property
        return $ {}
          :method false
          :shorthand true
          :extra $ {}
            :shorthand true
          :value pattern
          :type :ObjectProperty
          :key pattern
          :computed false

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
        :object $ decideSolution object :expression
        :property $ {}
          :type :Identifier
          :name $ property.substr 1
        :computed false
      {}
        :type :MemberExpression
        :object $ decideSolution object :expression
        :property $ decideSolution property :expression
        :computed true

  :and $ \ (args environment)
    assert.array args ":args for and"
    assert.result (> args.length 0) ":args for and should not be empty"

    if (is args.length 1) $ do
      return $ decideSolution (. args 0) :expression

    var
      self $ . dictionary :and
    return $ {}
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
    return $ {}
      :type :LogicalExpression
      :operator :||
      :left $ self (initial args) :expression
      :right $ decideSolution (getLast args) :expression

  :not $ \ (args environment)
    assert.array args ":not"

    return $ {}
      :type :UnaryExpression
      :operator :!
      :prefix true
      :argument $ decideSolution (first args) :expression

  :if $ \ (args environment)
    assert.array args ":if"

    var
      test $ . args 0
      consequent $ . args 1
      alternate $ . args 2
      consequentBody $ consequent.slice 1

    return $ {}
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

    return $ {}
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
      do $ var alternateAst $ {}
        :type :Identifier
        :name :undefined

    return $ {}
      :type :ConditionalExpression
      :test $ decideSolution test :expression
      :consequent $ decideSolution consequent :expression
      :alternate alternateAst

  :-- $ \ (args environment)
    return $ {}
      :type :Identifier
      :name :undefined

  :__call_expression__ $ \ (args environment)
    assert.array args :__call_expression__
    var
      callee $ . args 0
      args $ args.slice 1

    return $ {}
      :type :CallExpression
      :callee $ decideSolution callee :expression
      :arguments $ args.map $ \ (item)
        return $ decideSolution item :expression

  :is $ \ (args environment)
    assert.array args :is
    return $ {}
      :type :BinaryExpression
      :operator :===
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :isnt $ \ (args environment)
    assert.array args :isnt
    return $ {}
      :type :BinaryExpression
      :operator :!==
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :> $ \ (args environment)
    assert.array args :>
    return $ {}
      :type :BinaryExpression
      :operator :>
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :>= $ \ (args environment)
    assert.array args :>=
    return $ {}
      :type :BinaryExpression
      :operator :>=
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :< $ \ (args environment)
    assert.array args :<
    return $ {}
      :type :BinaryExpression
      :operator :<
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :<= $ \ (args environment)
    assert.array args :<=
    return $ {}
      :type :BinaryExpression
      :operator :<=
      :left $ decideSolution (. args 0) :expression
      :right $ decideSolution (. args 1) :expression

  :debugger $ \ (args environment)
    return $ {}
      :type :DebuggerStatement

  :continue $ \ (args environment)
    return $ {}
      :type :ContinueStatement
      :label null

  :break $ \ (args environment)
    return $ {}
      :type :BreakStatement
      :label null

  :new $ \ (args environment)
    assert.array args :new
    var
      callee $ . args 0
      args $ args.slice 1
    return $ {}
      :type :NewExpression
      :callee $ decideSolution callee :expression
      :arguments $ args.map $ \ (item)
        return $ decideSolution item :expression

  :throw $ \ (args environment)
    assert.array args :throw
    var
      argument $ . args 0
    assert.defined argument ":argument of throw"
    return $ {}
      :type :ThrowStatement
      :argument $ decideSolution argument :expression

  :? $ \ (args environment)
    assert.array args :?
    var
      value $ . args 0
    return $ {}
      :type :BinaryExpression
      :operator :!=
      :left $ decideSolution value :expression
      :right $ {}
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
    return $ {}
      :type :TryStatement
      :block $ decideSolution block :expression
      :finalizer null
      :handler $ {}
        :type :CatchClause
        :param $ makeIdentifier param
        :body $ {}
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
    return $ {}
      :type :SwitchStatement
      :discriminant $ decideSolution discriminant :expression
      :cases $ cases.map $ \ (item)
        assert.array item ":case of switch"
        var
          test $ . item 0
          consequent $ item.slice 1
          consequentCode $ listUtil.append consequent (array :break)
        return $ {}
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
    return $ {}
      :type :CallExpression
      :arguments $ []
      :callee $ {}
        :type :ArrowFunctionExpression
        :id null
        :params $ []
        :extra $ {}
          :parenthesized true
        :generator false
        :async false
        :body $ {}
          :type :BlockStatement
          :body $ []
            object
              :type :SwitchStatement
              :discriminant $ decideSolution discriminant :expression
              :cases $ cases.map $ \ (item)
                assert.array item ":case of switch"
                var
                  test $ . item 0
                  consequent $ item.slice 1
                return $ {}
                  :type :SwitchCase
                  :test $ cond (is test :else) null
                    decideSolution test :expression
                  :consequent $ consequent.map $ \ (item index)
                    return $ cond (is index (- consequent.length 1))
                      object
                        :type :ReturnStatement
                        :argument $ decideSolution item :expression
                      decideSolution item :expression
          :directives $ []

  :... $ \ (args environment)
    if (is args.length 1)
      do
        assert.array args :spread
        var
          argument $ . args 0
        assert.string :argument ":argument of spread"
        return $ {}
          :type :SpreadElement
          :argument $ makeIdentifier argument
      do
        assert.array args ":chain"
        return $ buildChain args
    , undefined

  :import $ \ (args environment)
    if (not (is args.length 2) )
      do
        throw $ new Error ":length need to be 2"
    var source (. args 0)
    assert.string source ":Path should be a string"
    = source $ source.slice 1
    if (is :string (type (. args 1)))
      do
        var target $ . args 1
        return $ {} (:type :ImportDeclaration)
          :specifiers $ []
            {} (:type :ImportDefaultSpecifier)
              :local $ {} (:type :Identifier) (:name target)
          :source $ {} (:type :StringLiteral)
            :extra $ {} (:rawValue source) (:raw (JSON.stringify source))
            :value source
      do
        var targets $ . args 1
        assert.array targets ":targets should be array"
        var specifiers $ targets.map $ \ (x)
          assert.string x ":a specifier is a string"
          return $ {} (:type :ImportSpecifier)
            :imported $ {} (:type :Identifier) (:name x)
            :local $ {} (:type :Identifier) (:name x)
        return $ {} (:type :ImportDeclaration)
          :specifiers specifiers
          :source $ {} (:type :StringLiteral)
            :extra $ {} (:rawValue source) (:raw (JSON.stringify source))
            :value source
    , undefined

  :export $ \ (args environment)
    if (not (is args.length 2))
      do $ throw $ new Error ":export expects 1 argument"
    var target $ . args 0
    switch target
      :default $ do
        var expression $ . args 1
        return $ {} (:type :ExportDefaultDeclaration)
          :declaration $ cond (is :string (type expression))
            readToken expression
            transformOperation expression
      :var
        return $ {} (:type :ExportNamedDeclaration) (:specifiers $ []) (:source null)
          :declaration $ transformOperation args
      :let
        throw $ new Error ":TODO export let"
      else
        throw $ new Error ":Unknown export"
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
    return $ {}
      :type :ClassDeclaration
      :id $ makeIdentifier className
      :superClass $ cond (? superClass)
        makeIdentifier superClass
        , null
      :body $ {}
        :type :ClassBody
        :body $ classMethods.map $ \ (pair)
          assert.result (is pair.length 2) ":MethodDefinition"
          var
            keyName $ first pair
            prefix $ []
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
          return $ {}
            :type :MethodDefinition
            :key $ makeIdentifier keyName
            :value $ decideSolution definition :expression
            :kind kind
            :static isStatic
            :computed false

= (. dictionary :=) (. dictionary :__assgin__)
= (. dictionary :;) (. dictionary :--)

= exports.transform $ \ (tree)
  var
    environment :statement
    isModule false
    list $ tree.map $ \ (line)
      if (is :import (. line 0)) $ do
        = isModule true
      if (is :export (. line 0)) $ do
        = isModule true

      return $ decideSolution line environment

  {}
    :type :File
    :errors $ []
    :program $ {}
      :type :Program
      :sourceType $ cond isModule :module :script
      :interpreter null
      :body list
      :directives ([])
