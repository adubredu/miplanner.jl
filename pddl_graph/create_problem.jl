function create_grocery_problem(items, problem_name)
    prefix = "(define (problem gprob)
       (:domain grocery)\n (:objects "
   for ob in items
       prefix *= string(ob) * " "
   end
   prefix *= ")\n"
   prefix *= "(:init (arm-empty) "
   for ob in items
       prefix *= "(on-table " * string(ob) * ") "
   end
   prefix *= ")\n"
   prefix *= "(:goal (and "
   for ob in items
       prefix *= "(in-bag "*string(ob)*") "
   end
   prefix *= ")))"

   open("pddl_graph/pddl/grocerypacking/"*problem_name*"_problem.pddl", "w") do io
       write(io, prefix)
   end
   return ("pddl_graph/pddl/grocerypacking/domain.pddl", "pddl_graph/pddl/grocerypacking/"*problem_name*"_problem.pddl")
end


items = ["a","b", "c"]
create_grocery_problem(items, "prob")
