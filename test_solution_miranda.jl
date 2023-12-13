# Load the necessary packages
using SymPy
using DelimitedFiles
using JSON
using IntervalArithmetic

# Define constants
tree_folder = "RK_rootedtrees"
solution_folder = "RK_solutions"
rk_problem = "RK_s3p3"
# Split to get the sNpM part
rk_problem_sp = split(rk_problem, "_")[2]
solution_file = string(rk_problem, "_solution_v0.txt")
tree_file = string("ERK_equations_", rk_problem_sp, ".json")
solution_path = joinpath(solution_folder, solution_file)
tree_path = joinpath(tree_folder, tree_file)

# Create the main function
function main()

    println("Running the test_solution_miranda.jl script...")
    # 1 - Load the data from the solution file
    data = readdlm(solution_path)
    coeffs = data[:, 1]
    # println(coeffs)

    # 2 - Determine bounds a=min(coeffs), b=max(coeffs)
    a = minimum(coeffs)
    b = maximum(coeffs)
    # println("a = ", a)
    # println("b = ", b)

    # Define interval
    X = a .. b
    # println("X = ", X)

    # 3 - Evaluate the order conditions for the solution but with one component changed to a then b
    # Load equation functions from tree file
    json_str = read(tree_path, String)
    data = JSON.parse(json_str)
    variables = data["variables"]
    equations = data["equations"]
    # println("\nVariables for the $(rk_problem)):")
    # println(variables)
    # println("\nEquations for the $(rk_problem)):")
    # println(equations)

    # Create variables as symbols
    variables_sym = [symbols(Symbol(var), real=true) for var in variables[1:end]]
    # Convert vector of symbols to list of symbols
    # variables_sym = Symbol.(variables_sym)
    println(typeof(variables_sym))
    println(variables_sym)

    # # Define vars
    # @vars variables_sym

    # # Create symbolic variables
    # @vars Symbol.(variables)
    # # Print the defined symbolic variables
    # println(Symbol.(variables))

    # Convert expressions to symbolic objects
    equations_sym = [sympify(eq) for eq in equations]
    # equations_sym = [Symbol(eq) for eq in equations]
    println(equations_sym)

    # # List of strings representing variable names
    # variable_names = ["aa", "bb", "cc"]
    # # Create symbolic variables
    # @vars a1, b2, c3
    # # Print the defined symbolic variables
    # println(a1)
    # println(b2)
    # println(c3)

    # Create dict to match variables with values
    X_dict = Dict(var => coeffs[i] for (i, var) in enumerate(variables_sym))

    println(X_dict)

    # # Loop over the equations and variables to evaluate X as each solution
    # for (i, eq) in enumerate(equations)
    #     # println("\nEquation $(i):")
    #     # println(eq)
    #     # for (j, var) in enumerate(variables)
    #     #     # Check if the variable is in the equation
    #     #     if occursin(var, eq)
    #     #         println("\nVariable $(j): $(var) ... $(X_dict[var])")

    #     #     end    
    #     # end
    #     # Evaluate variables values in the equation
    #     eq_eval = eval(eq, X_dict)
    #     println("\nEquation $(i) evaluated:")
    #     println(eq_eval)
    # end

    # Loop over the equations and variables to evaluate X as each solution
    for (i, eq) in enumerate(equations_sym)

        # println("\nEquation $(i):")
        println(eq)
        # println(typeof(eq))

        # print("\nCoeffs: ")
        # println(typeof(coeffs))

        # Find the variables in the equation and create a list of tuples with the variable and its value
        var_values = [(var, coeffs[i]) for (i, var) in enumerate(variables_sym) if occursin(string(var), string(eq))]   

        println(var_values)

        @vars variables_sym[1:end]

        eq_eval = eq.subs([(b_1, 0.701310920909321), (b_2, 0.5796676749090314), (b_3, -0.28097859581835233)])


        println(eq_eval)

        # Substitute variable values into the symbolic expression
        # Substitute variable values into the expression
        # eq_eval = substitute(eq, coeffs)

        # println("\nEquation $(i) evaluated:")
        # println(eq_eval)

        # equation = lambdify(variables_sym, eq)
        # println(equation)
        # eq_eval = equation(coeffs...)
        # println(eq_eval)




        # eq_with_values = eq

        # # # Replace variables in the equation with their values from X_dict
        # # for (var, value) in X_dict
        # #     eq_with_values = replace(eq_with_values, var => value))
        # # end

        # # println(eq_with_values)
        # # println(eq(coeffs))
        # # Evaluate the modified equation
        # eq_eval = eval(eq, 
        # println(eq_eval)

        # # println(eq)
        # # println(typeof(eq))

        # # Convert the equation string to a symbolic expression
        # eq_sym = Sym(eq)
        # Substitute variable values into the expression
        # eq_eval = eval(interpolate_from_dict(eq, X_dict))

        # println("\nEquation $(i) evaluated:")
        # println(eq_eval)
    end

end


# Function to perform substitution in an Expr
function substitute(expr, substitutions)
    return map(x -> x isa Symbol ? get(substitutions, x, x) : x, expr)
end

main()