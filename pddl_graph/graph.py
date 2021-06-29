from planning_graph.planning_graph import PlanningGraph

planning_graph = PlanningGraph("/home/alphonsus/research/mip/pddl_graph/pddl/blocksworld/domain.pddl", "/home/alphonsus/research/mip/pddl_graph/pddl/blocksworld/problem.pddl",
visualize=True)

graph = planning_graph.create(max_num_of_levels=10)
graph.visualize_png("graph.png")
print(graph)
