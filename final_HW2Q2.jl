#Homework2 California LCFS refinery purchasin

import Pkg;
Pkg.add("JuMP")
Pkg.add("GLPK")

using JuMP
using GLPK

#Minimize:

CRUDEOIL = ["Bacha","Maya","Arab","Mars","Bonny","Krik","SAGD","Mining","CA"]
nCRUDEOIL = length(CRUDEOIL)

AvailableCrude = [50000, 60000, 20000, 60000, 4000, 20000, 75000, 60000, 130000]
#const 
PurchaseCost = [13.86, 14.87, 15.46, 18.36, 17.43, 16.3, 13.47, 13.47, 13.18]
RefineCost = [2.31, 2.00, 1.99, 1.96, 1.91, 1.90, 2.36, 2.36, 2.30]
#crude characteristics 
Gravity = [10.7, 22.0, 31.1, 31.5, 32.9, 36.6, 8.5, 8.3, 13.4]
#emissions
ProdEmission = [2.5, 6.2, 3.5, 3.2, 15.1, 5.6, 15.9, 7.8, 16.0]
#refine emissions = 14.16 - 0.13*Gravity
RefineEmission = zeros(1,nCRUDEOIL)
for i = 1:nCRUDEOIL
    RefineEmission[i] = 14.16 - 0.13*Gravity[i] 
end
#Yield (GJ/GJ input)
GasYield = [0.22, 0.31, 0.40, 0.42, 0.45, 0.51, 0.20, 0.20, 0.26]
DieselYield = [0.24, 0.22, 0.28, 0.22, 0.23, 0.21, 0.24, 0.24, 0.25]
AsphaltYield = [0.49, 0.41, 0.27, 0.31, 0.27, 0.13, 0.51, 0.51, 0.44]
TotalYield = zeros(1,nCRUDEOIL)
for i = 1:nCRUDEOIL
    TotalYield[i] = GasYield[i] + DieselYield[i] + AsphaltYield[i] 
end
#worth
GasWorth = 21.65 #$/GJ
DieselWorth = 20.43 #$/GJ
AsphaltWorth = 16.35 #$/GJ
#total worth
TotalWorth = zeros(1,nCRUDEOIL)
for i = 1:nCRUDEOIL
    TotalWorth[i] = GasWorth*GasYield[i] + DieselWorth*DieselYield[i] + AsphaltWorth*AsphaltYield[i]
end
#fixed constraints
CRUDEINPUT = 1.35*10^5 #GJ of crude oil inputs per day
EMISSION = 2.3625*10^6 #kgCO2/ GJ input


m = Model(GLPK.Optimizer)

#variable declaration
@variable(m, PurchaseCrude_[1:nCRUDEOIL] >= 0);

@objective(m, Max, sum(-(PurchaseCost[i]+RefineCost[i])*PurchaseCrude_[i] +TotalWorth[i]*PurchaseCrude_[i] for i = 1:nCRUDEOIL))

#Subject to:
#availability
@constraint(m,[i = 1:nCRUDEOIL], PurchaseCrude_[i] <= AvailableCrude[i])
#emissions
@constraint(m, sum((ProdEmission[i]
+RefineEmission[i])* PurchaseCrude_[i] for i = 1:nCRUDEOIL) <= EMISSION)
#input rate
@constraint(m, sum(PurchaseCrude_[i] for i = 1:nCRUDEOIL) == CRUDEINPUT )

#the commend that solves it
optimize!(m) 

#solution printiing
print(objective_value(m))
print(value.(PurchaseCrude_))
