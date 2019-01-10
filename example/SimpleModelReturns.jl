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
raux[1] = r1; raux[2] = r2;
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
pt1 = bar(autocor(values(r))[2:16], label=colnames(r)[1],ylim=[0,1], title="FAC Series");

#- FAC square series
pt2 = bar(autocor((values(r)).^2)[2:16], label=colnames(r)[1],ylim=[0,1], title="FAC Squared Series");

plot(pt1,pt2,layout=2)

#########################################################
#       Study name: GARCH(1,1) Predictive Distribution 
#       Objective : - GARCH(1,1) Conditional Distribution
#                   build.
#       Model     : r[t] = σ[t]ϵ[t]
#                   σ²[t] = α₀ + α₁r²[t-1] + β₁σ²[t-1],
#                   β₁ > 0,  α₁ > 0, α₁ + β₁ < 1
#                   ϵ[t] ~ t(0, 1,m) and iid
#########################################################

#? Parameters
#- constant
β₁ = 0.8; α₁ = 0.15; α₀ = 0.001
#- erro's degrees of liberty
m = 12
#- initial values
r0 = 0; σ0 = 0
#- series size
T = 100
#- Number of simulations
S = 10000

#? Generate Returns
#- error generation
srand(1111);

#- Init
r = Array{Float64}(T,S);

#- Simulation
for i = 1:S
    ϵ = rand(TDist(m), T);

    #- returns
    raux = Array{Float64}(T);
    s2aux = Array{Float64}(T);

    s2aux[1] = α₀ + α₁*r0^2 + β₁*σ0^2
    raux[1] = sqrt(s2aux[1])*ϵ[1]
    for t=2:T
        s2aux[t] = α₀ + α₁*raux[t-1]^2 + β₁*s2aux[t-1]
        raux[t] = sqrt(s2aux[t])*ϵ[t]
    end

    r[:,i] = raux
end

#- plot returns
rplot = TimeArray(Date(2018,1,1): Date(2018,1,1)+Day(T-1),r[:,1],["Generated_series"]) #- handle as timeseries
plot(rplot, xlabel="Dates",ylabel="Retunrs")

#- histogram
histogram(values(rplot))

#? Conditional Distributions and comparison with TDist
#- Series on step 2,3 and 100
K = [2;3;100]
yaux = r[K,:]'

#- TDist
std_garch = sqrt(α₀/(1-(β₁+ α₁))) #- unconditional std
ϵ = std_garch*rand(TDist(m), S);#-std*rand(TDist(m), S);

#- adapt to use timeseries function Descriptive Statistics
yaux = [yaux ϵ]
y = TimeArray(Date(2018,1,1): Date(2018,1,1)+Day(S-1),yaux,["k=2","k=3","k=100","TDist"]) #- handle as timeseries

#- histogram
phist = Vector(size(K,1)+1) 
for i= 1:size(K,1)
    phist[i] = histogram(yaux[:,i], label= "k=$(K[i])", color=i)
end
phist[size(K,1)+1] = histogram(yaux[:,size(K,1)+1], label= "TDist", color=4);
plot(phist...)

#- Descriptive Statistics
latexifyin = DescriptiveStatistics(y)
for i=1:size(colnames(y),1)
    name = Symbol(colnames(y)[i])
    latexifyin[name] = signif.(latexifyin[name],2)  
end
latexifyin
latexify(latexifyin,env=:table,latex=false) # print latex

#########################################################
#       Study name: GARCH(1,1) Predictive Distribution 
#       Objective : - GARCH(1,1) Conditional Distribution
#                   build.
#       Model     : r[t] = σ[t]ϵ[t]
#                   σ²[t] = α₀ + α₁r²[t-1] + β₁σ²[t-1],
#                   β₁ > 0,  α₁ > 0, α₁ + β₁ < 1
#                   ϵ[t] ~ N(0, 1) and iid
#########################################################

#? Parameters
#- constant
β₁ = 0.84; α₁ = 0.13; α₀ = 0.001
#- initial values
r0 = 0; σ0 = 0
#- series size
T = 2000
#- Number of simulations
S = 10000

#? Generate Returns
#- error generation
srand(1111);

#- Init
r = Array{Float64}(T,S);

#- Simulation
for i = 1:S
    ϵ = rand(Normal(), T);

    #- returns
    raux = Array{Float64}(T);
    s2aux = Array{Float64}(T);

    s2aux[1] = α₀ + α₁*r0^2 + β₁*σ0^2
    raux[1] = sqrt(s2aux[1])*ϵ[1]
    for t=2:T
        s2aux[t] = α₀ + α₁*raux[t-1]^2 + β₁*s2aux[t-1]
        raux[t] = sqrt(s2aux[t])*ϵ[t]
    end

    r[:,i] = raux
