include("../pddl_graph/create_graph.jl")
domain = load_domain("pddl_graph/pddl/blocksworld/domain.pddl")
problem =  load_problem("pddl_graph/pddl/blocksworld/hard_problem.pddl")

@time tree = create_causal_graph_ff(domain, problem; max_depth=1e10)
draw_graph(tree)
# println("Number of states: ",length(tree))
# id_dict = get_state_int_id_dict(tree)
# pais, actions, pair_action_dict = get_edge_action_pairs(tree)
# print_id_to_state(tree, id_dict)
# println(pair_action_dict)
# matrix = create_adjacency_matrix(tree, pais)

# get_goal_id(domain, problem, id_dict, tree)
