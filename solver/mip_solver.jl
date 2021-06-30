include("../pddl_graph/make_graph.jl")

using JuMP
import GLPK
import LinearAlgebra

function mip_planner(domain_path, problem_path)
    dom, prob = get_domain_problem_objects(domain_path, problem_path)
    tree = create_causal_graph(dom, prob, max_depth=100)
    action_mapping = get_edge_action_dict(tree)
    gid = get_goal_id(prob, dom, tree)

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
    
    solution = value.(x)
    cartesian_indices = findall(x->x==1, solution)
    plan = format_plan(tree, cartesian_indices)
    return plan
end



# =#
# println(cartesian_indices)
# solution
#TO DO: fix sequence of actions
# draw_graph(tree)
