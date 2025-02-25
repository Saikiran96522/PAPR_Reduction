%SAMIROVITCH PROGRAMMM ABOUT PTS AND SLM METHOD
clc; clear all; close all;
N = 128; % The number of carriers
OF = 4; % Oversampling factor
K = N*OF;
QPSK_Set = [1 -1 1i -1i]; % QPSK Constellation symbols
Phase_Set = [1 -1 1i -1i]; % Weighting factor
M = 4; % The number of branches in SLM method
V = 2; % The number of sub-blocks in PTS method
X1 = zeros(M,N); % Initialize the data matrix Index1 = zeros(M,N);
X2 = zeros(1,N);
Index2 = zeros(1,N);
hwait = waitbar(0,'Please wait...'); % Creates and displays a waitbar
for i=1:4 % Generate all possible combinations of weighting factor set in PTS method
    X(i,1:4^i) = [repmat(1,1,4^(i-1)),repmat(2,1,4^(i-1)),repmat(3,1,4^(i-1)),repmat(4,1,4^(i-1))];
    Y = X(i,1:4^i);
    X(i,1:256) = repmat(Y,1,256/length(Y));
    end
    X = X.';
    Choose = fliplr(X);
    Choose_Len = 256; % The total number of combinations or IFFT operations in PTS method
    Max_Symbols = 1e3; % The number of generated OFDM symbols
    for nSymbol=1: Max_Symbols *10
        Index = randint(1,N,length(QPSK_Set))+1;
        X = QPSK_Set(Index(1,:)); % The QPSK modulation
        X = [X(1:N/2) zeros(1,K-N) X(N/2+1:N)]; % oversampling process
        x = ifft(X,[],2); % Signals in time domain after IFFT operation
        Signal_Power = abs(x.^2);
        Peak_Power = max(Signal_Power,[],2);
        Mean_Power = mean(Signal_Power,2);
        PAPR_Orignal(nSymbol) = 10*log10(Peak_Power./Mean_Power);
    end;
    step = Max_Symbols /100; % Set the parameters of waitbar
    for nSymbol=1:Max_Symbols
        if Max_Symbols-nSymbol<=50
            waitbar(nSymbol/ Max_Symbols,hwait,'Almost done!');
            pause(0.05);
        else PerStr=fix(nSymbol/step);
            str=['Process on going>>>',num2str(PerStr),'%'];
            waitbar(nSymbol/ Max_Symbols,hwait,str);
            pause(0.05);
        end
        %SLM
% Define the specific phase angles in degrees
	specific_angles_degrees = [90, 135, 180, 225];

% Convert angles from degrees to radians
	specific_angles_radians = deg2rad(specific_angles_degrees);

% Create Phase_Set with specified phase angles
	Phase_Set = exp(1i * specific_angles_radians);

% Now, you can use Phase_Set to generate Index1 and Phase_Rot
	Index1(1,:) = ones(1, N); % Using the first QPSK symbol for all carriers
	Phase_Rot = Phase_Set(randi(length(Phase_Set), M-1, N)); % Randomly selecting phase angles from Phase_Set

% Now, you can generate X1 with QPSK modulation and phase rotations
	X1(1,:) = QPSK_Set(Index1(1,:)); % The QPSK modulation
	X1(2:M,:) = repmat(X1(1,:), M-1, 1) .* Phase_Rot;

        X11 = [X1(:,1:N/2) zeros(M,K-N) X1(:,N/2+1:N)]; % oversampling process
        x = ifft(X11,[],2); % Signals in time domain after IFFT operation
        Signal_Power = abs(x.^2);
        Peak_Power = max(Signal_Power,[],2);
        Mean_Power = mean(Signal_Power,2);
        PAPR_temp = 10*log10(Peak_Power./Mean_Power);
        PAPR_SLM(nSymbol) = min(PAPR_temp);
        %PTS
        A = zeros(V,N); % Initial phase set to '0',exp(j*0)
        Index2 = randint(1,N,length(QPSK_Set))+1;
        X2 = QPSK_Set(Index2(1,:));
        Index= randperm(N);
        for v=1:V % Divided signals in frequency domain X into V non-overlapping sub-blocks
            A(v,Index(v:V:N)) = X2(Index(v:V:N));
        end
        A1 = [A(:,1:N/2) zeros(V,K-N) A(:,N/2+1:N)];
        a = ifft(A1,[],2);
        min_value = 10; % Applying optimum algorithm
        for n=1:Choose_Len temp_phase = Phase_Set(Choose(n,:)).';
            temp_max = max(abs(sum(a.*repmat(temp_phase',2,512/4))));
            if temp_max<min_value min_value = temp_max;
                Best_n = n;
                end
        end
        aa = sum(a.*repmat(Phase_Set(Choose(Best_n,:)),2,512/4)); % Represent the accumulation process
        Signal_Power = abs(aa.^2);
        Peak_Power = max(Signal_Power,[],2);
        Mean_Power = mean(Signal_Power,2);
        PAPR_PTS(nSymbol) = 10*log10(Peak_Power./Mean_Power);
    end
    close(hwait);
    [cdf1, PAPR1] = ecdf(PAPR_Orignal);
    [cdf2, PAPR2] = ecdf(PAPR_SLM);
    [cdf3, PAPR3] = ecdf(PAPR_PTS);
    semilogy(PAPR1,1-cdf1,'r','linewidth',2)
    hold on;
    semilogy(PAPR2,1-cdf2,'b','linewidth',2)
    hold on;
    semilogy(PAPR3,1-cdf3,'r--','linewidth',2)
    legend(' Orignal',' SLM',' PTS');
    xlabel('PAPR0 [dB]');
    ylabel('CCDF (Pr[PAPR>PAPR0])');
    axis([5 12 10e-4 1])
    grid on

