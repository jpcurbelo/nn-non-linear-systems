# findRKgroebner.jl
Script to find the Groebner basis of a RK problem given the number of stages (s)
and order (p). The script uses the RootedTrees.jl (https://github.com/SciML/RootedTrees.jl) 
and Groebner.jl (https://github.com/sumiya11/Groebner.jl) packages.

## Getting started
Auxiliar packages to be added
### RootedTrees.jl
add RootedTrees, SymPy
### Groebner.jl
add DynamicPolynomials, Groebner
### To save/load RK equations
add JSON
add FileIO
add JLD2

## How to use it
"julia findRKgroebner.jl <num-stages\> <order\>"