function plot_sequence(sequence,offset,pointertoaxis)
axes(pointertoaxis);
num_letters=max(size(sequence));
blocksize=50;
numblocks=ceil(num_letters/blocksize);


set(gca,'XLim',[-0.1 1.1],'YLim',[-0.1 1.1]);
set(gca,'XTick',[],'YTick',[]);
set(gca,'Visible','off');
set(gcf,'color','white');
for k=1:num_letters;
    i = mod((k-1),blocksize);
    j = floor((k-1)/blocksize);
    h=text(i/blocksize,0.9-0.1*j,sequence(k));
    set(h,'fontweight','bold');
   if (i == 0) text(-3/blocksize, 0.9-0.1*j, num2str(1+offset+ blocksize*j));end;
end

