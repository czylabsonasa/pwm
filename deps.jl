import Pkg
deps=[
  "Revise",
  "GLMakie",
  "Printf", "LaTexStrings",
  # "LinearAlgebra",
]


Pkg.add.(deps)

#
Pkg.instantiate()
