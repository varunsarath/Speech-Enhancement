%This function calls clean_speech.m, in which the actual code for method 1
%is written. 
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

aud1=original;
noise_aud1=awgn(aud1,noise_levels(nl),'measured');


frame_size=  20*10^-3*16000;
padding_need=frame_size-mod(length(noise_aud1),frame_size);
noise_aud1=padarray(noise_aud1,[padding_need,0],0,'post');
aud1=padarray(aud1,[padding_need,0],0,'post');

threshold=findthreshold(noise_aud1,frame_size);
[clean_signalf,clean_signal_fft,acc_H_test]= clean_speech(noise_aud1,frame_size,threshold);


stoi_noise_current= stoi(aud1,noise_aud1,16000);
stoi_clean_current = stoi(aud1,clean_signalf,16000);

[snr_seg_noise_current,snr_noise_current]=v_snrseg(noise_aud1,aud1,16000);
[snr_seg_clean_current,snr_clean_current]= v_snrseg(clean_signalf,aud1,16000);

stoi_noise=horzcat(stoi_noise,stoi_noise_current);
stoi_clean=horzcat(stoi_clean,stoi_clean_current);

snr_seg_noise=horzcat(snr_seg_noise,snr_seg_noise_current);
snr_seg_clean=horzcat(snr_seg_clean,snr_seg_clean_current);

snr_noise=horzcat(snr_noise,snr_noise_current);
snr_clean=horzcat(snr_clean,snr_clean_current);

noisy_signals=horzcat(noisy_signals,noise_aud1);
clean_signals=horzcat(clean_signals,clean_signalf);


end
