% Assignment_1
%  Group 16, AA2023-2024
%

%% Clear the workspace
clear
close all
clc

%% Fix the random seed
rng(42);

%% Pricing parameters
S0=1;
K=1;
r=0.03;
TTM=1/4; 
sigma=0.22;
flag=1; % flag:  1 call, -1 put
d=0.06;

%% Quantity of interest
B=exp(-r*TTM); % Discount

%% Pricing 
F0=S0*exp(-d*TTM)/B;     % Forward in G&C Model

%% Point a

%   Price the option, 
%   considering an underlying price equal to 1 Euro (i.e a derivative Notional of 1 Mln Euro): 
%   i) via blkprice Matlab function; 
%   ii) with a CRR tree approach; 
%   iii) with a Monte-Carlo (MC) approach. 

M=100; % M = simulations for MC, steps for CRR;

optionPrice = zeros(3,1);

for i=1:3
    pricingMode = i; % 1 ClosedFormula, 2 CRR, 3 Monte Carlo
    optionPrice(i) = EuropeanOptionPrice(F0,K,B,TTM,sigma,pricingMode,M,flag);
end

fprintf(['\nOPTION PRICE \n' ...
        'BlackPrice :   %.4f \n'],optionPrice(1));
fprintf('CRRPrice   :   %.4f \n',optionPrice(2));
fprintf('MCPrice    :   %.4f \n',optionPrice(3));

%% Point b and Point c

% plot Errors for CRR varing number of steps
[nCRR,errCRR]=PlotErrorCRR(F0,K,B,TTM,sigma);
% plot Errors for MC varing number of simulations N 
[nMC,stdEstim]=PlotErrorMC(F0,K,B,TTM,sigma); 

% spread is 1 bp
spread = 10^-4;

% find the optimal M for CRR and MC
M_CRR = nCRR(find(errCRR < spread,1));
M_MC = nMC(find(stdEstim < spread,1));

fprintf(['\nOPTIMAL M FOR CRR \n' ...
        'Number of intervals CRR :   %.d \n'],M_CRR);
fprintf(['\nOPTIMAL M FOR MC \n' ...
        'Number of intervals CRR :   %.d \n'],M_MC);
%% Point d

%   Price also a European Call Option with European barrier at €1.3 (up&in) and same parameters with 
%   the two numerical techniques (tree & MC). Does it exist a closed formula also in this case? If yes, 
%   compare the results. 

% set the barrier
KI = 1.3;

M = 1000;  

% store the prices
optionPriceKI = zeros(3,1);

% closed formula
optionPriceKI(1) = EuropeanOptionKIClosed(F0,K,KI,B,TTM,sigma);
% CRR
optionPriceKI(2) = EuropeanOptionKICRR(F0,K,KI,B,TTM,sigma,M);
% monte carlo
optionPriceKI(3) = EuropeanOptionKIMC(F0,K,KI,B,TTM,sigma,M);

fprintf(['\nOPTION PRICE KI \n' ...
        'ClosedPriceKI  :   %.4f \n'],optionPriceKI(1));
fprintf('CRRPriceKI     :   %.4f \n',optionPriceKI(2));
fprintf('MCPriceKI      :   %.4f \n',optionPriceKI(3));

%% Point e

%   For this barrier option, plot the Vega (possibly using both the closed formula and a numerical 
%   estimate) with the underlying price in the range 0.70 Euro and 1.5 Euro. Comment the results. 


S_start = 0.7;
S_end = 1.5;

rangeS0 = linspace(S_start,S_end,100);
% compute the corresponding forward prices
rangeF0 = rangeS0*exp(-d*TTM)/B;

M = 10000;

% closed formula vegas
vegasClosed = zeros(length(rangeS0),1);
for i = 1:length(rangeS0)
    vegasClosed(i) = VegaKI(rangeF0(i),K,KI,B,TTM,sigma,M,3);
end

% MC vegas
vegasMC = zeros(length(rangeS0),1);
for i = 1:length(rangeS0)
    vegasMC(i) = VegaKI(rangeF0(i),K,KI,B,TTM,sigma,M,2);
end

% CRR vegas
vegasCRR = zeros(length(rangeS0),1);
for i = 1:length(rangeS0)
    vegasCRR(i) = VegaKI(rangeF0(i),K,KI,B,TTM,sigma,M,1);
end

% plot the results
figure
subplot(1,2,1)
plot(rangeS0,vegasClosed)
title('Vega Closed Formula')
xlabel('S0')
ylabel('Vega')
hold on
plot(rangeS0,vegasMC)
title('Vega Monte Carlo')
xlabel('S0')
ylabel('Vega')

legend('Closed','MC')


subplot(1,2,2)
plot(rangeS0,vegasClosed)
title('Vega Closed Formula')
xlabel('S0')
ylabel('Vega')
hold on 
plot(rangeS0,vegasCRR)
title('Vega CRR')
xlabel('S0')
ylabel('Vega')

legend('Closed','CRR')

%% MC trick

vegasTrick = zeros(length(rangeS0),1);
for i = 1:length(rangeS0)
    vegasTrick(i) = VegaMCTrick(rangeF0(i),K,KI,B,TTM,sigma,M);
end

figure
plot(rangeS0,vegasTrick)
hold on
plot(rangeS0,vegasClosed)
title('Vega Monte Carlo Trick')
xlabel('S0')
ylabel('Vega')

legend('Trick','Closed')

%% Point f

% Does antithetic variables technique (Hull 2009, Ch.19.7) reduce MC error of point b.? 

[nMCAV,stdEstimAV]=PlotErrorMCAV(F0,K,B,TTM,sigma);

% Plot the results of MC
figure
loglog(nMCAV,stdEstimAV)
title('MC antithetic variable')
hold on 
loglog(nMCAV,1./sqrt(nMCAV))
% cutoff
loglog(nMCAV, spread * ones(length(nMCAV),1))
loglog(nMC,stdEstim)

legend('MC AV','1/sqrt(nMC)','cutoff','MC')

%% point g

%   Price also -with the Tree- a Bermudan option, where the holder has also the right to exercise 
%   the option at the end of every month, obtaining the stock at the strike price. 


S0=K;  % TO BE CHECKED
F0=S0*exp(-d*TTM)/B;

OptionPriceBermudan = BermudanOptionCRR(F0, K, B, TTM, sigma, M, flag);
fprintf('CRRPriceBermudan      :   %.4f \n',OptionPriceBermudan);

%% point h

%   Pricing the Bermudan option, vary the dividend yield between 0% and 6% and compare 
%   with the corresponding European price. Discuss the results.
M=1000;
d=[0:0.005:0.06];
Delta_price=zeros(length(d),1);
for i=1:length(d)
    F0=S0*exp(-d(i)*TTM)/B;
    OptionPriceBermudan = BermudanOptionCRR(F0, K, B, TTM, sigma, M, flag);
    Delta_price=OptionPriceBermudan-EuropeanOptionCRR(F0, K, B, TTM, sigma, M, flag);
end
figure
loglog(d,Delta_price,'x')