end

#- plot returns
rplot = TimeArray(Date(2018,1,1): Date(2018,1,1)+Day(T-1),r[:,1],["Generated_series"]) #- handle as timeseries
plot(rplot, xlabel="Dates",ylabel="Retunrs")

#- histogram
histogram(values(rplot))

#? Conditional Distributions and comparison with Normal
#- Series on step k
K = [1;2;5;10;100]
yaux = r[K,:]'

#//#- Normal inovation
#//std_garch = sqrt(α₀/(1-(β₁+ α₁))) #- unconditional std
#//ϵ = std_garch*rand(Normal(), S);#-std*rand(TDist(m), S);

#- adapt to use timeseries function Descriptive Statistics
#//yaux = [yaux ϵ]
y = TimeArray(Date(2018,1,1): Date(2018,1,1)+Day(S-1),yaux,["k=1","k=2","k=5","k=10","k=100"]) #- handle as timeseries

#- histogram
phist = Vector(size(K,1)) 
for i= 1:size(K,1)
    phist[i] = histogram(yaux[:,i], label= "k=$(K[i])", color=i,linewidth = 0,xlim=[-0.4,0.4],size = (800, 600))
end
plot(phist...)

#- Descriptive Statistics
latexifyin = DescriptiveStatistics(y)
for i=1:size(colnames(y),1)
    name = Symbol(colnames(y)[i])
    latexifyin[name] = signif.(latexifyin[name],2)  
end
latexifyin
latexify(latexifyin,env=:table,latex=false) # print latex

#? Unconditional Distribution
#- Series on step 100 and 2000
K = [100;T]
yaux = r[K,:]'

#- histogram
phist = Vector(size(K,1)) 
for i= 1:size(K,1)
    phist[i] = histogram(yaux[:,i], label= "k=$(K[i])", color=i,linewidth = 0,xlim=[-1,1],size = (800, 300))
end
plot(phist...)

#######################################################################
#       Study name: GARCH(1,1) Stylized Facts & Parameters Sensitivity  
#       Objective : - Analyse GARCH(1,1) Caracteristics and compare it 
#                   to the Stylized Facts of financial returns.
#.                  - Analyse Parameters Sensitivity.
#       Model     : r[t] = σ[t]ϵ[t]
#                   σ²[t] = α₀ + α₁r²[t-1] + β₁σ²[t-1],
#                   β₁ > 0,  α₁ > 0, α₁ + β₁ < 1
#                   ϵ[t] ~ t(0, 1,m) and iid
#######################################################################

#? Parameters
#- constant
β₁ = 0.8; α₁_base = 0.17; α₀ = 0.01
#- erro's degrees of liberty
m = 10
#- initial values
r0 = 2.0; σ0 = sqrt(5.0)
#- series size
T = 10000
#- Number of simulations
S = 4

#? Theoretical kurtosis
#- Gaussian inovation
K_r_gaussian = (6*α₁_base^2)/(1-(α₁_base+β₁)^2-2*α₁_base^2)

#- TDist inovation
K_r = (6+(m+1)*K_r_gaussian)/((m-4)-K_r_gaussian)+3

#? Generate Returns
#- Init
r = Array{Float64}(T,S);
pnames = Array{String}(S);

#- Simulation
for i = 1:S
    #- varing parameter
    α₁ = max(α₁_base-((i-1)^2)*0.02,0.01)
    pnames[i] = "α₁ = $(signif(α₁,2)) "
    #- error generation
    srand(1111);
    ϵ = rand(TDist(m), T);

    #- returns
    raux = Array{Float64}(T);
    s2aux = Array{Float64}(T);

    s2aux[1] = α₀ + α₁*r0^2 + β₁*σ0^2
    raux[1] = sqrt(s2aux[1])*ϵ[1]
    for t=2:T
        s2aux[t] = α₀ + α₁*raux[t-1]^2 + β₁*s2aux[t-1]
        raux[t] = sqrt(s2aux[t])*ϵ[t]
    end

    r[:,i] = raux
end

#- plot returns
r = TimeArray(Date(2018,1,1): Date(2018,1,1)+Day(T-1),r,pnames) #- handle as timeseries
pplot = Vector(size(colnames(r),1)) 
for i=1:size(colnames(r),1)
    pplot[i] = plot(values(r[colnames(r)[i]]), label= "$(colnames(r)[i])", color=i) #-, ylim=[-15,15])
