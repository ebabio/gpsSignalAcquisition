function [sN, l] = oversampleDigital(s0, fFactor)


%% Find oversampled signal
[m, n] = size(s0);
l = floor(fFactor*n);

T = 1/fFactor;
k = ceil(T*(1:l));

sN = zeros(m,l);
for i=1:l
   sN(:,i) = s0(:,k(i)); 
end

end