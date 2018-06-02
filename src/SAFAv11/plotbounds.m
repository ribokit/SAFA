function plotbounds(imagey,ysel,xsel_bound,xsel_center, xguide1_ref,yguide1_ref,xguide2_ref,yguide2_ref);
%plotbounds(imagey,ysel,xsel_bound,xsel_center);
%
% Replots gel image, and defined lane boundaries, cleanly.
%
global renderSqrt;
if (nargin>0) 
    hold off; 
    if(renderSqrt == 1)
        image(sqrt(imagey));
    else
        image(imagey);
    end
end

if (nargin>2)
    count = size(xsel_bound,1);
    for k=1:count
        hold on; plot(xsel_bound(k,:),ysel,'g','linewidth',1); 
    end
end

if (nargin>3)
    count = size(xsel_center,1);    
    for k=1:count
        hold on; plot(xsel_center(k,:),ysel,'k','linewidth',1); 
    end
end

if (nargin>4)
    hold on; plot(xguide1_ref,yguide1_ref,'m')
    hold on; plot(xguide2_ref,yguide2_ref,'m')
end
