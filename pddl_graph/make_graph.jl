using PDDL

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

function draw_graph(tree)
    unique_states = get_unique_states(tree)
    N = length(unique_states)
    ids = IdDict()
    for i=1:N
        ids[unique_states[i]] = i
    end
    edges, actions = get_edge_pairs(tree, ids)
    println(edges)
    print_ids(ids)
    println(actions)

    
end

function print_ids(ids)
    for (k,v) in ids
        print(v)
        print(" => ")
        println(k)
        println()
    end
end

dom, prob = get_domain_problem_objects("pddl_graph/pddl/blocksworld/domain.pddl", "pddl_graph/pddl/blocksworld/problem.pddl")
tree = create_causal_graph(dom, prob, max_depth=3)
draw_graph(tree)
