using TimeSeries
using StatsBase
using DataFrames

# sk2
function sk2(y)
    (percentile(y,75)+percentile(y,25)-2*percentile(y,50))/(percentile(y,75)-percentile(y,25))
end
# sk3
function sk3(y)
    (mean(y)-median(y))/mean(abs.(y-median(y)))
end

#kr2
function kr2(y)
	(((percentile(y,7/8*100)- percentile(y,5/8*100)) + ( percentile(y,3/8*100)- percentile(y,1/8*100))) / (percentile(y,6/8*100)- percentile(y,2/8*100)))-1.23
end

#kr3
"""
    KR3 estimator from Kim & White
    source: https://www.statsmodels.org/dev/_modules/statsmodels/stats/stattools.html
    Parameters
    ----------
    y : array-like, 1-d
    alpha : float, optional
        Lower cut-off for measuring expectation in tail.
    beta :  float, optional
        Lower cut-off for measuring expectation in center.

    Returns
    -------
    kr3 : float
        Robust kurtosis estimator based on standardized lower- and upper-tail
        expected values

    Notes
    -----
    .. [*] Tae-Hwan Kim and Halbert White, "On more robust estimation of
       skewness and kurtosis," Finance Research Letters, vol. 1, pp. 56-73,
       March 2004.
    """
function kr3(y; alpha=5.0, beta=50.0)
    perc = [alpha, 100.0 - alpha, beta, 100.0 - beta]
    lower_alpha, upper_alpha, lower_beta, upper_beta = percentile(y, perc)
    l_alpha = mean(y[y .< lower_alpha])
    u_alpha = mean(y[y .> upper_alpha])

    l_beta = mean(y[y .< lower_beta])
    u_beta = mean(y[y .> upper_beta])

    (u_alpha - l_alpha) / (u_beta - l_beta) -2.59
end

## Calculate descriptive statistics

function DescriptiveStatistics(y)
    ds = DataFrame()
    for i=1:size(y,2)+1
        if i == 1
            ds[Symbol("Stat")]= String[]
        else
            ds[Symbol(colnames(y)[i-1])]= Float64[]
        end
    end

    # mean
    push!(ds, vcat(["mean"],[mean(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    #mean(logreturns["BBAS3","DOL"])
    # median
    push!(ds, vcat(["median"],[median(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    #median(values(logreturns["BBAS3","DOL"]),1)
    # mode
    push!(ds, vcat(["mode"],[mode(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    # std
    push!(ds, vcat(["std"],[std(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    #std(logreturns["BBAS3","DOL"])
    # max
    push!(ds, vcat(["maximum"],[maximum(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    # min
    push!(ds, vcat(["minimum"],[minimum(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    # quantiles
    push!(ds, vcat(["quantile 1%"],[percentile(values(y[colnames(y)[i]]),1) for i=1:size(colnames(y))[1]][:]))
    push!(ds, vcat(["quantile 5%"],[percentile(values(y[colnames(y)[i]]),5) for i=1:size(colnames(y))[1]][:]))
    push!(ds, vcat(["quantile 10%"],[percentile(values(y[colnames(y)[i]]),10) for i=1:size(colnames(y))[1]][:]))
    push!(ds, vcat(["quantile 90%"],[percentile(values(y[colnames(y)[i]]),90) for i=1:size(colnames(y))[1]][:]))
    push!(ds, vcat(["quantile 95%"],[percentile(values(y[colnames(y)[i]]),95) for i=1:size(colnames(y))[1]][:]))
    push!(ds, vcat(["quantile 99%"],[percentile(values(y[colnames(y)[i]]),99) for i=1:size(colnames(y))[1]][:]))
    # kurtosis (k1)
    push!(ds, vcat(["kurtosis"],[kurtosis(values(y[colnames(y)[i]]))+3 for i=1:size(colnames(y))[1]][:]))    
    # skewness (sk1)
    push!(ds, vcat(["skewness"],[skewness(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    # sk2
    push!(ds, vcat(["sk2"],[sk2(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    # sk3
    push!(ds, vcat(["sk3"],[sk3(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    #kr2
    push!(ds, vcat(["kr2"],[kr2(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))
    #kr3
    push!(ds, vcat(["kr3"],[kr3(values(y[colnames(y)[i]])) for i=1:size(colnames(y))[1]][:]))

    ds
end