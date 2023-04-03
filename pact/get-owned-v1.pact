(interface get-owned-v1
  (defun get-owned:[object] (account:string)
    @doc "Get all owned objects of a given account"
  )

  (defun get-uri:string (id:string)
    @doc "Get the URI of an object"
  )
)