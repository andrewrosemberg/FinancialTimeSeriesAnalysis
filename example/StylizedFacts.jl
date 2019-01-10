using TimeSeries
using StatsBase
using DataFrames
using Plots
using Latexify
using Distributions
include("DescriptiveStatistics.jl")
plotly()
using RCall 

#R"library(goftest)"
R"library(nortest)"

##############################################
#       Initalization and Data Preparation
##############################################

## Load Data
#history = readtimearray(".\\docs\\Presentations\\plot_history\\baseG18.csv")
history = readtimearray(".\\docs\\HistoricoLista1SF.csv", format="dd/mm/yyyy") #delim=';')
numA = size(history,2)
datesOriginal = timestamp(history)

## Prepare data: remove NAN rows

historyNoNA = history[datesOriginal[vec(!any(isnan.(values(history)),2))]]
numD,numA = size(historyNoNA)       # A: Assets    D: Days
dates = timestamp(historyNoNA)

#term = Date(2018,02)
#tm_corridos = Int.(term-dates)
#tm_uteis = Int.(bdays.(BusinessDays.Brazil(), dates, term))

## visualize data
plot(historyNoNA, xlabel="Dates",ylabel="Prices")

plot(historyNoNA["BBAS3"], xlabel="Dates",ylabel="Prices");

plot!(historyNoNA["DOL"], xlabel="Dates",ylabel="Prices")

## Calculate returns
# Calculate arithmetic returns and log returns daily
returns = percentchange(historyNoNA)
numD,numA =size(returns)

logreturns = percentchange(historyNoNA, :log)
numD,numA =size(returns)

plot(timestamp(returns),values(returns["BBAS3"]), title="BBAS3 Daily Returns", label="returns", xlabel="Dates",ylabel="Returns");
plot!(timestamp(returns),values(logreturns["BBAS3"]), label="logreturns", xlabel="Dates",ylabel="Returns")

plot(timestamp(returns),values(returns["DOL"]),title="DOLAR Daily Returns", label="returns", xlabel="Dates",ylabel="Returns");
plot!(timestamp(returns),values(logreturns["DOL"]), label="logreturns", xlabel="Dates",ylabel="Returns")

# histogram logreturns
histogram(logreturns["BBAS3"])
histogram(logreturns["DOL"])

# Calculate arithmetic returns and log returns monthly
returns30 = percentchange(historyNoNA[dates[1:22:end]])
numD,numA =size(returns30)

logreturns30 = percentchange(historyNoNA[dates[1:22:end]], :log)
numD,numA =size(logreturns30)

plot(timestamp(returns30),values(returns30["BBAS3"]), title="BBAS3 Monthly Returns", label="returns", xlabel="Dates",ylabel="Returns");
plot!(timestamp(returns30),values(logreturns30["BBAS3"]), label="logreturns", xlabel="Dates",ylabel="Returns")

plot(timestamp(returns30),values(returns30["DOL"]), title="DOLAR Monthly Returns", label="returns", xlabel="Dates",ylabel="Returns");
plot!(timestamp(returns30),values(logreturns30["DOL"]), label="logreturns", xlabel="Dates",ylabel="Returns")

##############################################
#        Descriptive Statistics
##############################################

## Calculate descriptive statistics entire series

# descriptive statistics daily returns-#
latexifyin = DescriptiveStatistics(logreturns["BBAS3","DOL"])
latexifyin[:BBAS3] = signif.(latexifyin[:BBAS3],2)
latexifyin[:DOL] = signif.(latexifyin[:DOL],2)
latexify(latexifyin,env=:table,latex=false) # print latex

