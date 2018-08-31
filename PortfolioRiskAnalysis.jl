using TimeSeries
using StatsBase
using DataFrames
using Plots
plotly()

## Load Data
#history = readtimearray(".\\docs\\Presentations\\plot_history\\baseG18.csv")
history = readtimearray(".\\docs\\HistoricoLista1SF.csv", format="dd/mm/yyyy") #delim=';')
numA = size(history,2)
datesOriginal = timestamp(history)

## Prepare data: remove NAN rows

historyNoNA = history[datesOriginal[vec(!any(isnan.(values(history)),2))]]
numD,numA = size(historyNoNA)       # A: Assets    D: Days
dates = timestamp(historyNoNA)

## Parameters Portfolio

# initial Wealth
W0 = 1e6

# number of assets
numA = 5

## Calculate returns
# Calculate arithmetic returns
returns = percentchange(historyNoNA[1:numA])  # if unused assets are placed last
numD,numA =size(returns)

##############################################
#       Analysis of a equal wighted portfolio
##############################################
## Parameters
# weights
a = fill(1/numA,numA)

## Initial setting
# Initial number of round lots (100 shares) of our stocks
rl = Int.(floor(a*W0./values(historyNoNA[1])'))

# initial invested money
V0 = values(historyNoNA[1])*rl

# left out money
LO = W0-V0

## Final setting
# final invested money
VT = values(historyNoNA[end])*rl

# total return
rf = VT/V0

## Descriptive portfolio statistics
# Mean (μ)
μ = mean(values(returns),1)

# Variance and Covariance Matrix
Σ = cov(values(returns),1)






