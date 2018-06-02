function profile = calc_profile_from_peakamps(amppeaks, pixels, xpeak_fit, widthpeak)

% for k=1:size(amppeaks,2)
%     predlorentz(:,k) = getlorentzian(pixels,xpeak_fit(k), widthpeak(k),amppeaks(k));
% end
numpeaks = length(xpeak_fit);
[x,xpeak_grid]    = meshgrid(pixels,xpeak_fit);
[x,widthpeak_grid]= meshgrid(pixels,widthpeak);

predlorentz = 1./(1+((x-xpeak_grid)./widthpeak_grid).^2);
calc_profile = predlorentz'*amppeaks';

% Sum across the lorentzians at each pixel location to get our
% calculated profile.
%calc_profile = sum(predlorentz, 2);
profile = calc_profile;