end
plot(pplot...)


#- histogram
phist = Vector(size(colnames(r),1)) 
for i=1:size(colnames(r),1)
    phist[i] = histogram(values(r[colnames(r)[i]]), label= "$(colnames(r)[i])", color=i, xlim=[-5,5])
end
plot(phist...)


#- Descriptive Statistics
latexifyin = DescriptiveStatistics(r)
for i=1:size(colnames(r),1)
    name = Symbol(colnames(r)[i])
    latexifyin[name] = signif.(latexifyin[name],2)  
end
latexifyin
latexify(latexifyin,env=:table,latex=false) # print latex

#- autocorrelation function (FAC) series
pfac = Vector(size(colnames(r),1)) 
for i=1:size(colnames(r),1)
    pfac[i] = bar(autocor(values(r[colnames(r)[i]]))[2:40], label=colnames(r)[i],ylim = [0,1], title="FAC Series", color=i);
end
plot(pfac...)

#- FAC square series
pfac2 = Vector(size(colnames(r),1)) 
for i=1:size(colnames(r),1)
    pfac2[i] = bar(autocor(values(r[colnames(r)[i]]).^2)[2:40], label=colnames(r)[i],ylim = [0,1], title="FAC Squared Series", color=i);
end
plot(pfac2...)

#######################################################################
#       Study name: Stochastic Volatility  
#       Objective : - Analyse a model with Stochastic Volatility
#                   and its caracteristics and compare it 
#                   to the Stylized Facts of financial returns.
#       Model     : r[t] = σ[t]ϵ[t]
#                   σ[t] = exp((1/2)h[t])
#                   h[t] = ϕ h[t-1] + η[t]
#                   |ϕ| < 1
#                   ϵ[t] ~ N(0, 1) and iid, η[t] ~ N(0, σ²_n) and iid
#######################################################################

#? Parameters
#- constant
ϕ = 0.6;
#- η variance
σ_n = 1.5;
#- initial values
h0 = 3.0;
#- series size
T = 10000;

#? Generate Returns
#- Init
raux = Array{Float64}(T);
haux = Array{Float64}(T);

#- error generation
srand(1111);
ϵ = rand(Normal(), T);
η = rand(Normal(0,σ_n), T);

#- returns
haux[1] = ϕ*h0 + η[1]
raux[1] = exp(0.5*haux[1])*ϵ[1]
for t=2:T
    haux[t] = ϕ*haux[t-1] + η[t]
    raux[t] = exp(0.5*haux[t])*ϵ[t]
end

r = TimeArray(Date(2018,1,1): Date(2018,1,1)+Day(T-1),raux,["Generated_series"]) #- handle as timeseries
#- plot returns
plot(r, xlabel="Dates",ylabel="Retunrs")

#- histogram
histogram(values(r), xlim=[-8.7,8.7], label="Generated_series")

#? Descriptive Statistics

#- Descriptive Statistics
latexifyin = DescriptiveStatistics(r)
for i=1:size(colnames(r),1)
    name = Symbol(colnames(r)[i])
    latexifyin[name] = signif.(latexifyin[name],2)  
end
latexifyin
latexify(latexifyin,env=:table,latex=false) # print latex

#- autocorrelation function (FAC) series
pfac = Vector(size(colnames(r),1)*3) 
for i=1:size(colnames(r),1)
    pfac[i] = bar(autocor(values(r[colnames(r)[i]]))[2:40], label=colnames(r)[i],ylim = [0,1], title="FAC Series", color=i);
end

#- FAC square series
for iaux=size(colnames(r),1)+1:size(colnames(r),1)*2
    i = iaux-size(colnames(r),1)
    pfac[iaux] = bar(autocor(values(r[colnames(r)[i]]).^2)[2:40], label=colnames(r)[i],ylim = [0,1], title="FAC Squared Series", color=i);
end

#- FAC log square series
for iaux=2*size(colnames(r),1)+1:size(colnames(r),1)*3
    i = iaux-size(colnames(r),1)*2
    pfac[iaux] = bar(autocor(log.(values(r[colnames(r)[i]]).^2))[2:40], label=colnames(r)[i],ylim = [0,1], title="FAC Log Squared Series", color=i);
end
plot(pfac...)

#? Normality Test
include("normalitytest.jl")

#- Normality Test Results
normtests= normalitytest(r)

latexifyin = normtests
latexify(latexifyin,env=:table,latex=false) # print latex

