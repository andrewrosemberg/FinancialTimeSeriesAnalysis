using TimeSeries
using StatsBase
using Distributions
using DataFrames
using Plots
using Latexify
using IterableTables
include("DescriptiveStatistics.jl")
plotly()

#########################################################
#       Study name: Simple Model Adequacy Analysis
#       Objective : - Verify if the following model for 
#                   financial returns is consistent with
#                   the knwons Stylized Facts.
#       Model     : r[t] = β*ϵ²[t-1]*ϵ[t-2]*ϵ[t], β > 0
#                   ϵ[t] ~ t(0, 1,m) and iid
#########################################################

#? Parameters
#- constant
β = 0.001
#- erro's degrees of liberty
m = 6
#- initial values
r1 = 0; r2 = -0.003;
#- series size (must be over 50, because we will discard the first 50)
T = 300

#? Generate Returns
#- error generation
srand(1111);
ϵ = rand(TDist(m), T);

#- returns
raux = Array{Float64}(T);
raux[1] = r1; r[2] = r2;
for t=3:T
    raux[t] = β*(ϵ[t-1]^2)*ϵ[t-2]*ϵ[t]
end

r = TimeArray(Date(2018,1,1)+Day(50): Date(2018,1,1)+Day(T-1),raux[51:T],["Generated_series"]) #- handle as timeseries
#- plot returns
plot(r, xlabel="Dates",ylabel="Retunrs")

#- histogram
histogram(values(r))

#? Stylized Facts
#- Descriptive Statistics
latexifyin = DescriptiveStatistics(r)
latexifyin[:Generated_series] = signif.(latexifyin[:Generated_series],2)  
latexify(latexifyin,env=:table,latex=false) # print latex

#- autocorrelation function (FAC) series
bar(autocor(values(r))[2:16], label=colnames(r)[1], title="FAC Series")

#- FAC square series
bar(autocor((values(r)).^2)[2:16], label=colnames(r)[1], title="FAC Squared Series")