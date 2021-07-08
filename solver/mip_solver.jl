include("../pddl_graph/create_graph.jl")

using JuMP
import GLPK, Gurobi
import LinearAlgebra

function mip_planner(domain_path, problem_path)
    dom, prob = get_domain_problem_objects(domain_path, problem_path)
    tree = create_causal_graph(dom, prob, max_depth=1000000)
    pais, actions, action_mapping = get_edge_action_pairs(tree)
    gid = get_goal_id(dom, prob, tree)
    iid = get_init_id(dom, prob, tree)

    G = create_adjacency_matrix(tree,pais)
    println("Setting up optimization...")
    n = size(G)[1]
    println("Decision variable matrix size: ",size(G))
    shortest_path = Model(Gurobi.Optimizer)

    @variable(shortest_path, x[1:n, 1:n], Bin)
    @constraint(shortest_path, [i=1:n, j=1:n; G[i,j]==0], x[i,j]==0)
    @constraint(shortest_path, [i=1:n; i!=iid && i!=gid], sum(x[i,:])==sum(x[:,i]))
    @constraint(shortest_path, sum(x[iid,:]) - sum(x[:,iid])==1)
    @constraint(shortest_path, sum(x[gid,:]) - sum(x[:,gid])==-1)

    @objective(shortest_path, Min, LinearAlgebra.dot(G, x))

    optimize!(shortest_path)

    solution = value.(x)
    cartesian_indices = findall(x->x==1, solution)
    plan = format_plan(tree, cartesian_indices, action_mapping, iid)
    return plan
end



# =#
# println(cartesian_indices)
# solution
#TO DO: fix sequence of actions
# draw_graph(tree)
