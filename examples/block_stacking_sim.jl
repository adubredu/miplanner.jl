include("../sim/block_stacking_env.jl")

domain_path = "pddl_graph/pddl/blocksworld/domain.pddl"
problem_path = "pddl_graph/pddl/blocksworld/hard_problem.pddl"
load_and_run_sim(domain_path, problem_path)
