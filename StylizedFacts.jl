using TimeSeries
using StatsBase
using DataFrames
using Plots
plotly()

# Load Data
#history = readtimearray(".\\docs\\Presentations\\plot_history\\baseG18.csv")
history = readtimearray(".\\docs\\HistoricoLista1SF.csv", format="dd/mm/yyyy") #delim=';')
numA = size(history,2)
datesOriginal = timestamp(history)

## Prepare data

historyNoNA = history[datesOriginal[vec(!any(isnan.(values(history)),2))]]
numD,numA = size(historyNoNA)       # A: Assets    D: Days
dates = timestamp(historyNoNA)

#term = Date(2018,02)
#tm_corridos = Int.(term-dates)
#tm_uteis = Int.(bdays.(BusinessDays.Brazil(), dates, term))

## visualize data
plot(historyNoNA, xlabel="Dates",ylabel="Prices")

plot(historyNoNA["BBAS3"], xlabel="Dates",ylabel="Prices")

plot(historyNoNA["DOL"], xlabel="Dates",ylabel="Prices")

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


# Calculate arithmetic returns and log returns daily
returns30 = percentchange(historyNoNA[dates[1:22:end]])
numD,numA =size(returns30)

logreturns30 = percentchange(historyNoNA[dates[1:22:end]], :log)
numD,numA =size(logreturns30)

plot(timestamp(returns30),values(returns30["BBAS3"]), title="BBAS3 Monthly Returns", label="returns", xlabel="Dates",ylabel="Returns");
plot!(timestamp(returns30),values(logreturns30["BBAS3"]), label="logreturns", xlabel="Dates",ylabel="Returns")

plot(timestamp(returns30),values(returns30["DOL"]), title="DOLAR Monthly Returns", label="returns", xlabel="Dates",ylabel="Returns");
plot!(timestamp(returns30),values(logreturns30["DOL"]), label="logreturns", xlabel="Dates",ylabel="Returns")

## Descriptive statistics entire series
y1 = logreturns["BBAS3"]; y2 = logreturns["DOL"]
ds = DataFrame(stat = String[], BBAS3 = Float64[], DOL = Float64[])
# mean
push!(ds, ["mean", mean(values(y1)),mean(values(y2))])
#mean(logreturns["BBAS3","DOL"])
# median
push!(ds, ["median", median(values(y1)),median(values(y2))])
#median(values(logreturns["BBAS3","DOL"]),1)
# mode
push!(ds, ["mode", mode(values(y1)),mode(values(y2))])
# std
push!(ds, ["std", std(values(y1)),std(values(y2))])
#std(logreturns["BBAS3","DOL"])
# max
push!(ds, ["maximum", maximum(values(y1)),maximum(values(y2))])
# min
push!(ds, ["minimum", minimum(values(y1)),minimum(values(y2))])
# quantiles
push!(ds, ["quantile 1%", percentile(values(y1),1),percentile(values(y2),1)])
push!(ds, ["quantile 5%", percentile(values(y1),5),percentile(values(y2),5)])
push!(ds, ["quantile 10%", percentile(values(y1),10),percentile(values(y2),10)])
push!(ds, ["quantile 90%", percentile(values(y1),90),percentile(values(y2),90)])
push!(ds, ["quantile 95%", percentile(values(y1),95),percentile(values(y2),95)])
push!(ds, ["quantile 99%", percentile(values(y1),99),percentile(values(y2),99)])

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

# kurtosis
kurtosis(values(y1))+3
kurtosis(values(y2))+3

# skewness (sk1)
skewness(values(y1))
skewness(values(y2))

# sk2
function sk2(y)
    (percentile(y,75)+percentile(y,25)-2*percentile(y,50))/(percentile(y,75)-percentile(y,25))
end


# sk3
function sk3(y)
    (mean(y)-median(y))/mean(abs.(y-median(y)))
end
