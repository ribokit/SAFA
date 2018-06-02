function [peakarea_lin,profiles_pred,xsel_all,widthpeak_all,whichpeaks,dwhichpeaks,profiles_pred_fine] = peakfitlinear_refineboot(profiles_combine,numfinebins,xsel,alpha,numres_refine,profiles);
%
% For each lane, does an initial fitting of peak amplitudes, positions, and
% two Lorentzian constants. Then it does a linear regression to fit the
% remaining peak amplitudes, 
%
%
% Added some modifications of positivity constraint, and also fits to
% each discrete column of 2D image... RD Sep 6, 2004
%

warning off MATLAB:singularMatrix

figure(2);
numpeaks = length(xsel); 
if (nargin < 7) propconst=0.1; minwidth=2; end

numlanes = size(profiles_combine,2); 
profiles_pred      = profiles_combine*0;
profiles_pred_fine = profiles_combine*0;

%peakarea_lin = zeros(numpeaks,numlanes);
%peakamp_lin = zeros(numpeaks,numlanes);
tmpbreak=0;
for j=1:numlanes
    Profile_tofit = profiles_combine(:,j);
    propconst = 0.1; minwidth = 3;
    fprintf(1,'Now fitting lane %d ...', j);
    
    %First fit the first few residues with general peak model, varying peak
    % positions, amplitudes, and the two parameters of the peak width model
    [xpeak_fit,widthpeak,amppeak,areapeak,propconst,minwidth] = fitset_constrwid_useexp(Profile_tofit,numres_refine,xsel,propconst,minwidth);
    figure(2);
    subplot(3,1,1); xlabel('pixel'); ylabel(['Profile in lane ',num2str(j)]);
    legend('expt profile','fit with lorentzians','individual lorentzians');
    title(['Lane ',num2str(j)]);
    
    distpeak = getdistpeak(xpeak_fit);
    
    subplot(3,1,2); xlabel('residue number'); ylabel('Counts');
    legend('Fitted band area, peak positions refit');
    peakmove = 0.5* (xpeak_fit - xsel(numres_refine))./widthpeak';
    avgpeakmove = 100*sqrt(mean(peakmove.^2));
    title(['Lane ',num2str(j),' positions refit by ',num2str(avgpeakmove,3),'% of width (rms)']);
    fprintf(1,' peak positions refit by %4.1f %% of width (rms).\n', squeeze(avgpeakmove));
    
    xsel_all(:,j) = xsel';
    xsel_all(numres_refine,j) = xpeak_fit';
    
    xsel_refine = xsel;
    xsel_refine(numres_refine) = xpeak_fit;
    
    %Now get set up to fit all peak positions defined by the user!
    %Constrain peak positions to the refit values above, or the 
    % user-defined guesses for the peak positions not fit above..
    count=0;
    startpeak = min(find(xsel_refine>0));    endpeak   = numpeaks; 
    
    whichpeaks = startpeak:endpeak;
    %    whichpeaks = numres_refine;
    numallpeaks = length(whichpeaks);
    
    distpeak = getdistpeak(xsel_refine(whichpeaks));
    widthpeak = distpeak*propconst + minwidth;
    widthpeak_all(whichpeaks,j) = widthpeak';
    
    startbin = max(round(min(xsel_refine(whichpeaks))-max(widthpeak)) , 1);
    endbin   = min(round(max(xsel_refine(whichpeaks))+max(widthpeak)) ,  size(profiles_combine,1));
    
    pixels = [startbin:endbin]';
    
    Profile_tofit       = profiles_combine(startbin:endbin,j);
    Profiles_tofit_fine = [];
    if (nargin>5)
        finelanes = (j-1)*numfinebins+1 :  j*numfinebins;
        Profiles_tofit_fine = profiles        (startbin:endbin,finelanes);
    end    
    
    %numpadpeaks = 10; %  Assumes gel was cut off at bottom; only really makes a difference to bottommostband.
    numpadpeaks = 0; %  No pad peaks
    
    % Use linear regression to obtain our experimental peak areas and profile
    [peakarea_temp, profiles_temp,profiles_temp_fine] = getareapeak(pixels,xsel_refine(whichpeaks),widthpeak,alpha,Profile_tofit,numpadpeaks,Profiles_tofit_fine);
    
    subplot(3,1,2); % Return to the middle plot
    hold on;  plot(whichpeaks,peakarea_temp);hold off;
    legend('Fitted band area, peak positions refit','All fitted band areas');
    %    axis([min(numres_refine)-10 max(numres_refine)+10 0 max(areapeak)]);
    axis([startpeak-1 endpeak+1 0 max(areapeak)]);
    
    %Check if any negative amplitudes were fit -- that shouldn't happen!
    numfitpeaks = length(peakarea_temp); maxpeak = max(numfitpeaks-5,2);
    if ~isempty(find(peakarea_temp(2:maxpeak)  <  0)) 
        
        subplot(3,1,1); % Make sure our refitting is shown in the first plot
        % Here use leasqr with exp to ensure non-negative peakareas on all peaks
        %        mean_amppeak = mean(amppeak, 2);
        %        amppeak_guesses = mean_amppeak*ones(1,size(xsel_refine_whichpeaks,2));
        amppeak_guesses = (1/pi)*abs(peakarea_temp./widthpeak');
        log_amppeak_guesses = log(amppeak_guesses);
        % Uses the log of peakamps and then exp() to ensure non-negative peak amps, and thus peak areas
        [peakarea_temp, profiles_temp] = getareapeak_useexp(pixels,log_amppeak_guesses,xsel_refine(whichpeaks),widthpeak,Profile_tofit,propconst,minwidth);
        
        subplot(3,1,2);
        hold on;  plot(whichpeaks,peakarea_temp,'c');hold off;
        legend('Fitted band area, peak positions refit','All fitted band areas','All fitted band areas, force positive');
    end
    
    profiles_pred(pixels,j) = profiles_temp; 
    if (nargin>5) 
        profiles_pred_fine(pixels,finelanes) = profiles_temp_fine; 
    end

    
    subplot(3,1,3);
    semilogy([Profile_tofit profiles_temp]);
    title(['Lane ',num2str(j)]);
    legend('whole expt profile','fit with lorentzians')
    peakarea_lin(:,j) = peakarea_temp;
    
    if tmpbreak==0
        Click=questdlg('Fit all the data once? Click no to fit one lane at a time.','Fit next Lane','Yes');
        if strcmp(Click,'Yes') == 1
            tmpbreak=1;
        end
        if strcmp(Click,'No') == 1
            tmpbreak=0;
        end
        if strcmp(Click,'Cancel') == 1
            break;
        end
    end
end

%rms_xsel_refinement = mean( std(xsel_all(numres_refine,:)'));
xpeak = xsel(whichpeaks); numpeaks = length(whichpeaks);
distpeak = getdistpeak(xpeak);
widthpeak = distpeak'*propconst + minwidth;

%dwhichpeaks = rms_xsel_refinement./distpeak;
dwhichpeaks = min( mean(widthpeak,2)./distpeak', 20);

