function [stdscore,bestres] = calcrhijuscore(data,whichlanes,whichpeaks,referencelane,referenceres);
% warning off MATLAB:divideByZero
titrationlanes = whichlanes; 
%referencelane = 5; referenceres = 20;
goodbins = find(data(:,referencelane)>0);
stdscore = 0*data(:,referencelane);
for k=goodbins'
    normdata =  data(goodbins,:) * diag(1./data(k,:));
    %The following works, but is not Keiji's prescription.
    stdscore(k) = std( std(normdata(goodbins,whichlanes),1,2));
end

[sortlist,bestres] = sort(stdscore);
figure(2)
plot(whichpeaks(goodbins),stdscore(goodbins))
axis([min(whichpeaks) max(whichpeaks) 0 1])
figure(1)    
bestres=bestres(1:5)';
