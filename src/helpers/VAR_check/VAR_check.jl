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

"""
    DynamicMultipliers(A::Matrix; K::Int, P::Int, T::Int, structural::Bool = false)

    Make the Dynamic Multipliers responses of the VAR system. These functions are 
    responses of a variable into the system to a unique shock uₖₜ.

    - A is a coefficients matrix (reduced form)
    - K number of variables
    - P order of the VAR
    - T size of periods ahead
    - structural is a boolean variable that defines wheater functions are 
      Dynamic Multipliers or IRFs.

"""

function DynamicMultipliers(A::Matrix; K::Int, P::Int, T::Int, structural::Bool = false)

    # Companion matrix
    A_comp = companion(A; K = K, P = P)

    # J Matrix
    J = hcat(Matrix(I, K, K), zeros(K, K*(P-1)))


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

"""
    ForceStability(A::Matrix; K::Int, P::Int)

    This function ensures the stability of the VAR system by multipliying the coefficients matrix by 0.99 as many times as necessary.
    The eigenvalues of the A matrix should be within the unit circle.

    - A is the coefficients matrix
    - K number of variables
    - P order of the VAR
"""

function ForceStability(A::Matrix; K::Int, P::Int, shrinking_type::String = "diagonal")

    A_comp = companion(A; K = K, P = P)

    real_eigenvalues = real.(eigvals(A_comp))

    factor = 0.99

    while any(x -> x > 1, real_eigenvalues)

        if shrinking_type == "diagonal"

            A = factor * Matrix(I, 17, 17) * A

        elseif shrinking_type == "all"

            A = factor * A

        end

        A_comp = companion(A; K = K, P = P)
        
        real_eigenvalues = real.(eigvals(A_comp))

    end

    return A
end

function ForceStabilityExpDecrease(A::Matrix; K::Int, P::Int, shrinking_type::String = "diagonal")

    A_comp = companion(A; K = K, P = P)

    real_eigenvalues = real.(eigvals(A_comp))

    factor = 0.99

    i = 1

    while any(x -> x > 1, real_eigenvalues)

        if shrinking_type == "diagonal"

            A = factor^i * Matrix(I, 17, 17) * A

            i += 1

        elseif shrinking_type == "all"

            A = factor^i * A
            
            i += 1

        end

        A_comp = companion(A; K = K, P = P)
        
        real_eigenvalues = real.(eigvals(A_comp))

    end

    return A


end