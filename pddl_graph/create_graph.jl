using PDDL
using LightGraphs
using GraphPlot
using Colors
using SymbolicPlanners

function get_domain_problem_objects(domain_path, problem_path)
    domain = load_domain(domain_path)
    problem = load_problem(problem_path)

    return domain, problem
end

function expand!(node, tree, queue, domain, problem)
    state = node[5]
    actions = available(state, domain)
    for act in actions
        next_state = execute(act, state, domain)
        next_id = hash(next_state)
        if haskey(tree, next_id) continue end
        tree[next_id] = (node[4], state, act, next_id, next_state)
        push!(queue, next_id)
    end

end

function expand_ff!(node, tree, queue, domain, problem, ff)
    state = node[5]
    actions = available(state, domain)
    for act in actions
        next_state = execute(act, state, domain)
        next_id = hash(next_state)
        if haskey(tree, next_id) continue end
        tree[next_id] = (node[4], state, act, next_id, next_state)
        next_cost = ff(domain, next_state, problem.goal)
        if !(next_id in keys(queue))
            enqueue!(queue, next_id, next_cost)
        else
            queue[next_id] = next_cost
        end
    end
end

function create_causal_graph(domain, problem; max_depth=10)
    init_state = initialize(problem)
    init_id = hash(init_state)
    queue = [init_id]
    tree = IdDict()
    tree[init_id] = (init_id, init_state, nothing, init_id, init_state)

    for i=1:max_depth
        node_id = popfirst!(queue)
        node = tree[node_id]
        if satisfy(problem.goal, node[5], domain)[1]
            return tree
        end
        expand!(node, tree, queue, domain, problem)
    end
    return :Failure
end

function create_causal_graph_ff(domain, problem; max_depth=10)
    init_state = initialize(problem)
    init_id = hash(init_state)
    tree = IdDict()
    tree[init_id] = (init_id, init_state, nothing, init_id, init_state)
    ff = precompute!(FFHeuristic(), domain, init_state, problem.goal)
    est_cost = ff(domain, init_state, problem.goal)
    queue = PriorityQueue{UInt, Float64}(init_id => est_cost)

    for i = 1:max_depth
        node_id = dequeue!(queue)
        node = tree[node_id]
        if satisfy(problem.goal, node[5], domain)[1]
            return tree
        end
        expand_ff!(node, tree, queue, domain, problem, ff)
    end
    return :Failure
end

function get_state_int_id_dict(tree)
    tkeys = collect(keys(tree))
    state_index_dict = Dict()
    for i=1:length(tkeys)
        state_index_dict[tkeys[i]] = i
    end
    return state_index_dict
end

function get_edge_action_pairs(tree)
    int_id_dict = get_state_int_id_dict(tree)
    pair_action_dict = Dict()
    actions = []
    pais = []
    for (k,v) in tree
        pair = (int_id_dict[v[1]], int_id_dict[v[4]])
        action = v[3]
        push!(pais, pair)
        push!(actions, action)
        pair_action_dict[pair] = action
    end
    return pais, actions, pair_action_dict
end

function create_adjacency_matrix(tree, pais)
    N = length(tree)
    matrix = zeros((N,N))
    for e in pais
        matrix[e[1],e[2]] = 1
    end
    return matrix
end

function print_id_to_state(tree, id_dict)
    for (k,v) in tree
        print(id_dict[k]," => ")
        print(v[5])
        println(" ")
    end
end

function get_goal_id(domain, problem, tree)
    id_dict = get_state_int_id_dict(tree)
    goal = problem.goal
    id = :failed
    for (k,v) in tree
        if satisfy(goal, v[5], domain)[1]
            id = k
            break
        end
    end
    return id_dict[id]
end

function get_init_id(domain, problem, tree)
    id_dict = get_state_int_id_dict(tree)
    init = problem.init
    id = :failed
    for (k,v) in tree
        if satisfy(init, v[5], domain)[1]
            id = k
            break
        end
    end
    return id_dict[id]
end

function find_first_node(plan, node)
    for p in plan
        if p[1] == node
            return p
        end
    end
end

function force_right_order(plan, iid)
    ordered_plan = []
    first = plan[1]
    for p in plan
        if p[1] == iid
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

function format_plan(tree, cartesian_indices, action_mapping, iid)
    plan_edges = []
    plan = []
    for ci in cartesian_indices
        idx = (ci[1], ci[2])
        push!(plan_edges, idx)
    end
    plan_edge_path = force_right_order(plan_edges, iid)
    for ei in plan_edge_path
        push!(plan, action_mapping[ei])
    end
    return plan
end

function draw_graph(tree)
    Edges, actions = get_edge_action_pairs(tree)
    N = length(tree) 
    causal_graph = DiGraph(N)
    for pair in Edges
        add_edge!(causal_graph, pair[1], pair[2])
    end
    gplot(causal_graph,   edgelabelc=colorant"orange", nodesize=10.0)
end
