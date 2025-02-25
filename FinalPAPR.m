% Define your input signals s1, s2, ..., s256
%s = randn(1, 256); % for example, generate random input signals

% Transmitting algorithm
pkg load communications;
for k=1:1024
m=16;
symbols=randi(m-1,1,512);
s=qammod(symbols,m);
x(1) = s(1);
for i = 2:numel(s)
    x(i) = s(i) + 2 * x(i-1);
end

 x2 = ifft(x,[],2); % Sinyal dalam domain waktu setelah proses IFFT
        Signal_Power = abs(x2.^2);
        Peak_Power = max(Signal_Power,[],2);
        Mean_Power = mean(Signal_Power,2);
        PAPR_temp = 10*log10(Peak_Power./Mean_Power);
        PAPR_SLM(k)= min(PAPR_temp);
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
[cdf2, PAPRSLM] = ecdf(PAPR_SLM);
semilogy(PAPRSLM, 1-cdf2)
