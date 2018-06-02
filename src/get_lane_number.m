function laneNo=get_lane_number(profiles,pointertoaxes,numfinebins)
global renderSqrt;

numlanes = size(profiles,2);
axes(pointertoaxes);
% maxprof = max(max(max(profiles))/200);
% %maxprof = round(max(max(profiles))/80);
% grayscaleon = 1;
% %setcolormap(grayscaleon,maxprof);
hold off;
if(renderSqrt == 1)
    image(sqrt(abs(profiles)));
else
    image(abs(profiles));
end
hold on
set(gca,'xtick',(numfinebins+1)/2:numfinebins:numlanes,'xticklabel',1:numlanes/numfinebins,'xminortick','on');
title('Click on lane to use as reference ladder');

[x,y]=ginput(1);

laneNo=ceil(x/numfinebins);
