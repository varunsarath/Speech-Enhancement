


seed = 1;
length_frame = 0.02;
length_subframe = 0.002;
fs=16000;

[original,sampleRate]=audioread('clean_speech.wav');
stoi_noise=zeros(1,1);
stoi_clean=zeros(1,1);
snr_seg_noise=zeros(1,1);
snr_seg_clean=zeros(1,1);
snr_noise=zeros(1,1);
snr_clean=zeros(1,1);
noisy_signals=zeros(577920,1);
clean_signals=zeros(577920,1);

noise_levels=[-10,-5,0,5,10,15,20];


for nl=1:7

aud1=original';


%Read audio
clean_speech = original';

%Paddle
clean_speech_padding = [clean_speech,zeros(1,265)];
N = length(clean_speech_padding);

%Find speech start point index
for i = 1:N
    if (clean_speech_padding(i) == 0)&&(clean_speech_padding(i+1)~=0)
        start_index = i+1;
        break
    end
end

%Add noise
%Generate noise
%White Guassian noise
noise_aud1=awgn(clean_speech_padding,noise_levels(nl),'measured');
contaminated_speech=noise_aud1;
L_frame = length_frame*fs;
L_subframe = length_subframe*fs;

K_frame = N/L_frame;
K_subframe = L_frame/L_subframe;

%Segment
frames = zeros(K_frame,L_frame);
subframes = zeros(K_subframe,L_subframe,K_frame);
spc_frames = zeros(K_frame,L_frame);

for i = 1:K_frame
    frames(i,:) = contaminated_speech((i-1)*L_frame+1:i*L_frame);
    tmp = abs(fft(frames(i,:)));
    spc_frames(i,:) = tmp;
    %spc_frames(i,:) = tmp(1:round(length(tmp)/2));
    for j = 1:K_subframe
        subframes(j,:,i) = frames(i,(j-1)*L_subframe+1:j*L_subframe);
    end
end

%Calculate zero-crossings
cnt_zeros = zeros(K_frame,K_subframe);

power_noise = zeros(K_frame,L_subframe);
power_contaminated_speech = zeros(K_frame,L_subframe);
for i = 1:K_frame
    for j = 1:K_subframe
        cnt_zeros(i,j) = zero_crossings(subframes(j,:,i))/L_subframe;
    end
    zero_noise = mean(mean(cnt_zeros(1:(start_index-1)/L_frame,:)));
    thr = zero_noise; %Average value of noise and contaminated speech.
    
    index_noise = find(cnt_zeros(i,:)>thr);
    index_contaminated_speech = find(cnt_zeros(i,:)<thr);

    len_noise = length(index_noise)*L_subframe;
    len_conta = length(index_contaminated_speech)*L_subframe;

    for j = 1:K_subframe
        spc = abs(fft(subframes(j,:,i)));
        %spc = spc(1:round(length(spc)/2));
        if cnt_zeros(i,j)>thr
            power_noise(i,:) = power_noise(i,:) + abs(spc).^2/len_noise;
        else
            power_contaminated_speech(i,:) = power_contaminated_speech(i,:) + abs(spc).^2/len_conta;
        end
    end
    
end

%Estimate the PSD of clean speech
power_clean_speech = power_contaminated_speech - power_noise;
power_clean_speech(power_clean_speech<0)=0;

winner = power_clean_speech./(power_noise + power_clean_speech);

spc_clean_speech_subframe = zeros(K_subframe,L_subframe,K_frame);
est_clean_speech = 0;
for i = 1:K_frame
    est_clean_speech_frames = conv(abs(ifft(winner(i))),frames(i,:));
    est_clean_speech = [est_clean_speech,est_clean_speech_frames];
end

% for i = 1:K_frame
%     for j = 1:K_subframe
%         spc_clean_speech_subframe(j,:,i) = winner(i).*subframes(j,:,i);
%         est_clean_speech = [est_clean_speech,ifft(spc_clean_speech_subframe(j,:,i))];
%     end
% end

est_clean_speech = real(est_clean_speech);
spc_est_clean_speech = fftshift(fft(est_clean_speech));
spc_clearn_speech_padding = fftshift(fft(clean_speech_padding));

aud1=clean_speech_padding';
noise_aud1=noise_aud1';
est_clean_speech=est_clean_speech';
est_clean_speech=est_clean_speech(2:end);

stoi_noise_current= stoi(aud1,noise_aud1,16000);
stoi_clean_current = stoi(aud1,est_clean_speech,16000);

[snr_seg_noise_current,snr_noise_current]=v_snrseg(noise_aud1,aud1,16000);
[snr_seg_clean_current,snr_clean_current]= v_snrseg(est_clean_speech,aud1,16000);

stoi_noise=horzcat(stoi_noise,stoi_noise_current);
stoi_clean=horzcat(stoi_clean,stoi_clean_current);

snr_seg_noise=horzcat(snr_seg_noise,snr_seg_noise_current);
snr_seg_clean=horzcat(snr_seg_clean,snr_seg_clean_current);

snr_noise=horzcat(snr_noise,snr_noise_current);
snr_clean=horzcat(snr_clean,snr_clean_current);

noisy_signals=horzcat(noisy_signals,noise_aud1);
clean_signals=horzcat(clean_signals,est_clean_speech);


end







