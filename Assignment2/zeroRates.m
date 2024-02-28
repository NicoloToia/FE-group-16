function [zRates] = zeroRates(dates, discounts)
% zeroRates Compute zero rates from discount factors
%
% INPUT:
% dates     - vector of dates
% discounts - vector of discount factors
%
% OUTPUT:
% zRates    - vector of zero rates
    
zRates = -log(discounts) ./ yearfrac(dates(1), dates);
zRates(1) = zRates(2);
zRates = zRates * 100;

end