y1 = logreturns["BBAS3"]; y2 = logreturns["DOL"]
# autocorrelation function (FAC) series
pt1 = bar(autocor(values(y1))[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC Series");
pt2 = bar(autocor(values(y2))[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC Series",color="orange");

# FAC square series
pt3 = bar(autocor((values(y1)).^2)[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC Squared Series");
pt4 = bar(autocor((values(y2)).^2)[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC Squared Series",color="orange");

# FAC module series
pt5 = bar(autocor(abs.(values(y1)))[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC module Series");
pt6 = bar(autocor(abs.(values(y2)))[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC module Series",color="orange");

plot(pt1,pt2,pt3,pt4,pt5,pt6,layout=(3,2))

# correlation between series
cor(values(y1),values(y2))

#- descriptive statistics monthly returns-#
latexifyin = DescriptiveStatistics(logreturns30["BBAS3","DOL"])
latexifyin[:BBAS3] = signif.(latexifyin[:BBAS3],2)
latexifyin[:DOL] = signif.(latexifyin[:DOL],2)
latexify(latexifyin,env=:table,latex=false) # print latex

y1 = logreturns30["BBAS3"]; y2 = logreturns30["DOL"]

# autocorrelation function (FAC) series
pt1 = bar(autocor(values(y1))[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC Series");
pt2 = bar(autocor(values(y2))[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC Series",color="orange");

# FAC square series
pt3 = bar(autocor((values(y1)).^2)[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC Squared Series");
pt4 = bar(autocor((values(y2)).^2)[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC Squared Series",color="orange");

# FAC module series
pt5 = bar(autocor(abs.(values(y1)))[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC module Series");
pt6 = bar(autocor(abs.(values(y2)))[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC module Series",color="orange");

plot(pt1,pt2,pt3,pt4,pt5,pt6,layout=(3,2))

# correlation between series
cor(values(y1),values(y2))

#- descriptive statistics returns before crisis 2008-#
latexifyin = DescriptiveStatistics(to(logreturns["BBAS3","DOL"],Date(2008,1,1)))
latexifyin[:BBAS3] = signif.(latexifyin[:BBAS3],2)
latexifyin[:DOL] = signif.(latexifyin[:DOL],2)
latexify(latexifyin,env=:table,latex=false) # print latex

y1 = to(logreturns["BBAS3"],Date(2008,1,1)); y2 = to(logreturns["DOL"],Date(2008,1,1))
# autocorrelation function (FAC) series
pt1 = bar(autocor(values(y1))[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC Series");
pt2 = bar(autocor(values(y2))[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC Series",color="orange");

# FAC square series
pt3 = bar(autocor((values(y1)).^2)[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC Squared Series");
pt4 = bar(autocor((values(y2)).^2)[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC Squared Series",color="orange");

# FAC module series
pt5 = bar(autocor(abs.(values(y1)))[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC module Series");
pt6 = bar(autocor(abs.(values(y2)))[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC module Series",color="orange");

plot(pt1,pt2,pt3,pt4,pt5,pt6,layout=(3,2))

# correlation between series
cor(values(y1),values(y2))

#- descriptive statistics returns after crisis 2008-#
latexifyin = DescriptiveStatistics(from(logreturns["BBAS3","DOL"],Date(2008,1,1)))
latexifyin[:BBAS3] = signif.(latexifyin[:BBAS3],2)
latexifyin[:DOL] = signif.(latexifyin[:DOL],2)
latexify(latexifyin,env=:table,latex=false) # print latex

y1 = from(logreturns["BBAS3"],Date(2008,1,1)); y2 = from(logreturns["DOL"],Date(2008,1,1))
# autocorrelation function (FAC) series
pt1 = bar(autocor(values(y1))[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC Series");
pt2 = bar(autocor(values(y2))[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC Series",color="orange");

# FAC square series
pt3 = bar(autocor((values(y1)).^2)[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC Squared Series");
pt4 = bar(autocor((values(y2)).^2)[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC Squared Series",color="orange");

# FAC module series
pt5 = bar(autocor(abs.(values(y1)))[2:16], label=colnames(y1)[1],ylim = [0,1], title="FAC module Series");
pt6 = bar(autocor(abs.(values(y2)))[2:16], label=colnames(y2)[1],ylim = [0,1], title="FAC module Series",color="orange");

plot(pt1,pt2,pt3,pt4,pt5,pt6,layout=(3,2))

# correlation between series
cor(values(y1),values(y2))

### durante criste
DescriptiveStatistics(to(from(logreturns["BBAS3","DOL"],Date(2008,1,1)),Date(2010,1,1)))

##############################################
#        Hypothesis Tests
##############################################
include("normalitytest.jl")
## Normality Test Results
# dayly retuns
y = logreturns["BBAS3","CSNA3"]
normtests_y = normalitytest(y)

latexifyin = normtests_y
latexify(latexifyin,env=:table,latex=false) # print latex

# monthly retuns
y30 = logreturns30["BBAS3","CSNA3"]

normtests_y30 = normalitytest(y30)
latexifyin = normtests_y30
latexify(latexifyin,env=:table,latex=false) # print latex