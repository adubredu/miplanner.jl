using PDDL
using LightGraphs
using GraphPlot
using Colors

# domain = load_domain("pddl_graph/pddl/blocksworld/domain.pddl")
# problem =  load_problem("pddl_graph/pddl/blocksworld/problem.pddl")
#
# state = initialize(problem)
# state = execute(pddl"(pickup a)", state, domain)
# state = execute(pddl"(stack a b)", state, domain)
#
# satisfy(problem.goal, state, domain)[1] == true

function get_domain_problem_objects(domain_path, problem_path)
    domain = load_domain(domain_path)
    problem = load_problem(problem_path)

    return domain, problem
end

function create_causal_graph(domain, problem; max_depth=3)
    s₀ = initialize(problem)
    tree = IdDict()
    tree[1] = [(s₀, domain.actions[:unstack], s₀)]
    for i = 2:max_depth
        tree[i] = []
        for snode in tree[i-1]
            sᵢ = snode[3]
            A = available(sᵢ, domain)
            for a in A
                s¹ = execute(a, sᵢ, domain)
                push!(tree[i], (sᵢ, a, s¹))
                if satisfy(problem.goal, s¹, domain)[1]
                    return tree
                end
            end
        end
    end
    return tree
end

function in_set_vector(vect, set)
    status = false
    for ele in vect
        eles = ele.facts
        sets = set.facts
        if issetequal(eles, sets)
            status = true
            break
        end
    end
    return status
end

function get_unique_states(tree)
    unique_states = []
    for (k,nodes) in tree
        for s in nodes
            state = s[3]
            if !in_set_vector(unique_states, state)
                push!(unique_states, state)
            end
        end

    end
    return unique_states
end

function get_similars(tree, state)
    uniques = get_unique_states(tree)
    sf = state.facts
    sims = []
    for st in uniques
        stf = st.facts
        if issetequal(sf, stf)
            push!(sims, st)
        end
    end
    return sims
end

function get_edge_pairs(tree, ids)
    pairs = []
    actions = []
    for (k, nodes) in tree
        if k>1
            for s in nodes
                if haskey(ids, s[1])
                    from_id = ids[s[1]]
                else
                    similars = get_similars(tree, s[1])
                    for s in similars
                        if haskey(ids, s)
                            from_id = ids[s]
                            break
                        end
                    end
                end

                if haskey(ids, s[3])
                    to_id = ids[s[3]]
                else
                    similars = get_similars(tree, s[3])
                    for s in similars
                        if haskey(ids, s)
                            to_id = ids[s]
                            break
                        end
                    end
                end
                push!(pairs, (from_id, to_id))
                push!(actions, s[2])
            end
        end
    end
    return pairs, actions
end


function get_state_ids(tree)
    unique_states = get_unique_states(tree)
    N = length(unique_states)
    ids = IdDict()
    for i=1:N
        ids[unique_states[i]] = i
    end
    return ids
end

function get_goal_id(problem, domain, tree)
    ids = get_state_ids(tree)
    goal = problem.goal
    for (state, id) in ids
        if satisfy(goal, state, domain)[1]
            goal_index = id
            return goal_index
        end
    end
    println("Cannot get Goal ID")
    return 0
end

function get_edge_action_dict(tree)
    ids = form_state_ids(tree)
    edges, actions = get_edge_pairs(tree, ids)
    mapping = Dict()
    for (e,a) in zip(edges, actions)
        mapping[e]=a
    end
    return mapping
end

function draw_graph(tree)
    ids = form_state_ids(tree)
    N = length(ids)
    Edges, actions = get_edge_pairs(tree, ids)
    actions =  union(actions)
    # println(Edges)
    # print_ids(ids)
    # println(actions)
    causal_graph = DiGraph(N)
    for pair in Edges
        add_edge!(causal_graph, pair[1], pair[2])
    end
    nodelabel = 1:nv(causal_graph)
    plot_edges = []
    for e in edges(causal_graph)
        ed = (src(e),dst(e))
        push!(plot_edges, ed)
    end
    # println(plot_edges)
    edge_labels = []
    for p in plot_edges
        index = findall(x->x==p, Edges)[1]
        push!(edge_labels, actions[index])
    end
    gplot(causal_graph, nodelabel=nodelabel,  edgelabelsize=2.0,  edgelabeldistx=0.5, edgelabeldisty=0.5, edgelabel=edge_labels, edgelabelc=colorant"orange", nodesize=10.0, layout=spectral_layout)
end

function find_first_node(plan, node)
    for p in plan
        if p[1] == node
            return p
        end
    end
end

function force_right_order(plan)
    ordered_plan = []
    first = plan[1]
    for p in plan
        if p[1] == 1
            first = p
            push!(ordered_plan, p)
            break
        end
    end
    focus = first
    while length(ordered_plan) != length(plan)
        node = find_first_node(plan, focus[2])
        push!(ordered_plan, node)
        focus = node
    end
    return ordered_plan
end

function create_adjacency_matrix(tree)
    ids = form_state_ids(tree)
    N = length(ids)
    edges, actions = get_edge_pairs(tree, ids)
    matrix = zeros((N,N))
    for e in edges
        matrix[e[1],e[2]] = 1
    end
    return matrix
end

function format_plan(tree, cartesian_indices)
    action_mapping = get_edge_action_dict(tree)
    plan_edges = []
    plan = []
    for ci in cartesian_indices
        idx = (ci[1], ci[2])
        push!(plan_edges, idx)
    end
    plan_edge_path = force_right_order(plan_edges)
    for ei in plan_edge_path
        push!(plan, action_mapping[ei])
    end

    return plan
end

function print_ids(ids)
    for (k,v) in ids
        print(v)
        print(" => ")
        println(k)
        println()
    end
end


# dom, prob = get_domain_problem_objects("pddl_graph/pddl/blocksworld/domain.pddl", "pddl_graph/pddl/blocksworld/problem.pddl")
# tree = create_causal_graph(dom, prob, max_depth=3)
# draw_graph(tree)
# create_adjacency_matrix(tree)
# =#
