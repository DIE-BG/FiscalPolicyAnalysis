# The functions below are helpers functions to check the stability of a VAR system.
# There is a function to check stability of a VAR through the eigenvalues of the companion matrix
# and and other one to calculate the responses to VAR forecast errors or dynamic multipliers

using Statistics
using LinearAlgebra

"""
    companion(A::Matrix; K::Int, P::Int)

    Makes the companion matrix of a VAR of order p. This matrix is essential to check the stability of the VAR and generate
    the responses to VAR forecast errors.

    - A is the coefficients matrix of the VAR
    - K number of variables
    - P order of the VAR
"""

function companion(A::Matrix; K::Int, P::Int)
    
    # A Matrix
    A_comp = vcat(
        A,
        hcat(Matrix(I, K*(P-1), K*(P-1)), zeros(K*(P-1), K))
    )

    return A_comp

end

function DynamicMultipliers(A::Matrix; K::Int, P::Int, T::Int, structural::Bool = false)

    # Companion matrix
    A_comp = companion(A, K, P)

    # J Matrix
    J = hcat(Matrix(I, K, K), zeros(K, K*(p-1)))


    # IRF array to store the IRFs
    IRF = Array{Float64}(undef, K, K, T)

    if structural

        # for i in 1:T
        #     IRF[:, :, i] = (J * A_comp^i * J') * BQ_VAR(VAR_est)["B_0_inv"]
        # end

    else

        for i in 1:T
            IRF[:, :, i] = (J * A_comp^i * J') 
        end

    end

    return IRF

end
