using Combinatorics

function create_grocery_problem(items, problem_name)
    prefix = "(define (problem gprob)
       (:domain grocery)\n (:objects "
   for ob in items
       prefix *= string(ob) * " "
   end
   prefix *= ")\n"
   prefix *= "(:init  "
   for ob in items
       prefix *= "(ontable " * string(ob) * ") "
   end
   prefix *= ")\n"

   # prefix *= "(:goal (and "
   # for ob in items
   #     prefix *= "(inbag "*string(ob)*") "
   # end
   # prefix *= ")))"

   # prefix *= "(:goal (or "
   # perms = []
   # for ob in items
   #      for ob2 in items
   #          if ob!=ob2
   #              dis = "(and (inbag "*string(ob)*") (inbag "*string(ob2)*"))"
   #              dis2 = "(and (inbag "*string(ob2)*") (inbag "*string(ob)*"))"
   #              if !(dis in perms) && !(dis2 in perms)
   #                  push!(perms, dis)
   #                  prefix *= dis*" "
   #              end
   #          end
   #      end
   #  end
   #  prefix *=")))"

    prefix *= "(:goal (or "
    println("items: ", items)
    combos = combinations(items)
    for combo in combos
        dis="(and "
        for c in combo
            dis*="(inbag "*string(c)*") "
        end
        dis*=") "
        prefix*=dis*" "
    end
    prefix *=")))"

   open("pddl_graph/pddl/grocerypacking/"*problem_name*"_problem.pddl", "w") do io
       write(io, prefix)
   end
   return ("pddl_graph/pddl/grocerypacking/domain.pddl", "pddl_graph/pddl/grocerypacking/"*problem_name*"_problem.pddl")
end


# items = ["a","b", "c"]
# create_grocery_problem(items, "prob")
