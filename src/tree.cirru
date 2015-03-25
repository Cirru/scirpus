
= map
  :Literal $ \ (value)
    object (:type :Literal)
      :value value
      :raw $ String value
  :Identifier $ \ (value)
    object $ :Identifier value
  :BinaryExpression $ \ (operator left right)
    object (:type :BinaryExpression)
      :operator operator
      :left $ resolve left
      :right $ resolve right
  :ExpressionStatement $ \ (expression)
    object (:type ExpressionStatement) $ :expression expression
  :Program $ \ (data)
    object (:type :Program) $ :body (resolve data)
  :do $ \ list (list.map resolve)
  :AssignmentExpression $ \ (operator left right)
    object (:operator operator)
      :left left
      :right right

= resolve $ \ (data)
  = name $ . data 0
  = func $ . map name
  if (? func)
    do $ func.apply @ (data.slice 1)
    do $ throw
      new Error $ ++: :not-defined func