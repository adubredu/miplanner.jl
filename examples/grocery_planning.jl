include("../pddl_graph/create_problem.jl")
include("../solver/mip_solver.jl")

using JuMP
import GLPK
import LinearAlgebra

weights = [7, 10, 30, 22, 80, 94, 11, 81]
items = ["chocolate", "comb", "spam", "mustard", "bleach", "sugar", "banana", "soup"]

N = length(weights)
values = ones(N)
max_cpty = 200

grocery_model = Model(GLPK.Optimizer)
@variable(grocery_model, y[1:N], Bin)
@constraint(grocery_model, weights' * y <= max_cpty)
@objective(grocery_model, Max, values' * y)

optimize!(grocery_model)

indices_packed =  findall(x->x==1, value.(y))
items_packed = [items[i] for i in indices_packed]

domain_path, problem_path = create_grocery_problem(items_packed, "packing")
plan = mip_planner(domain_path, problem_path)

println("\nPlan: ", plan)
