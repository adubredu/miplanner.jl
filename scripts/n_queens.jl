using JuMP
using GLPK
using LinearAlgebra

N = 8
model = Model(GLPK.Optimizer)

@variable(model, x[1:N, 1:N], Bin)
@constraint(model, vert_con[i=1:N], sum(x[i, :]) == 1)
@constraint(model, hor_con[j=1:N], sum(x[:, j]) == 1)
for i in -(N-1):(N-1)
    @constraint(model, sum(LinearAlgebra.diag(x, i)) <= 1)
    @constraint(model, sum(LinearAlgebra.diag(reverse(x, dims=1), i)) <= 1)
end


optimize!(model)

for i in 1:N
    println(convert.(Int, value.(x[i,:])))
end
