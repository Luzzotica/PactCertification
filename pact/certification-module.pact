(module certification-module GOV
  @doc "Certification storage module with governance and permissions"

  ;; -------------------------------
  ;; Governance

  (defconst GOV_GUARD:string "gov")

  (defcap GOV ()
    (enforce-guard (at "guard" (read m-guards GOV_GUARD ["guard"])))
  )

  (defschema m-guard
    @doc "Stores guards for the module"
    guard:guard
  )
  (deftable m-guards:{m-guard})

  (defun rotate-gov:string (guard:guard)
    @doc "Requires GOV. Changes the gov guard to the provided one."
    (with-capability (GOV)
      (update m-guards GOV_GUARD
        { "guard": guard }
      )
      "Rotated GOV to a new guard"
    )
  )

  (defun get-gov-guard:guard ()
    @doc "Gets the current gov guard and returns it"
    (at "guard" (read m-guards GOV_GUARD))
  )

  (defun init-perms:string (gov:guard)
    @doc "Initializes the guards"
    (insert m-guards GOV_GUARD
      { "guard": gov }
    )
  )

  ;; -------------------------------
  ;; String Values

  (defschema value
    @doc "Stores string values"
    value:string
  )
  (deftable values:{value})

  (defun update-string-value (val-id:string value:string)
    @doc "Updates the account for the bank"

    (with-capability (GOV)
      (write values val-id
        { "value": value }
      )
    )
  )

  (defun get-string-value:string (val-id:string)
    @doc "Gets the value with the provided id"

    (at "value" (read values val-id ["value"]))
  )

  ;; -------------------------------
  ;; Certification Governance
  
  (defschema certification-gov
    @doc "Stores the guard that governs the ability to add to versions to a certification. \
    \ The award-guard is the guard that can award the certification. Generally this will be a keyset \
    \ that allows many users to award the certification (keys-any)."
    name:string
    guard:guard
  )
  (deftable certification-govs:{certification-gov})

  (defun create-certification-gov:string 
    (
      cert-name:string
      cert-guard:guard
    )
    @doc "Requires GOV. Creates a new certification gov record with the given name and guard."
    (insert certification-govs cert-name
      { "name": cert-name
      , "guard": cert-guard 
      }
    )
    "Certification gov record created"
  )

  (defun rotate-cert-gov-guard:string 
    (
      cert-name:string
      new-guard:guard
    )
    @doc "Requires the guard of the certification record. Updates the guard for the certification."
    (with-read certification-govs cert-name
      { "guard":= cert-guard }
      (enforce-guard cert-guard)
      (update certification-govs cert-name
        { "guard": new-guard }
      )
      "Certification gov guard rotated"
    )
  )

  (defun get-certification-govs:[object{certification-gov}] ()
    @doc "Gets all the certification gov records."
    (select certification-govs (constantly true))
  )

  (defun get-certification-gov:string (cert-name:string)
    @doc "Gets the certification gov record for the given certification name."
    (read certification-govs cert-name)
  )

  ;; -------------------------------
  ;; Certification Creation

  (defschema certification
    @doc "Stores certification text and its associated guard"
    name:string
    version:string
    text:string
    awardGuard:guard
  )
  (deftable certifications:{certification})

  (defun create-certification:string 
    (
      cert-name:string
      cert-version:string
      cert-text:string 
      cert-award-guard:guard
    )
    @doc "Requires certification gov. Creates a new certification record with the given name, version, and text."
    (with-read certification-govs cert-name
      { "guard":= cert-guard }
      (enforce-guard cert-guard)
      (insert certifications (format "{}-{}" [cert-name cert-version])
        { "name": cert-name
        , "version": cert-version
        , "text": cert-text
        , "awardGuard": cert-award-guard
        }
      )
      "Certification record created"
    )
  )

  (defun rotate-certification-award-guard:string
    (
      cert-name:string
      cert-version:string
      new-guard:guard
    )
    @doc "Requires the certification gov. Updates the award guard for the certification."
    (with-read certification-govs cert-name
      { "guard":= cert-guard }
      (enforce-guard cert-guard)
      (update certifications (format "{}-{}" [cert-name cert-version])
        { "awardGuard": new-guard }
      )
      "Certification award guard rotated"
    )
  )

  (defun get-certifications:[object{certification}] ()
    @doc "Gets all the certification records."
    (select certifications (constantly true))
  )

  (defun get-certifications-for-name:[object{certification}] (cert-name:string)
    @doc "Gets all the certification records for the given certification name."
    (select certifications (where "name" (= cert-name)))
  )

  (defun get-certification:string (cert-name:string cert-version:string)
    @doc "Gets the certification text for the given certification name."
    (read certifications (format "{}-{}" [cert-name cert-version]))
  )

  ;; -------------------------------
  ;; Awarded Certifications

  (implements get-owned-v1)

  (defschema awarded-certification
    @doc "Stores the certification name, version, and the user that was awarded the certification"
    account:string
    name:string
    version:string
    dateAwarded:time
  )
  (deftable awarded-certifications:{awarded-certification})

  (defun award-certification:string
    (
      cert-name:string
      cert-version:string
      account:string
    )
    @doc "Requires the award guard of the certification. Awards the certification to the sender. \
    \ Uses block time for dateAwarded."
    (with-read certifications (format "{}-{}" [cert-name cert-version])
      { "awardGuard":= award-guard }
      (enforce-guard award-guard)
      (insert awarded-certifications (format "{}-{}-{}" [cert-name cert-version account])
        { "account": account
        , "name": cert-name
        , "version": cert-version
        , "dateAwarded": (at "block-time" (chain-data))
        }
      )
      "Certification awarded"
    )
  )

  (defun get-owned:[object] (account:string)
    @doc "Gets all the certifications awarded to the given account."
    (select awarded-certifications (where "account" (= account)))
  )

  ;; -------------------------------
  ;; URI Handling

  (defconst CERTIFICATION_URI "CERTIFICATION_URI")

  (defun get-uri:string (id:string)
    @doc "Gets the URI for the given certification ID. \
    \ The ID is the certificat name."
    (format "{}/{}" [(get-string-value CERTIFICATION_URI) id])
  )
)

(if (read-msg "upgrade")
  "Contract upgraded"
  [
    (create-table m-guards)
    (create-table certification-govs)
    (create-table certifications)
    (create-table awarded-certifications)
    (create-table values)
    (init-perms (read-msg "gov-guard"))
    (update-string-value CERTIFICATION_URI (read-msg "uri"))
  ]
)