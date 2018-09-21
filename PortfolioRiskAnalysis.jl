using TimeSeries
using StatsBase
using Distributions
using DataFrames
using Plots
using Latexify
using IterableTables
plotly()

##############################################
#       Initalization and Data Preparation
##############################################

#? Load Data
#//history = readtimearray(".\\docs\\Presentations\\plot_history\\baseG18.csv")
history = readtimearray(".\\docs\\HistoricoLista1SF.csv", format="dd/mm/yyyy") #//delim=';')
numA = size(history,2)
datesOriginal = timestamp(history)

#? Prepare data: remove NAN rows
historyNoNA = history[datesOriginal[vec(!any(isnan.(values(history)),2))]]
numD,numA = size(historyNoNA)       #- A: Assets    D: Days
dates = timestamp(historyNoNA)

#? Parameters Portfolio
#-initial Wealth
W0 = 1e6

#-number of assets
numA = 5

#? Init
#-select assets
historyNoNA = historyNoNA[colnames(historyNoNA)[1:numA]...] #-if unused assets are placed last

#? Calculate returns
#-calculate arithmetic returns
returns = percentchange(historyNoNA) 
numD,numA =size(returns)

##############################################
#       Analysis of a equal wighted portfolio
##############################################

#? Parameters
#-weights
ω = fill(1/numA,numA)

#? Initial setting
#-Initial number of round lots (100 shares) of our stocks
InitLots = TimeArray(timestamp(historyNoNA)[1], Int.(floor(ω*W0./values(100*historyNoNA[1])'))',colnames(historyNoNA))

df_InitLots = DataFrame(Dict(zip(colnames(historyNoNA),Int.(floor(ω*W0./values(100*historyNoNA[1])')))))
df_InitLots[:timestamp] = string(timestamp(historyNoNA)[1])

latexify(df_InitLots, env=:table) #-print latex

#-number of shares
rl =Int.(floor(ω*W0./values(100*historyNoNA[1])'))*100

#-initial invested money
V0 = values(historyNoNA[1])*rl

#-left out money
LO = W0-V0

#? Progress
Vt = TimeArray(timestamp(historyNoNA),[(values(historyNoNA[t])*rl)[1] for t=1:size(historyNoNA,1)],["Portfolio"])
plot(Vt, xlabel="Dates",ylabel="Wealth(R\$)")

#? Final setting
#-final invested money
VT = values(historyNoNA[end])*rl

#-total return
rf = VT/V0 - 1

#? Descriptive portfolio statistics
#-Mean (μ)
μ = mean(values(returns),1)'
latexify(signif.(μ,2)) #-print latex

#-Variance and Covariance Matrix
Σ = cov(values(returns),1) #-calculate
latexify(signif.(Σ,2)) #-print latex

#? Risk analysis - Approximated Lost function
#-Approximated Lost function distribution T+1 (Expectation, Variance) ~ N(E_LΔ_T1, V_LΔ_T1)
E_LΔ_T1 = (-VT*ω'μ)[1] #-Expectation

V_LΔ_T1 = ((VT^2)*ω'Σ*ω)[1] #-Variance

histogram(rand(Normal(E_LΔ_T1,sqrt(V_LΔ_T1)),100000))

#-VaR_{95%}
VaR_95 = sqrt(V_LΔ_T1)*quantile(Normal(),0.95)+E_LΔ_T1
#- == VaR_95 = quantile(Normal(E_LΔ_T1,sqrt(V_LΔ_T1)),0.95)

#? Risk analysis - "True" Lost function (Logarimic)
#-Lost function distribution T+1 through Mont Carlo
r_T1 = rand(MvNormal(μ[:,1],Σ),100000); #-returns generation
L_T1 = (-VT*(ω')*((e.^r_T1)-1))'[:,1]

# histogram
histogram(L_T1)

#-VaR_{95%}
quantile(L_T1,0.95)


