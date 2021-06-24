using JuMP
using GLPK

function example_cannery()
    plants = ["Seattle", "San-Diego"]
    num_plants = length(plants)

    markets = ["New-York", "Chicago", "Topeka"]
    num_markets = length(markets)

    capacity = [350, 600]
    demand = [300, 300, 300]

    distance = [2.5 1.7 1.8; 2.5 1.8 1.4]

    freight = 10
    cannery = Model()
    set_optimizer(cannery, GLPK.Optimizer)

    @variable(cannery, ship[1:num_plants, 1:num_markets] >= 0)

    @constraint(cannery, capacity_con[i = 1:num_plants], sum(ship[i,:]) <= capacity[i])

    @constraint(cannery, demand_con[j=1:num_markets], sum(ship[:,j]) >= demand[j])

    @objective(cannery, Min, sum(distance[i,j]*freight*ship[i,j] for i = 1:num_plants, j = 1:num_markets))

    optimize!(cannery)
    println("RESULTS:")
    for i = 1:num_plants
        for j = 1:num_markets
            println("  $(plants[i]) $(markets[j]) = $(Int(value(ship[i,j])))")
        end
    end
    return
end

example_cannery()
