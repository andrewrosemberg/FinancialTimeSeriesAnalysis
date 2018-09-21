using TimeSeries
using StatsBase
using DataFrames
using Plots
using Latexify
include("DescriptiveStatistics.jl")
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
plot(timestamp(returns),values(logreturns["BBAS3"])*100, label="logreturns", xlabel="Dates",ylabel="Returns")

plot(timestamp(returns),values(returns["DOL"]),title="DOLAR Daily Returns", label="returns", xlabel="Dates",ylabel="Returns");
plot(timestamp(returns),values(logreturns["DOL"])*100, label="logreturns", xlabel="Dates",ylabel="Returns")

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

## Calculate descriptive statistics entire series

# descriptive statistics daily returns-#
latexifyin = DescriptiveStatistics(logreturns["BBAS3","DOL"])
latexify(signif.(latexifyin,2)) # print latex

y1 = logreturns["BBAS3"]; y2 = logreturns["DOL"]
# autocorrelation function (FAC) series
bar(autocor(values(y1))[2:16], label=colnames(y1)[1], title="FAC Series")
bar(autocor(values(y2))[2:16], label=colnames(y2)[1], title="FAC Series")

# FAC square series
bar(autocor((values(y1)).^2)[2:16], label=colnames(y1)[1], title="FAC Squared Series")
bar(autocor((values(y2)).^2)[2:16], label=colnames(y2)[1], title="FAC Squared Series")

# FAC module series
bar(autocor(abs.(values(y1)))[2:16], label=colnames(y1)[1], title="FAC Squared Series")
bar(autocor(abs.(values(y2)))[2:16], label=colnames(y2)[1], title="FAC Squared Series")

# correlation between series
cor(values(y1),values(y2))

#- descriptive statistics monthly returns-#
DescriptiveStatistics(logreturns30["BBAS3","DOL"])

y1 = logreturns30["BBAS3"]; y2 = logreturns30["DOL"]

# autocorrelation function (FAC) series
bar(autocor(values(y1))[2:16], label=colnames(y1)[1], title="FAC Series")
bar(autocor(values(y2))[2:16], label=colnames(y2)[1], title="FAC Series")

# FAC square series
bar(autocor((values(y1)).^2)[2:16], label=colnames(y1)[1], title="FAC Squared Series")
bar(autocor((values(y2)).^2)[2:16], label=colnames(y2)[1], title="FAC Squared Series")

# FAC module series
bar(autocor(abs.(values(y1)))[2:16], label=colnames(y1)[1], title="FAC Squared Series")
bar(autocor(abs.(values(y2)))[2:16], label=colnames(y2)[1], title="FAC Squared Series")

# correlation between series
cor(values(y1),values(y2))

#- descriptive statistics returns before crisis 2008-#
DescriptiveStatistics(to(logreturns["BBAS3","DOL"],Date(2008,1,1)))

y1 = to(logreturns["BBAS3"],Date(2008,1,1)); y2 = to(logreturns["DOL"],Date(2008,1,1))
# autocorrelation function (FAC) series
bar(autocor(values(y1))[2:16], label=colnames(y1)[1], title="FAC Series")
bar(autocor(values(y2))[2:16], label=colnames(y2)[1], title="FAC Series")

# FAC square series
bar(autocor((values(y1)).^2)[2:16], label=colnames(y1)[1], title="FAC Squared Series")
bar(autocor((values(y2)).^2)[2:16], label=colnames(y2)[1], title="FAC Squared Series")

# FAC module series
bar(autocor(abs.(values(y1)))[2:16], label=colnames(y1)[1], title="FAC Squared Series")
bar(autocor(abs.(values(y2)))[2:16], label=colnames(y2)[1], title="FAC Squared Series")

# correlation between series
cor(values(y1),values(y2))

#- descriptive statistics returns after crisis 2008-#
DescriptiveStatistics(from(logreturns["BBAS3","DOL"],Date(2008,1,1)))

y1 = from(logreturns["BBAS3"],Date(2008,1,1)); y2 = from(logreturns["DOL"],Date(2008,1,1))
# autocorrelation function (FAC) series
bar(autocor(values(y1))[2:16], label=colnames(y1)[1], title="FAC Series")
bar(autocor(values(y2))[2:16], label=colnames(y2)[1], title="FAC Series")

# FAC square series
bar(autocor((values(y1)).^2)[2:16], label=colnames(y1)[1], title="FAC Squared Series")
bar(autocor((values(y2)).^2)[2:16], label=colnames(y2)[1], title="FAC Squared Series")

# FAC module series
bar(autocor(abs.(values(y1)))[2:16], label=colnames(y1)[1], title="FAC Squared Series")
bar(autocor(abs.(values(y2)))[2:16], label=colnames(y2)[1], title="FAC Squared Series")

# correlation between series
cor(values(y1),values(y2))

### durante criste
DescriptiveStatistics(to(from(logreturns["BBAS3","DOL"],Date(2008,1,1)),Date(2010,1,1)))
