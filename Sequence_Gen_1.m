% Define your input signals s1, s2, ..., s256
%s = randn(1, 256); % for example, generate random input signals

% Transmitting algorithm
m=4;
symbols=randint(1,256,[1 m-1])
s=qammod(symbols,m);
x(1) = s(1);
for i = 2:numel(s)
    x(i) = s(i) + 2 * x(i-1);
end

% Receiving algorithm
x_det = zeros(size(x));
x_det(1) = x(1);
for i = 2:numel(x)
    x_det(i) = x(i) - 2 * x(i-1); % Modified this line
end

% Display the results
disp('Transmitted sequence:');
disp(x);
disp('Received sequence:');
disp(x_det);

