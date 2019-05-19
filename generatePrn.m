function s = generatePrn(prn)
%% Check input

if(nargin > 1)
    error('error 1: wrong number of inputs');
end

if(nargout > 1)
    error('error 4: maximum number of outputs excedeeded');
end

if(size(size(prn),2) ~= 2)
    error('error 3: input must be a matrix')
end

if(size(prn,2) ~= 1)
    error('error 2: input must be a column vector')
end

%% Setup and initialize LFSR

% LFSR order
n = 10;

% code length
l = 2^n-1;

% characteristic polynomials for Gold codes
% p1 = x^10 + x^3 + 1
p1 = [1 0 0 0 0 0 0 1 0 0 1];
% p2 = x^10 + x^9 + x^8 + x^6 + x^3 + x^2 + 1
p2 = [1 1 1 0 1 0 0 1 1 0 1];

% initial states
g1 = [ones(1,10) zeros(1,l)];
g2 = [ones(1,10) zeros(1,l)];

%% Run LFSR

for i=11:l+10
    % Compute generating function
    g1(i) = mod(g1(i-10:i-1) * p1(1:10).', 2);
    g2(i) = mod(g2(i-10:i-1) * p2(1:10).', 2);
    
end

%% Generate gold codes
m = numel(prn);

s = zeros(m,l);
for i=1:m
    % Select prn
    gold = selectGold(prn(i));
    
    % Compute prn from generating functions
    for j=1:l
        if(gold ==0) % debug
            k = j+n;
            s(i,j) = g1(k-10);
        else
            k = j+n;
            s(i,j) = mod(g1(k-10) + g2(k-gold(1)) + g2(k-gold(2)) ,2);
        end
    end
end

end