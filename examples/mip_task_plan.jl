include("../solver/mip_solver.jl")

domain_path = "pddl_graph/pddl/blocksworld/domain.pddl"
problem_path = "pddl_graph/pddl/blocksworld/problem5.pddl"
@time plan = mip_planner(domain_path, problem_path)

println("\nPlan: ", plan)
