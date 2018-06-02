function [stdscore,bestres] = calckeijiscore(data,whichlanes,whichpeaks,referencelane,referenceres);
warning off MATLAB:divideByZero
titrationlanes = whichlanes; 
%referencelane = 5; referenceres = 20;
%goodbins = find(data(:,referencelane)>0);
goodbins=[1:size(data,1)]';
stdscore = 0*data(:,referencelane);

for k=goodbins'
    normdata =  data(goodbins,:) * diag(1./data(k,:));
    %The following works, but is not Keiji's prescription.
    %   stdscore(k) = std( std(normdata,1,2));

    %This is Keiji's prescription.
    for i=1:length(goodbins)
        V(i) = sqrt(sum( (normdata(i,whichlanes) - normdata(i,referencelane)).^2,2) / (length(whichlanes)-1));
    end
    V_norm = V/normdata(referenceres,referencelane);
    stdscore(k) = std(V_norm);
end

numres=length(stdscore);
if numres>15
    stdscore = stdscore(1 : numres-10);  
end

[sortlist,bestres] = sort(stdscore);
% figure(2)
% plot(whichpeaks(goodbins),stdscore(goodbins))
% axis([min(whichpeaks) max(whichpeaks) 0 1])
% figure(1)    
bestres=bestres(1:5)';
fprintf(1,'\n Invariant residues with ref. lane %d and ref. res %d : %d %d %d %d %d',referencelane,whichpeaks(referenceres),...
        whichpeaks(bestres));
%        bestres(1),bestres(2),bestres(3),bestres(4),bestres(5));
    
    
