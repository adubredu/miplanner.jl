using JuMP
import GLPK, Gurobi
import LinearAlgebra


weights = [7, 10, 30, 22, 80, 94, 11, 81, 70, 64, 59, 18, 10, 36, 3, 8, 15, 42, 9, 10,42, 47, 52, 32, 26, 48, 55, 6, 29, 84, 2, 4, 18, 56, 7, 29, 93, 44, 71, 3, 86, 66, 31, 65, 0, 79, 20, 65, 52, 13]

N = length(weights)
values = ones(N)
max_cpty = 850

grocery_model = Model(GLPK.Optimizer)
@variable(grocery_model, y[1:N], Bin)
# @constraint(grocery_model, [i=1:N], y[i] <= 1)
@constraint(grocery_model, weights' * y <= max_cpty)
@objective(grocery_model, Max, values' * y)

optimize!(grocery_model)

println("objective value: ", objective_value(grocery_model))
items_packed =  findall(x->x==1, value.(y))
println("items packed: ", items_packed)
weights_packed = [weights[i] for i in items_packed]
println("weights of items: ", weights_packed)
println("sum weights: ", sum(weights_packed))
