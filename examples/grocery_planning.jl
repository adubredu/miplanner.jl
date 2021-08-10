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
indices_not_packed = findall(x->x==0, value.(y))
items_packed = [items[i] for i in indices_packed]

####
domain_path, problem_path = create_grocery_problem(items_packed, "packing")
# plan = mip_planner(domain_path, problem_path)


dom, prob = get_domain_problem_objects(domain_path, problem_path)
tree = create_causal_graph_ff(dom, prob, max_depth=1000000)

pais, actions, action_mapping = get_edge_action_pairs(tree)
gid = get_goal_id(dom, prob, tree)
iid = get_init_id(dom, prob, tree)
println("Action mapping: ", action_mapping)
G = create_adjacency_matrix(tree,pais)

penalty = 999
unpacked_items = [items[i] for i in indices_not_packed]
println("Unpacked items: ", unpacked_items)
for p in action_mapping
    act = p[2]
    if act != nothing
        for obj in act.args
            if obj in unpacked_items
                G[p[1],p[2]] = penalty
            end
        end
    end
end

# println(G)


println("Setting up optimization...")
n = size(G)[1]
println("Decision variable matrix size: ",size(G))
shortest_path = Model(GLPK.Optimizer)

@variable(shortest_path, x[1:n, 1:n], Bin)
@constraint(shortest_path, [i=1:n, j=1:n; G[i,j]==0], x[i,j]==0)
@constraint(shortest_path, [i=1:n; i!=iid && i!=gid], sum(x[i,:])==sum(x[:,i]))
@constraint(shortest_path, sum(x[iid,:]) - sum(x[:,iid])==1)
@constraint(shortest_path, sum(x[gid,:]) - sum(x[:,gid])==-1)

@objective(shortest_path, Min, LinearAlgebra.dot(G, x))

@time optimize!(shortest_path)

solution = value.(x)
cartesian_indices = findall(x->x==1, solution)
plan = format_plan(tree, cartesian_indices, action_mapping, iid)
return plan

println("\nPlan: ", plan)
