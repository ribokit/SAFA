function residue_locations = pickpoints(imagex,offset,residue_locations, square_width);plottitle_usual = [...        'left/middle/right buttons: place square/erase square/zoom in/out \newline',...        'i/j/k/l or w/a/s/d  Move last square up/left/down/right \newline',...        'E:erase and replace closest square   Q,Z:finished\newline'];plottitle=plottitle_usual;figure(1); subplot(1,1,1); hold off; image(imagex); hold ontitle(plottitle);[xsize,ysize,zsize]=size(imagex);axis([0 ysize 0 xsize]); zoomedin = 0;axis equal GRIDSIZE= 4;stop_pick = 0;count=1;if (nargin>2)    count = length(residue_locations)+1;    if(count > 1)        for k=1:count-1            xpick = residue_locations(1,k);            ypick = residue_locations(2,k);            h(k) = rectangle('Position',...                [xpick - square_width/2, ypick-square_width/2,...                    square_width,square_width]);            set(h(k),'edgecolor','b');                    end    endend  while (stop_pick<1)    title([plottitle '                                   next: ', num2str(count+offset)])        [xpick,ypick,button] = ginput(1);    switch button        case 1            xpick = xpick - mod(xpick,GRIDSIZE);            ypick = ypick - mod(xpick,GRIDSIZE);            residue_locations(:,count) = [xpick;ypick];            h(count) = rectangle('Position',...                [xpick - square_width/2, ypick-square_width/2,...                    square_width,square_width]);            set(h(count),'edgecolor','r');            count= count+1;            title([plottitle 'next: ', num2str(count+offset)])        case 2            if(count > 1)                count= count-1;                residue_locations = residue_locations(:,1:count-1);                set(h(count),'visible','off');            end        case 3            if (zoomedin ==0)                axis([xpick-ysize/5 xpick+ysize/5 ...                        ypick - xsize/5 ypick+xsize/5])                    axis equal                    zoomedin= 1;                else                    axis([0 ysize 0 xsize]); zoomedin = 0;                end               end                switch char(button)            case {'q','z','Q','Z'}                stop_pick=1;            case {'i','w','I','W'}                residue_locations(2,count-1) = residue_locations(2,count-1) - 1;            case {'k','s','K','S'}                residue_locations(2,count-1) = residue_locations(2,count-1) + 1;            case {'l','d','L','D'}                residue_locations(1,count-1) = residue_locations(1,count-1) + 1;            case {'j','a','J','A'}                residue_locations(1,count-1) = residue_locations(1,count-1) - 1;            case {'e','E'}                [dummy, erasesquare] = min( (residue_locations(1,:) - xpick).^2 + (residue_locations(2,:) - ypick).^2 );                if (erasesquare>0)                    set(h(erasesquare),'visible','off');                    title(['Replace Pick ', num2str(erasesquare+offset), ' Now'])                        [xpick,ypick,button] = ginput(1);                    xpick = xpick - mod(xpick,GRIDSIZE);                    ypick = ypick - mod(xpick,GRIDSIZE);                    residue_locations(:,erasesquare) = [xpick;ypick];                    h(erasesquare) = rectangle('Position',...                        [xpick - square_width/2, ypick-square_width/2,...                            square_width,square_width]);                    set(h(erasesquare),'edgecolor','r');                end        end        switch char(button)            case {'i','j','k','l','I','J','K','L','a','s','d','w','A','S','D','W'}                xpick = residue_locations(1,count-1);                ypick = residue_locations(2,count-1);                set(h(count-1),'Position',  [xpick - square_width/2, ypick-square_width/2,...                        square_width,square_width]);                        end            end        title('Done picking points');