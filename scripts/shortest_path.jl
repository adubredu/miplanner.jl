using JuMP
import GLPK
import LinearAlgebra

G = [0 100 30 0 0;
     0 0 20 0 0;
     0 0 0 10 60;
     0 15 0 0 50;
     0 0  0 0 0]

n = size(G)[1]

shortest_path = Model(GLPK.Optimizer)
@variable(shortest_path, x[1:n, 1:n], Bin)

@constraint(shortest_path, [i=1:n, j=1:n; G[i,j] == 0], x[i,j] == 0)

@constraint(shortest_path, [i=1:n; i!=1 && i!=2], sum(x[i,:])==sum(x[:,i]))

@constraint(shortest_path, sum(x[1,:]) - sum(x[:,1]) == 1)

@constraint(shortest_path, sum(x[2, :]) - sum(x[:,2]) == -1)

@objective(shortest_path, Min, LinearAlgebra.dot(G,x))

optimize!(shortest_path) 
value.(x)
