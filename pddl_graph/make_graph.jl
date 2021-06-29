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

function create_causal_graph(domain, problem, max_depth=3)
    s₀ = initialize(problem)
    tree = Dict([(1, [(nothing, nothing,s₀)])])
    for i = 2:max_depth
        for snode in tree[i-1]
            sᵢ = snode[3]
            A = available(sᵢ, domain)
            

        end
    end
end
