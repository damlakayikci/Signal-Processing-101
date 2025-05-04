%% CMPE362 HW3 - Noise Removal using Digital Filters

clear; close all; clc;

%% Step 1: Load audio and visualize spectrogram

[x, fs] = audioread('sample.wav');
t = (0:length(x)-1)/fs;

% Plot spectrogram to identify noisy frequency band
figure;
spectrogram(x, 1024, 768, 1024, fs, 'yaxis');
title('Original Signal Spectrogram');
exportgraphics(gcf, 'original_spect.png', 'Resolution', 300);

% Based on inspection, boundaries for noisy region
f1 = 3800; % lower bound of noise frequency 
f2 = 4900; % upper bound of noise frequency 
fprintf('Estimated noise band: [%d Hz, %d Hz]\n', f1, f2);

%% Step 2: FIR Bandstop Filter Design

orderFIR = 256;
Wn = [(f1 - 500), (f2 + 500)] / (fs/2); % Normalize
bFIR = fir1(orderFIR, Wn, 'stop');
yFIR = filter(bFIR, 1, x);

%% Step 3: IIR Filters - Final Selected Orders
nBut = 7;
nChb = 6;
nEll = 6;
Rp = 0.1;

[bBUT, aBUT] = butter(nBut, Wn, 'stop');
[bCHB, aCHB] = cheby1(nChb, Rp, Wn, 'stop');
[bELL, aELL] = ellip(nEll, Rp, 40, Wn, 'stop');

yBUT = filter(bBUT, aBUT, x);
yCHB = filter(bCHB, aCHB, x);
yELL = filter(bELL, aELL, x);

%% Step 4: Frequency Response Comparison

[Hfir, w] = freqz(bFIR, 1, 2048, fs);
[Hbut, ~] = freqz(bBUT, aBUT, 2048, fs);
[Hchb, ~] = freqz(bCHB, aCHB, 2048, fs);
[Hell, ~] = freqz(bELL, aELL, 2048, fs);

figure;
plot(w, log10(abs(Hfir)), 'k', 'LineWidth', 1.5); hold on;
plot(w, log10(abs(Hbut)), 'r');
plot(w, log10(abs(Hchb)), 'g');
plot(w, log10(abs(Hell)), 'b');
xlim([2000 8000]);
legend('FIR', ...
    ['Butterworth n=', num2str(nBut)], ...
    ['Chebyshev I n=', num2str(nChb)], ...
    ['Elliptic n=', num2str(nEll)]);
xlabel('Frequency (Hz)');
ylabel('log_{10}|H(f)|');
title('Frequency Response Comparison');
exportgraphics(gcf, 'freq_response_selected_orders.png', 'Resolution', 300);

%% Step 4b: Pole-Zero Plots

figure;
subplot(1,3,1); zplane(bBUT, aBUT); title(['Butterworth Z-plane (n=', num2str(nBut), ')']);
subplot(1,3,2); zplane(bCHB, aCHB); title(['Chebyshev I Z-plane (n=', num2str(nChb), ')']);
subplot(1,3,3); zplane(bELL, aELL); title(['Elliptic Z-plane (n=', num2str(nEll), ')']);
exportgraphics(gcf, 'pzplots.png', 'Resolution', 300);
%% Step 5: Apply and Save Filtered Signals

audiowrite('sample_FIR.wav', yFIR, fs);
audiowrite('sample_Butter.wav', yBUT, fs);
audiowrite('sample_Cheby.wav', yCHB, fs);
audiowrite('sample_Ellip.wav', yELL, fs);

% Plot spectrograms with dynamic titles
figure;
subplot(2,2,1); spectrogram(yFIR, 1024, 768, 1024, fs, 'yaxis');
title(['FIR Filtered (Order = ', num2str(orderFIR), ')']);

subplot(2,2,2); spectrogram(yBUT, 1024, 768, 1024, fs, 'yaxis');
title(['Butterworth Filtered (n = ', num2str(nBut), ')']);

subplot(2,2,3); spectrogram(yCHB, 1024, 768, 1024, fs, 'yaxis');
title(['Chebyshev I Filtered (n = ', num2str(nChb), ')']);

subplot(2,2,4); spectrogram(yELL, 1024, 768, 1024, fs, 'yaxis');
title(['Elliptic Filtered (n = ', num2str(nEll), ')']);
exportgraphics(gcf, 'filtered_spectrograms.png', 'Resolution', 300);

%% Step 6: Instability Threshold Frequency Response Plot

% min n values where filters become unstable
nBut = 13;
nChb = 12;
nEll = 10;

[bdBUT, adBUT] = butter(13, Wn, 'stop');
[bdCHB, adCHB] = cheby1(12, Rp, Wn, 'stop');
[bdELL, adELL] = ellip(10, Rp, 40, Wn, 'stop');

[HdBut, ~] = freqz(bdBUT, adBUT, 2048, fs);
[HdChb, ~] = freqz(bdCHB, adCHB, 2048, fs);
[HdEll, ~] = freqz(bdELL, adELL, 2048, fs);

figure;
plot(w, log10(abs(Hfir)), 'k', 'LineWidth', 1.5); hold on;
plot(w, log10(abs(HdBut)), 'r');
plot(w, log10(abs(HdChb)), 'g');
plot(w, log10(abs(HdEll)), 'b');
xlim([2000 8000]);
legend('FIR', ...
    'Butterworth n=12', ...
    'Chebyshev I n=12', ...
    'Elliptic n=10');
xlabel('Frequency (Hz)');
ylabel('log_{10}|H(f)|');
title('Frequency Response at Instability Threshold');
exportgraphics(gcf, 'unstable_freq_response.png', 'Resolution', 300);



