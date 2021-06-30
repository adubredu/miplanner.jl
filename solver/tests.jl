domain = load_domain("pddl_graph/pddl/blocksworld/domain.pddl")
problem =  load_problem("pddl_graph/pddl/blocksworld/problem.pddl")

state = initialize(problem)
state = execute(pddl"(pickup a)", state, domain)
state = execute(pddl"(stack a b)", state, domain)

# satisfy(problem.goal, state, domain)[1] == true
println(state)
println(problem.goal)
