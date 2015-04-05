
= makeIdentifier $ \ (name)
  object
    :type :Identifier
    :name name

= exports.Identifier makeIdentifier

= buildMembers $ \ (names)
  if (< names.length 1)
    do
      throw $ new Error ":failed with empty names"
  if (is names.length 1)
    do $ return $ decideSolution (_.first names) :expression

  return $ object
    :type :MemberExpression
    :computed false
    :object $ buildMembers (_.initial names)
    :property $ assemble.Identifier (_.last names)

= exports.Members $ \ (names)
  buildMembers names
