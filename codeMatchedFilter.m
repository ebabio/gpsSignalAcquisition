%% Main detector script

%% Set up workspace

clear
close all
clc

display = 1;
performCMF = 0;
performCXcorr = 1;
%% Import data

load('data\complexdata.mat');

r = xcomplex;

nSampled = numel(r);
fs = 5e6; % Not exactly 5MHz..

%% Set parameters
prn = ([1 2 4 7 9 11 16 19 23 27 28 30])';
m = numel(prn);

samplesPerChip = (fs/1e3/1023);

replica = generatePrn(prn);
[replica, nReplica] = oversampleDigital(replica, fs/1.023e6);
replica = (-1).^replica;

delayResolution = 1/fs;
tI = delayResolution * nReplica;
t = delayResolution:delayResolution:nSampled*delayResolution;

samplesAveraged = 250;
fDopplerMax = fs / (2*samplesAveraged);
nDopplerBinsAv = floor(2*fDopplerMax * tI);
nDopplerBins = nDopplerBinsAv;

%fft reassigning terms
baseFreqIndex = floor(nDopplerBins/2)+1;
f = -fDopplerMax: 2*fDopplerMax/(nDopplerBins-1): fDopplerMax;

%% Test Autocorrelation
% %% Correlate constant signal
% replica = ones(size(replica));
% %% Correlate square signal
% replica = zeros(size(replica));
% replica(1:samplesPerChip*100) = ones(1,samplesPerChip*100);
% replica(end-samplesPerChip*100+1:end) = ones(1,samplesPerChip*100);
% %% Correlate agains replica
% replicaTimes = repmat(replica,1,12);
% r = zeros(size(r));
% for c=1:m
%     random = rand(1,2);
%     %     random = [1 .5];
%     rDelay = round(random(1)*1023*samplesPerChip)+1;
%     chipDelay(c) = 1-rDelay*delayResolution*1e3;
%     rDoppler(c) =  2*fDopplerMax*random(2) - fDopplerMax;
%     phase = rDoppler(c)* (2*pi*t + delayResolution*rDelay);
%     r = r + replicaTimes(c,rDelay : rDelay+nSampled-1).*exp(1i*phase);
% end
% r = r + 0*[1 1i] * randn(2,size(r,2));
% disp(['test Delays:' char(9) num2str(chipDelay)]);
% disp(['test Dopplers:' char(9) num2str(rDoppler)]);

%% Code Matched Filter
nCorr = nSampled - nReplica;
ddMapCMF = zeros(nDopplerBins,nCorr,m);

if(performCMF)
    for a = 1:m
        coherentCorr = zeros(1,nSampled);
        coherentCorrAv = zeros(1,nDopplerBins);
        disp(['Processing CMF for PRN' num2str(prn(a))]);
        for b = 1:nCorr
            coherentCorr = r(b:b+nReplica-1) .* conj((1+1i)*replica(a,:));
            % Perform averaging
            for c = 1:nDopplerBinsAv
                index = (c-1)*samplesAveraged + 1;
                coherentCorrAv(c) = sum(coherentCorr(index : index+samplesAveraged-1));
            end
            
            corrFreq = fft(coherentCorrAv, nDopplerBins);
            corrFreq = fftshift(corrFreq);
            ddMapCMF(:,b,a) = corrFreq.* conj(corrFreq);
        end
    end
    
    N0 = mean(mean(mean(ddMapCMF(:,:,1))));
    
    [ddMapCMFmax, j] = max(ddMapCMF,[],1);
    [ddMapCMFmax, i] = max(ddMapCMFmax,[],2);
    ddMapCMFmax = squeeze(ddMapCMFmax);
    i = squeeze(i);
    j = squeeze(j);
    delayMaxCMF = t(i);
    dopplerMaxCMF = f( (diag(j(i,:)))' ) ;
    
    SNRCMF = 10*log10(ddMapCMFmax/N0);
    
    for c=1:m
        disp(['SNR for PRN' num2str(prn(c)) ': ' num2str(SNRCMF(c))]);
        if(display)
            figure(10*c)
            surfc(t(1:nCorr), f, ddMapCMF(:,:,c));
            shading flat;
            view([15,60]);
            xlabel('delay [s]')
            ylabel('Doppler [Hz]')
            title(['CMF Delay Doppler Map for PRN' num2str(prn(c))])
            %         saveas(gcf, ['output\CMF' num2str(prn(c)) '.png']);
            pause(.1);
        end
    end
end
%% Circular correlation

if(performCXcorr)
    nCXcorr = floor(nSampled/nReplica);
    ddMapCXcorr = zeros(nDopplerBins,nCXcorr,m);
    for a = 1:m
        disp(['Processing CXcorr for PRN' num2str(prn(a))]);
        for b = 1:nCXcorr
            index = (b-1)*nReplica+1;
            rChunk = r(index:index+nReplica-1);
            rFFT = fft(rChunk);
            for c = 1:numel(f)
                replicaIf = replica(a,:) .* exp(1i*2*pi*f(c)*t(1:nReplica));
                replicaFFT = fft(replicaIf);
                fftXcorr = conj(replicaFFT).*rFFT;
                delayTests = ifft(fftXcorr);
                ddMapCXcorr(c,(index:index+nReplica-1),a) = delayTests .* conj(delayTests);
            end
        end
    end
    
    N0 = mean(mean(mean(ddMapCXcorr(:,:,1))));
    
    [ddMapCXmax, j] = max(ddMapCXcorr,[],1);
    [ddMapCXmax, i] = max(ddMapCXmax,[],2);
    ddMapCXmax = squeeze(ddMapCXmax);
    i = squeeze(i);
    j = squeeze(j);
    delayCXMax = t(i);
    dopplerCXMax = f( (diag(j(i,:)))' );
    
    SNRCX = 10*log10(ddMapCXmax/N0);
    
    for c=1:m
        disp(['SNR for PRN' num2str(prn(c)) ': ' num2str(SNRCX(c))]);
        if(display)
            figure(10*c+1)
            surfc(t(1:nCXcorr*nReplica),f,ddMapCXcorr(:,:,c));
            shading flat;
            view([15,60]);
            title(['CXcorr Delay Doppler Map for PRN' num2str(prn(c))])
            xlabel('delay [s]')
            ylabel('Doppler [Hz]')
            saveas(gcf, ['output\CX' num2str(prn(c)) '.png']);
            pause(0.1);
        end
    end
end