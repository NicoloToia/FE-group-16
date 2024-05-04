function sigmas = intSpotVols(target_strike, target_ttms, spot_vols, ttms, strikes)
% INTSPOTVOLS interpolates the spot volatilities to the target strikes and
% deltas (linear interpolation in the time dimension and spline in the strike)
%
% INPUT
%   target_strike: the target strike
%   target_ttms: the target time to maturities
%   spot_vols: the spot volatilities
%   ttms: the time to maturities
%   strikes: the strikes

% initialize the needed spot volatilities
needed_spot_vols = zeros(length(target_ttms), length(strikes));

% interpolate linearly by columns
for i = 1:length(strikes)
    % interpolate the spot volatilities (extrapolate with flat if needed)
    needed_spot_vols(:,i) = interp1(ttms, spot_vols(:,i), target_ttms, 'linear', spot_vols(1,i));
end

% initialize the vector of sigmas to use in the Bachelier formula
sigmas = zeros(length(target_ttms), 1);

% interpolate the strike using spline
for i = 1:length(target_ttms)
    sigmas(i) = interp1(strikes, needed_spot_vols(i,:), target_strike, 'spline');
end 

end