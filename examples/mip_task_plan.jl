include("../solver/mip_solver.jl")

domain_path = "pddl_graph/pddl/grocerypacking/domain.pddl"
problem_path = "pddl_graph/pddl/grocerypacking/packing_problem.pddl"
plan = mip_planner(domain_path, problem_path)

println("\nPlan: ", plan)
