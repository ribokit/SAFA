function [peakarea_temp, profiles_temp,profiles_temp_fine] = getareapeak(pixels,xsel_fit,widthpeak_fit,alpha,Profile_tofit,numpadpeaks,Profiles_tofit_fine);

numpeaks = length(xsel_fit);
[x,xpeak_grid]    =meshgrid(pixels,xsel_fit);
[x,widthpeak_grid]=meshgrid(pixels,widthpeak_fit);

predlorentz = 1./(1+((x-xpeak_grid)./widthpeak_grid).^2);

if (nargin>5) %user wants to pad peaks at bottom of gel...
    spacing = abs(xsel_fit( 2) - xsel_fit(3));
    for i=1:numpadpeaks
        %        predlorentz(numpeaks,:) = predlorentz(numpeaks,:) + 1./(1+((pixels'-xsel_fit(numpeaks)-numpadpeaks*spacing)./widthpeak_fit(numpeaks)).^2);
        predlorentz(1,:) = predlorentz(1,:) + 1./(1+((pixels'-xsel_fit(1)-i*spacing)./widthpeak_fit(1)).^2);
    end
end
overlapmatrix = predlorentz*predlorentz';

overlapmatrix = overlapmatrix+ alpha*diag(ones(1,length(xsel_fit)));

invoverlap = inv(overlapmatrix);
overlapprofile = predlorentz*Profile_tofit;

peakamp_temp = invoverlap*overlapprofile;
profiles_temp = predlorentz'*peakamp_temp;


for j=1:size(Profile_tofit,2)
    peakarea_temp(:,j) = pi*peakamp_temp(:,j).*widthpeak_fit';
end

profiles_temp_fine = [];
if (nargin>6)
    if ~isempty(Profiles_tofit_fine);
        for k=1:size(Profiles_tofit_fine,2)
            overlapprofile = predlorentz*Profiles_tofit_fine(:,k);
            peakamp_temp = invoverlap*overlapprofile;
            profiles_temp_fine(:,k) = predlorentz'*peakamp_temp;
        end
    end
end