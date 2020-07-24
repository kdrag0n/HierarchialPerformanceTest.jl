module HierarchialPerformanceTest

using HypothesisTests
using Statistics

const PerfMatrix = Array{Float64,2}

function hptRankSumTest(x::AbstractVector{S}, y::AbstractVector{T}, num_runs::Int) where {S<:Real,T<:Real}
    # Custom threshold as specified by the paper
    if num_runs < 12
        ExactMannWhitneyUTest(x, y)
    else
        ApproximateMannWhitneyUTest(x, y)
    end
end

function hptSignedRankTest(x::AbstractVector{T}, num_tests::Int) where T<:Real
    # Custom threshold as specified by the paper
    if num_tests < 25
        ExactSignedRankTest(x)
    else
        ApproximateSignedRankTest(x)
    end
end

function hpt(a::PerfMatrix, b::PerfMatrix; tail=:right)
    # Enforce identical and sane matrix sizes
    if size(a) != size(b)
        error("mismatching number of benchmarks/runs")
    elseif length(a) == 0
        error("no benchmarks given")
    end

    num_tests = size(a, 1) # n
    num_runs = size(a, 2) # m

    # Max significance for the *null* hypothesis, not the alternative
    maxNullSignificance = if (num_runs >= 5) 0.05 else 0.10 end

    # Calculate performance delta per benchmark
    test_deltas = Array{Float64}(undef, num_tests) # dT
    for test = 1:num_tests
        aRuns = a[test,:]
        bRuns = b[test,:]

        # Use SHT to determine which side is better
        shtP = pvalue(hptRankSumTest(aRuns, bRuns, num_runs), tail=tail)

        # Check is inverted because shtP = probability of null hypothesis (equal)
        test_deltas[test] = if (shtP < maxNullSignificance)
            median(aRuns) - median(bRuns)
        else
            0
        end
    end

    # Evaluate general performance using the selected SHT
    1 - pvalue(hptSignedRankTest(test_deltas, num_tests), tail=tail)
end

function hptSpeedup(a::PerfMatrix, b::PerfMatrix, minConfidence::Float64 = 0.95, digits::Int = 3, increment::Int = 1)
    # Calculate an extra digit internally to facilitate rounding
    baseSpeedup = 10 ^ digits
    # Use int for storing speedup to mitigate floating-point precision loss
    intSpeedup = baseSpeedup
    speedup = 1.0
    tail = :right

    # Invert if slower
    if hpt(a, b) < minConfidence
        increment *= -1
        tail = :left
    end

    while true
        confidence = hpt(a / speedup, b, tail=tail)
        if confidence >= minConfidence
            # Increment int and recalculate float to mitigate floating-point precision loss
            intSpeedup += increment
            speedup = intSpeedup / baseSpeedup
        else
            break
        end
    end

    speedup
end

function calcScore(results::PerfMatrix, reference::PerfMatrix, refScore::Int = 1000)
    # 95%-confidence speedup
    # We swap a and b because HPT considers higher values to be better, but
    # since our values are times rather than performance, lower is better
    round(Int, hptSpeedup(reference, results) * refScore)
end

end
