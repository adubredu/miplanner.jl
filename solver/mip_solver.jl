include("../pddl_graph/make_graph.jl")

using JuMP
import GLPK
import LinearAlgebra

dom, prob = get_domain_problem_objects("pddl_graph/pddl/blocksworld/domain.pddl", "pddl_graph/pddl/blocksworld/problem4.pddl")
tree = create_causal_graph(dom, prob, max_depth=100)
action_mapping = get_edge_action_dict(tree)
gid = get_goal_id(prob, dom, tree)
# draw_graph(tree)

G = create_adjacency_matrix(tree)
println("Setting up optimization...")
n = size(G)[1]
shortest_path = Model(GLPK.Optimizer)

@variable(shortest_path, x[1:n, 1:n], Bin)
@constraint(shortest_path, [i=1:n, j=1:n; G[i,j]==0], x[i,j]==0)
@constraint(shortest_path, [i=1:n; i!=1 && i!=gid], sum(x[i,:])==sum(x[:,i]))
@constraint(shortest_path, sum(x[1,:]) - sum(x[:,1])==1)
@constraint(shortest_path, sum(x[gid,:]) - sum(x[:,gid])==-1)

@objective(shortest_path, Min, LinearAlgebra.dot(G, x))

@time optimize!(shortest_path)
# objective_value(shortest_path)
solution = value.(x)
cartesian_indices = findall(x->x==1, solution)
plan = []
for ci in cartesian_indices
    idx = (ci[1], ci[2])
    # println(idx)
    println(action_mapping[idx])
    pushfirst!(plan, action_mapping[idx])
end
println("\nPlan: ",plan)
# =#
# cartesian_indices
#TO DO: fix sequence of actions
