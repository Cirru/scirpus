
= map $ object
  :Literal $ \ (value)
    object (:type :Literal)
      :value value
      :raw $ String value

  :Identifier $ \ (name)
    object (:type :Identifier)
      :name name

  :BinaryExpression $ \ (operator left right)
    object (:type :BinaryExpression)
      :operator operator
      :left $ resolve left
      :right $ resolve right

  :ExpressionStatement $ \ (expression)
    object (:type ExpressionStatement) $ :expression expression

  :Program $ \ (data)
    object (:type :Program) $ :body (resolve data)

  :each $ \ list
    list.map resolve

  :AssignmentExpression $ \ (operator left right)
    object (:operator operator)
      :left left
      :right right

  :EmptyStatement $ \ ()
    object $ :type :EmptyStatement

  :BlockStatement $ \ (body)
    object (:type :BlockStatement) $ :body (resolve body)

  :IfStatement $ \ (test consequent alternate)
    object (:type :IfStatement)
      :test $ resolve test
      :consequent $ resolve consequent
      :alternate $ resolve alternate

  :LabeledStatement $ \ (label body)
    object
      :label $ resolve label
      :body $ resolve body

  :BreakStatement $ \ (label)
    object (:type :BreakStatement) $ :label (resolve label)

  :WithStatement $ \ (object body)
    object (:type :WithStatement)
      :object $ resolve body
      :body $ resolve body

  :ReturnStatement $ \ (argument)
    object (:type :ReturnStatement) $ :argument (resolve argument)

  :ThrowStatement $ \ (argument)
    object (:type :ThrowStatement) $ :argument (resolve argument)

  :TryStatement $ \ (block handler finalizer)
    object (:type :TryStatement)
      :block $ resolve block
      :handler $ resolve handler
      :finalizer $ resolve finalizer

  :WhileStatement $ \ (test body)
    object (:type :WhileStatement)
      :test $ resolve test
      :body $ resolve body

  :DoWhileStatement $ \ (body test)
    object (:type :DoWhileStatement)
      :body $ resolve body
      :test $ resolve test

  :ForStatement $ \ (init test update body)
    object (:type :ForStatement)
      :init $ resolve init
      :test $ resolve test
      :update $ resolve update
      :body $ resolve body

  :ForInStatement $ \ (left right body)
    object (:type :ForInStatement)
      :left $ resolve left
      :right $ resolve right
      :body $ resolve body
      :each false

  :ForOfStatement $ \ (left right body)
    object
      :left $ resolve left
      :right $ resolve right
      :body $ resolve body

  :DebuggerStatement $ \ ()
    object $ :type :DebuggerStatement

  :FunctionDeclaration $ \ (id params body)
    object (:type :FunctionDeclaration)
      :id $ resolve id
      :params $ resolve params
      :defaults $ array
      :rest null
      :body $ resolve body
      :generator false
      :expression false

  :VariableDeclaration $ \ (declarations)
    object (:type :VariableDeclaration)
      :declarations (resolve declarations)
      :kind :var

  :VariableDeclarator $ \ (id init)
    object (:type :VariableDeclarator)
      :id $ resolve id
      :init $ resolve init

  :ThisExpression $ \ ()
    object $ :type :ThisExpression

  :ArrayExpression $ \ (elements)
    object (:type :ArrayExpression) $ :elements (resolve elements)

  :ObjectExpression $ \ (properties)
    object (:type :ObjectExpression) $ :properties (resolve properties)

  :Property $ \ (key value kind)
    object (:type :Property)
      :key $ resolve key
      :value $ resolve value
      :kind kind

  :FunctionExpression $ \ (id params body)
    object (:type :FunctionExpression)
      :id $ resolve id
      :params $ resolve params
      :defaults $ array
      :rest null
      :body $ resolve body
      :generator false
      :expression false

  :ArrowExpression $ \ (params body)
    object (:type :ArrowExpression)
      :params $ resolve params
      :defaults $ array
      :rest null
      :body $ resolve body
      :generator false
      :expression false

  :SequenceExpression $ \ (expressions)
    object (:type :SequenceExpression) $ :expressions (resolve expressions)

  :UnaryExpression $ \ (operator argument)
    object (:type :UnaryExpression)
      :operator operator
      :prefix true
      :argument $ resolve argument

  :UpdateExpression $ \ (operator argument)
    object (:type :UpdateExpression)
      :operator operator
      :argument $ resolve argument
      :prefix false

  :LogicalExpression $ \ (operator left right)
    object (:type :LogicalExpression)
      :operator operator
      :left $ resolve left
      :right $ resolve right

  :ConditionalExpression $ \ (test alternate consequent)
    object (:type :ConditionalExpression)
      :test $ resolve test
      :left $ resolve left
      :right $ resolve right

  :NewExpression $ \ (callee arguments)
    object (:type :NewExpression)
      :callee $ resolve callee
      :arguments $ resolve arguments

  :CallExpression $ \ (callee arguments)
    object (:type :CallExpression)
      :callee $ resolve callee
      :arguments $ resolve arguments

  :MemberExpression $ \ (object property computed)
    object (:type :MemberExpression)
      :object $ resolve object
      :property $ resolve property
      :computed computed

  :ObjectPattern $ \ (properties)
    object (:type :ObjectPattern) $ :properties (resolve properties)

  :pair $ \ (key value)
    object
      :key $ resolve key
      :value $ resolve value

  :ArrayPattern $ \ (elements)
    object (:type :ArrayPattern) $ :elements (resolve elements)

  :SwitchCase $ \ (test consequent)
    object (:type :SwitchCase)
      :test $ resolve test
      :consequent $ resolve consequent

  :CatchClause $ \ (param body)
    object (:type :CatchClause)
      :param $ resolve param
      :guard null
      :body $ resolve body

= resolve $ \ (data)
  = name $ . data 0
  = func $ . map name
  if (? func)
    do $ func.apply this (data.slice 1)

    do
      throw $ new Error (++: :not-defined func)
      return false

= exports.resolve $ \ (data)
  resolve data
