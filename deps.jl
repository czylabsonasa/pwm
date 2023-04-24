import Pkg
deps=[
  "Revise",
  "GLMakie",
  "Printf", "LaTeXStrings",
  # "LinearAlgebra",
]


Pkg.add.(deps)

#
Pkg.instantiate()
