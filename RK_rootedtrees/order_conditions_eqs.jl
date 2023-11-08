## RootedTrees.jl
using RootedTrees, SymPy

## Groebner.jl
using DynamicPolynomials, Groebner

##To save/load the s-o RK equations 
using JSON, FileIO


function print_help()
    println("Usage: julia order_conditions_eqs.jl <num-stages> <order>")
    println()
end


function generateRootedTrees(s, p, exp = true)

    variables = []

    if exp
        A = Array{Sym,2}(undef,s,s)
        for i = 1:s
            for j = 1:i-1
                A[i,j] = symbols("a_$(i)$(j)", real=true)
                push!(variables, A[i,j])
            end
            for j = i:s
                A[i,j] = 0
            end
        end
    else
        A = [symbols("a_$(i)$(j)", real=true) for i in 1:s, j in 1:s]
    end

    b = [symbols("b_$(i)", real=true) for i in 1:s]
    for i in 1:s
        push!(variables, b[i])
    end

    rk = RungeKuttaMethod(A, b)

    ## Define an empty array to store the results
    equations = []

    for o in 1:p
        for t in RootedTreeIterator(o)
            # Compute the residual order condition and append it to the results array
            residual = residual_order_condition(t, rk)
            push!(equations, residual)
        end
    end

    return variables, equations
end


function rk_system2groebner(variables, equations, file_name) 

    for (i, eq) in enumerate(equations)
        num_coeff = eq.args[1]
        equations[i] = eq * (- 1 / num_coeff)
    end

    ## Identify the equation terms
    equation_terms = []
    for (i, eq) in enumerate(equations)
        terms = []
        for term in eq.args
            term = :($term)
            term = simplify(term)
            push!(terms, term)
        end
        push!(equation_terms, terms)
    end

    # Create a dictionary with the data
    variables_str = string.(variables)
    equations_str = string.(equations)

    equation_terms_str = []
    for eq_term in equation_terms
        eq_term_str = string.(eq_term)
        push!(equation_terms_str, eq_term_str)
    end
    # equation_terms_str = string.(equation_terms_str)

    println("\nEquation terms:")    
    println(equation_terms_str)

    data = Dict("variables" => variables_str, "equations" => equations_str, "equation_terms" => equation_terms_str)

    # Save the data in a JSON file
    json_str = JSON.json(data)
    open(file_name, "w") do f
        write(f, json_str)
    end

    return equations

end


function main()
    if length(ARGS) == 0 || "-h" in ARGS || "--help" in ARGS
        print_help()
    else
        try
            num_stages, order = parse(Int, ARGS[1]), parse(Int, ARGS[2])

            file_name = "ERK_equations_s$(num_stages)p$(order).json"

            variables, equations = generateRootedTrees(num_stages, order)

            # println("\nVariables for the RK(s=$(num_stages), p=$(order)):")
            # println(variables)
            # println("\nEquations for the RK(s=$(num_stages), p=$(order)):")
            # println(equations)

            equations_groebner = rk_system2groebner(variables, equations, file_name)

            println("\nGroener equations for the RK(s=$(num_stages), p=$(order)):")
            println(equations_groebner)

        catch e
            println("Error: ", e)
            print_help()
        end
    end
end

main()