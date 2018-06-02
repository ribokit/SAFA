function [profiles] = calculateprofiles(xsel_bound_fine,imagey,numfinebins)
%[profiles] =calculateprofiles(ysel_center,xsel_center_finebin,xsel_bound,imagey,scale,displacement,whichlane);
%   Integrates down lanes, or subdivisions of lanes
%    Rhiju Das, August 31, 2003.

numpixels=size(imagey,1);numxpixels=size(imagey,2);
count = size(xsel_bound_fine,1);
profiles=zeros(numpixels,count-1);

for j=1:numpixels;
    for k=1:count-1
        % Include all counts for all pixels definitely in between these fine "sub-lane" boundaries.
        profiles(j,k) = sum(imagey(j,...
            ceil(xsel_bound_fine(k,j)) : floor(xsel_bound_fine(k+1,j))-1),2);
        % Then add in fractions of counts associated with pixels right at the
        % boundaries.
        profiles(j,k) = profiles(j,k) +  ...
            imagey(j, ceil(xsel_bound_fine(k,j)) - 1)  *  (ceil(xsel_bound_fine(k,j))     - xsel_bound_fine(k,j)) + ...
            imagey(j, floor(xsel_bound_fine(k+1,j)))   *  ((xsel_bound_fine(k+1,j) - floor(xsel_bound_fine(k+1,j))));            
    end
end    


%hold off;image(profiles/20);
%title(['Profiles down each lane with ',num2str(numfinebins),' subdivisions'])

