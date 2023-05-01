# ENERGY 191/291 HW#3

####### INITIALIZE PACKAGES ######
import Pkg;
Pkg.add("JuMP");
Pkg.add("GLPK");

# Make sure Julia can use these packages
using JuMP
using GLPK


###### SETS #########

# Production and Demand Cities 
SITES = ["Argentina" "Bolivia" "Brazil" "Chile" "Colombia" "Ecuador" "Peru" "T&T" "Uruguay" "Venezuela"]
nSITES = length(SITES)


# DISTANCE of each pipeline link [km]
# pipe from location i to location j
DISTANCE = [ [0 2225 2321 1150 4649 4340 3132 5007 221 5080]
             [2225 0 2168 1888 2436 2128 1083 3092 2364 3002]
             [2321 2168 0 3008 3678 3770 3181 3279 2252 3604]
             [1150 1888 3008 0 4231 3766 2453 4970 1269 4886]
             [4649 2436 3678 4231 0 710 1878 1556 4771 1024]
             [4340 2128 3770 3766 710 0 1322 2226 4489 1730]
             [3132 1083 3181 2453 1878 1322 0 3050 3305 2741]
             [5007 3092 3279 4970 1556 2226 3050 0 5059 619]
             [221 2364 2252 1369 4771 4489 3305 5059 0 5160]
             [5080 3002 3604 4886 1024 1730 2741 619 5160 0]]

###### PARAMETERS and DATA ###############

# unit pipe cost [$/m3 per 1000km]
UnitPipeCost = 0.020 
# The cost of pipe (computed parameter) [$/m3]
PipeCost = zeros(nSITES, nSITES)
for i = 1:nSITES
    for j = 1:nSITES
        PipeCost[i,j] = DISTANCE[i,j]*UnitPipeCost * 0.001
    end
end

# The cost of LNG pipeline [$/m3-1000km]
CostLNG = 0.015 
# The amount production and consumption for each country [m3 x 10^9]
Consumption =  [43.13 2.83 18.72 2.83 8.69 0.28 3.48 20.87 0.04 20.22]
Production = [41.37 12.63 10.28 1.36 10.48 0.28 3.48 40.61 0.00 18.43]

#Consumption and Production growth rate
ConsumpGrowth = [3 2 2 3 3 3 2 4 2 2]
ProductGrowth = [2 3 3 2 -1 3 5 -3 0 7]

#adjust based on the Export at Trinidad
LNGexport = sum(Production - Consumption)
Production[8] = Production[8] - LNGexport


#### INITIALIZE MODEL ####
m = Model(GLPK.Optimizer)

###### VARIABLES #####

# The amount Shipped between each source and each injector [Mt]
@variable(m, Ship[1:nSITES,1:nSITES] >= 0)

###### CONSTRAINTS #######

# Conservation of flow 
@constraint(m, [i=1:nSITES, j=1:nSITES], sum(Ship[j,i]-Ship[i,j]) == Production[j] - Consumption[j])


######### OBJECTIVE FUNCTION ################

# Minimize the total costs of pipeline [Mt-km/*$/Mt-km = $]
@objective(m, Min, sum(Ship[i,j]*PipeCost[i,j] for i=1:nSITES, j=1:nSITES) + CostLNG * LNGexport)

# Solve the model
optimize!(m)




#### PRINTING RESULTS ####
ObjValue = objective_value(m)
DecisionValues = value.(Ship)
print(ObjValue)
display(DecisionValues)

