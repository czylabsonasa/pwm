Play with Makie

some simple demos in GLMakie@Julia
```
include("deps.jl")
# for shorter waiting times compile a sysimage...
include("init.jl") # oc. Revise is not a must
using PwM
bracket("bs") # bracket() will print out the available methods
numint("trap") # numint() for help
```
* motto: you can use makie without any clue about it.
* my main problem is to separate the computation and visualization - i'll make some effort this direction
  * currently i am searching for an easy/clear/general way to combine them together


