function [profiles] = calculateprofiles_call_comp(xsel_bound_fine,imagey,numfinebins);%[profiles] = calculateprofiles_call_comp(xsel_bound_fine,imagey,numfinebins);%   Integrates down lanes, or subdivisions of lanes%    Rhiju Das, August 31, 2003.%    Updated Alain Laederach Sept. 04 2003, to include a fast compiled%    C-Mex file, fast_loop.c, must be precompiled, please type%    fast_loop.c prior to executing this functioncount = size(xsel_bound_fine',2);imagey=imagey';%   Call C-routine for fast loopingprofiles = fast_loop(imagey,xsel_bound_fine);   %profiles=profiles';%profiles=profiles(:,1:count-1);%figure(1)%hold off;image(profiles/20);%title(['Profiles down each lane with ',num2str(numfinebins),' subdivisions'])