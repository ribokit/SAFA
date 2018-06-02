function [peakarea_temp, profiles_temp] = getareapeak(pixels,log_amppeak_guesses,xsel_refine_whichpeaks,widthpeak_fit,Profile_tofit,propconst,minwidth);
%
% Modified by R. Das, Sam Pearlman cinco de mayo, 2004.
% Now we refit all the peak amplitudes, keeping the peak locations and
% lorentzian constants fixed.

stol=0.01;
niter=5;
wt=0*pixels+1;
dp=0*widthpeak_fit+1;

[f,params,kvg,iter,corp,covp,covr,stdresid,Z,r2]= ...
    leasqr_constparams(pixels, Profile_tofit,log_amppeak_guesses,...
    'predict_profile_constrwid_useexp_constparams',stol,niter,wt,dp,...
    'predict_partials_constrwid_useexp_constparams',[xsel_refine_whichpeaks propconst minwidth]);

% Now that we have done a least-squares fitting on all the peak amplitudes,
% we calculate the areas
peakamps = exp(params);

for j=1:size(Profile_tofit,2)
    peakarea_temp(:,j) = pi*peakamps(:,j).*widthpeak_fit';
end

profiles_temp = calc_profile_from_peakamps(peakamps', pixels, xsel_refine_whichpeaks, widthpeak_fit);
