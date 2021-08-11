include("../pddl_graph/create_graph.jl")
include("../pddl_graph/create_problem.jl")
using JuMP
import GLPK, Gurobi
import LinearAlgebra

# domain_path = "pddl_graph/pddl/blocksworld/domain.pddl"
# problem_path = "pddl_graph/pddl/blocksworld/problem1.pddl"
weights = [57, 10, 30]#, 22, 80]#, 94, 11, 81, 70, 64]#, 59, 18, 10, 36, 3, 8, 15, 42, 9, 10,42, 47, 52, 32, 26, 48, 55, 6, 29, 84, 2, 4, 18, 56, 7, 29, 93, 44, 71, 3, 86, 66, 31, 65, 0, 79, 20, 65, 52, 13]
N = length(weights)
items = [string(i) for i in 1:N]
values = ones(N)
max_cpty = 40

domain_path, problem_path = create_grocery_problem(items, "packing")
dom, prob = get_domain_problem_objects(domain_path, problem_path)
tree = create_causal_graph_more(dom, prob, max_depth=10E5)
pais, actions, action_mapping = get_edge_action_pairs_more(tree)
gid = get_goal_id(dom, prob, tree)
iid = get_init_id(dom, prob, tree)

G = create_adjacency_matrix(tree,pais)



println("Setting up optimization...")
n = size(G)[1]
println("Decision variable matrix size: ",size(G))
shortest_path = Model(Gurobi.Optimizer)

#plan variable
@variable(shortest_path, x[1:n, 1:n], Bin)
#object variable
@variable(shortest_path, y[1:N], Bin)

#task plan constraints
@constraint(shortest_path, [i=1:n, j=1:n; G[i,j]==0], x[i,j]==0)
@constraint(shortest_path, [i=1:n; i!=iid && i!=gid], sum(x[i,:])==sum(x[:,i]))
@constraint(shortest_path, sum(x[iid,:]) - sum(x[:,iid])==1)
@constraint(shortest_path, sum(x[gid,:]) - sum(x[:,gid])==-1)
# @constraint(shortest_path, [i=1:n, j=1:n, k=1:N; y[k]==0])

 #=
for p in action_mapping
    act = p[2]
    if act != nothing
        item_indices = []
        for obj in act.args
            # item_ind = findall(x->x==string(obj), items)
            # println("constraint on " , item_ind)
            # for i in item_ind
            #     @constraint(shortest_path, x[p[1][1], p[1][2]] == y[i])
            #     # @constraint(shortest_path, x[p[1][2], p[1][1]] == y[i])
            # end
            if obj in unpacked_items
                @constraint(shortest_path, x[p[1],p[2]] == 0)
            end
        end
    end
end
=#


#weight inequality constraint
@constraint(shortest_path, weights' * y <= max_cpty)

#shortest plan + largest num items objective function
@objective(shortest_path, Min, LinearAlgebra.dot(G, x) - values' * y)
# println(shortest_path)
println("Optimizing...")

optimize!(shortest_path)

solution = value.(x)
cartesian_indices = findall(x->x==1, solution)
plan = format_plan(tree, cartesian_indices, action_mapping, iid)
# println("Plan: ",plan)

items_to_pack =  findall(x->x==1, value.(y))
items_packed = []
println(string(length(items_to_pack))*" items to pack: ", items_to_pack)
for pa in plan
    for obj in pa.args
        push!(items_packed, obj)
    end
end
println(string(length(Set(items_packed)))*" items packed: ", Set(items_packed))
weights_packed = [weights[i] for i in items_to_pack]
println("weights of items: ", weights_packed)
println("sum weights: ", sum(weights_packed))
draw_graph(tree)
