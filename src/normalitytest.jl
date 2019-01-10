##############################################
#        Hypothesis Tests
##############################################
using HypothesisTests
using RCall
using StatsBase
using Distributions

#R"library(goftest)"
R"library(nortest)"

# Jarque Bera
function jbtest(x::Vector)
    n = length(x)
    m1 = sum(x)/n
    m2 = sum((x - m1).^2)/n
    m3 = sum((x - m1).^3)/n
    m4 = sum((x - m1).^4)/n
    b1 = (m3/m2^(3/2))^2
    b2 = (m4/m2^2)
    statistic = n * b1/6 + n*(b2 - 3)^2/24
    d = Chisq(2.)
    pvalue = 1.-cdf(d,statistic)
    statistic, pvalue
end

# # D'Agostino Pearson
# function skewtest(x::Vector)
#     n = length(x)
#     m1 = sum(x)/n
#     m2 = sum((x - m1).^2)/n
#     b2 = sum((x - m1).^3)/n
#     if n < 8
#         error("skewtest is not valid with less than 8 samples")
#     end
#     y = b2 * sqrt(((n + 1) * (n + 3)) / (6.0 * (n - 2)))
#     beta2 = (3.0 * (n^2 + 27*n - 70) * (n+1) * (n+3) /
#              ((n-2.0) * (n+5) * (n+7) * (n+9)))
#     W2 = -1 + sqrt(2 * (beta2 - 1))
#     delta = 1 / sqrt(0.5 * log(W2))
#     alpha = sqrt(2.0 / (W2 - 1))    
#     y = (y==0 ? 0: 1)
#     Z = delta * log(y / alpha + sqrt((y / alpha)^2 + 1))
# end

# function kurtosistest(x::Vector)
#     n = length(x)
#     m1 = sum(x)/n
#     m2 = sum((x - m1).^2)/n
#     b2 = sum((x - m1).^4)/n

#     E = 3.0*(n-1) / (n+1)
#     varb2 = 24.0*n*(n-2)*(n-3) / ((n+1)*(n+1.)*(n+3)*(n+5))  # [1]_ Eq. 1
#     x = (b2-E) / sqrt(varb2)  # [1]_ Eq. 4
#     # [1]_ Eq. 2:
#     sqrtbeta1 = 6.0*(n*n-5*n+2)/((n+7)*(n+9)) * sqrt((6.0*(n+3)*(n+5)) /
#                                                         (n*(n-2)*(n-3)))
#     # [1]_ Eq. 3:
#     A = 6.0 + 8.0/sqrtbeta1 * (2.0/sqrtbeta1 + sqrt(1+4.0/(sqrtbeta1^2)))
#     term1 = 1 - 2/(9.0*A)
#     denom = 1 + x*sqrt(2/(A-4.0))
#     denom = (denom < 0 ? 99: denom)
#     term2 = (denom < 0 ? term1: ((1-2.0/A)/denom)^ (1/3.0))    
#     Z = (term1 - term2) / sqrt(2/(9.0*A))  # [1]_ Eq. 5
#     Z = (denom == 99 ?  0: Z)
# end

# function DPtest(x::Vector)
#     n = length(x)
#     m1 = sum(x)/n
#     m2 = sum((x - m1).^2)/n
#     m3 = sum((x - m1).^3)/n
#     m4 = sum((x - m1).^4)/n
#     b1 = (m3/m2^(3/2))^2
#     b2 = (m4/m2^2)
#     s = skewtest(x)    
#     k = kurtosistest(x)
#     k2 = s*s + k*k
#     d = Chisq(2.)
#     pvalue = 1.-cdf(d,k2)
#     k2, pvalue
# end


function normalitytest(y)
    ds = DataFrame()
    for i=1:size(y,2)+1
        if i == 1
            ds[Symbol("Test")]= String[]
        else
            ds[Symbol(colnames(y)[i-1])]= Tuple{Float64,Float64}[]
        end
    end
    # Jarque Bera
    testresults =[ signif.(jbtest(values(y[colnames(y)[i]])),2) for i=1:size(colnames(y))[1]][:]
    push!(ds, vcat(["Jarque Bera"],testresults))

    # D'Agostino Pearson
    #testresults =[ signif.(DPtest(values(y[colnames(y)[i]])),2) for i=1:size(colnames(y))[1]][:]
    
    #R call
    for i=1:size(colnames(y),1)
        y_aux = values(y[colnames(y)[i]]);
        
        @rput y_aux
        R"result = pearson.test(y_aux)"
        resulttest = rcopy(R"result")

        testresults[i] = signif.((resulttest[:statistic],resulttest[:p_value]),2)
    end    
    
    push!(ds, vcat(["D'Agostino Pearson"],testresults))
    

    # Anderson-Darling test
    #testresults = Array{Tuple{Float64,Float64},1}(size(colnames(y)))

    for i=1:size(colnames(y),1)
        y_aux = values(y[colnames(y)[i]]);
        n = length(y_aux)
        m1 = sum(y_aux)/n
        m2 = sum((y_aux - m1).^2)/n
        sd = sqrt(m2)

        #d = Normal(m1,m2)
        #resulttest = OneSampleADTest(y_aux,d);
        #testresults[i] = signif.((resulttest.A²,pvalue(resulttest)),2)

        # R call
        @rput y_aux
        #@rput m1
        #@rput sd
        R"result = ad.test(y_aux)"
        resulttest = rcopy(R"result")

        testresults[i] = signif.((resulttest[:statistic],resulttest[:p_value]),2)
    end
    push!(ds, vcat(["Anderson-Darling"],testresults))

    ds
end