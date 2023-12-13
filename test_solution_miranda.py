# Import libraries
import os
import json
from sympy import sympify, roots, lambdify
import numpy as np
import matplotlib.pyplot as plt

# Precision to be float64
np.set_printoptions(precision=64)


# Parameters
# Define constants
tree_folder = "RK_rootedtrees"
solution_folder = "RK_solutions"
rk_problem = "RK_s3p3"
# Split to get the sNpM part
rk_problem_sp = rk_problem.split("_")[-1]
# solution_file = rk_problem + "_solution_kutta.txt"
solution_file = rk_problem + "_solution_v0.txt"
tree_file = "ERK_equations_" + rk_problem_sp + ".json"
solution_path = os.path.join(solution_folder, solution_file)
tree_path = os.path.join(tree_folder, tree_file)

# epsilon_value = 1e-14
# epsilon_value = np.finfo(float).eps
epsilon_value = np.sqrt(np.finfo(float).eps)
print("epsilon_value: ", epsilon_value)

def main():
    
    print("Running the test_solution_miranda.jl script...")
    
    # 1 - Load the data from the solution file as float values
    with open(solution_path, "r") as f:
        coeffs = [float(line.strip()) for line in f]
        
    # 2 - Determine bounds a=min(coeffs), b=max(coeffs)
    min_val = min(coeffs) - epsilon_value   #100*np.sqrt(epsilon_value)
    max_val = max(coeffs) + epsilon_value   #100*np.sqrt(epsilon_value)
    
    # # Define interval
    # X = [min_val, max_val]
    
    # 3 - Evaluate the order conditions for the solution but with one component changed to a then b
    with open(tree_path, 'r') as f:
        data = json.load(f)
    variables = data["variables"]
    equations = data["equations"]
    
    # Convert to sympy
    variables_sym = [sympify(var) for var in variables]
    equations_sym = [sympify(eq) for eq in equations]
    
    # Create dict to match variables with values
    X_dict = {var:coeffs[i] for (i, var) in enumerate(variables_sym)}
    
    print(f'X_dict: {X_dict}')
    
    # Loop over the equations and variables to evaluate X as each solution
    for eq in equations_sym:
        # Loop over the variables and substitute by min and max and evaluate
        # Print intervals eq(vars, min) and eq(vars, max)
        for var in variables_sym:
            if eq.has(var):
                # Create copy of dict
                X_dict_min = X_dict.copy()
                X_dict_min[var] = min_val 
                
                X_dict_max = X_dict.copy()
                X_dict_max[var] = max_val
                
                
                
                # Substitute values
                eq_subs_min = float(eq.subs(X_dict_min))
                eq_subs_max = float(eq.subs(X_dict_max))
                
                root_found = np.sign(eq_subs_min) != np.sign(eq_subs_max)
                
                print(f"{str(eq):45s} -> {str(var):6s} -> interval " \
                    f"= ({eq_subs_min:.3e}, {eq_subs_max:.3e}) " \
                    f"-> root found = {root_found}")  
                
                if not root_found:
                    # Create a function to evaluate the equation
                    # Substitute var by its symbol
                    X_dict_sym = X_dict.copy()
                    X_dict_sym[var] = var
                    print(f"X_dict_sym: {X_dict_sym}")
                    # Substitute values
                    eq_subs_sym = eq.subs(X_dict_sym)
                    print(f"eq_subs_sym: {eq_subs_sym}")
                    # Find roots
                    roots_eq = roots(eq_subs_sym)
                    print(f'min_val: {min_val}; max_val: {max_val}')
                    print(f"roots_eq: {roots_eq}")
                    # Plot eq_subs_sym in the interval [min_val, max_val]
                    plot_equation(eq, eq_subs_sym, var, min_val, max_val)
                    
                    
def plot_equation(equation, eq_subs_sym, var, min_value, max_value):
    
    # Convert symbolic equation to a numerical function
    eq_func = lambdify(var, eq_subs_sym, 'numpy')

    # Plot the equation in the interval [min_value, max_value]
    x_vals = np.linspace(min_value, max_value, 1000)
    y_vals = eq_func(x_vals)

    plt.plot(x_vals, y_vals, label=f'{eq_subs_sym}')
    # Plot horizontal line at y=0
    plt.axhline(y=0, color='k', linestyle='--')
    # Plot vertical line at x=min_value and x=max_value
    plt.axvline(x=min_value, color='k', linestyle='--')
    plt.axvline(x=max_value, color='k', linestyle='--')

    # Set labels and title
    plt.xlabel(var)
    plt.ylabel(str(eq_subs_sym))
    plt.title(f'{equation}')

    # Show legend
    plt.legend()

    # Show the plot
    plt.show()
                    


if __name__ == '__main__':
    main()