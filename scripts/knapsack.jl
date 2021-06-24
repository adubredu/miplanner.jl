using JuMP
import GLPK

function example_knapsack()
    profit = [5, 3, 2, 7, 4]
    weight = [2, 8, 4, 2, 5]
    capacity = 10

    model = Model(GLPK.Optimizer)

    @variable(model, x[1:5], Bin)
    @constraint(model, x'*weight <= 10)
    @objective(model, Max, x'*profit)

    optimize!(model)

    println("Objective is: ", objective_value(model))
    println("Solution is: ")
    for i in 1:5
        println("x[$i] = ", value(x[i]))
    end
end

example_knapsack()
