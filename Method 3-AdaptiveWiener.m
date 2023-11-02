
%[aud1,sampleRate]=audioread('clean_speech.wav');

%noise_aud1=awgn(aud1,10);
%noise_var=0.005;
%noise_aud1=aud1+wgn(length(aud1),1,noise_var,'linear');

%padding_need=frame_size-mod(length(noise_aud1),frame_size);
%noise_aud1=padarray(noise_aud1,[padding_need,0],0,'post');
%aud1=padarray(aud1,[padding_need,0],0,'post');

[original,sampleRate]=audioread('clean_speech.wav');
stoi_noise=zeros(1,1);
stoi_clean=zeros(1,1);
snr_seg_noise=zeros(1,1);
snr_seg_clean=zeros(1,1);
snr_noise=zeros(1,1);
snr_clean=zeros(1,1);
noisy_signals=zeros(577655,1);
clean_signals=zeros(577655,1);


noise_levels=[-10,-5,0,5,10,15,20];


for nl=1:7

aud1=original;
noise_aud1=awgn(aud1,noise_levels(nl),'measured');



noise=noise_aud1(1:1024);


% Calculate the noise psd-
window=blackman(50);
n_psd_welch=pwelch(noise,window);
%discuss about the estimation of the noise psd in the report.
%plot(n_psd_welch);
%problem is that it is not even close to the actual noise variance when we
%estimate it from the first 1024 samples
%same notation as the paper
var_v=mean(n_psd_welch);
%var_v= noise_var;
%noise variance
M=150;
clean_signal=zeros(1,1);
for i=1024:length(noise_aud1)-M
   m_s= sum(noise_aud1(i-M:i+M))/(2*M+1);
   m_x=m_s;
   var_x=   sum((noise_aud1(i-M:i+M)-m_x).^2)/(1+2*M);

   if(var_x>var_v)
       var_s=var_x-var_v;
   else
       var_s=0;
   end

   cleaned=m_s + (var_s/(var_s+var_v)).*(noise_aud1(i)-m_s);
   clean_signal=vertcat(clean_signal,cleaned);



end
clean_signalf=clean_signal(2:end);

full_signal=vertcat(noise_aud1(1:1023),clean_signalf,noise_aud1(length(noise_aud1)-M+1:end));


stoi_noise_current= stoi(aud1,noise_aud1,16000);
stoi_clean_current = stoi(aud1,full_signal,16000);

[snr_seg_noise_current,snr_noise_current]=v_snrseg(noise_aud1,aud1,16000);
[snr_seg_clean_current,snr_clean_current]= v_snrseg(full_signal,aud1,16000);

stoi_noise=horzcat(stoi_noise,stoi_noise_current);
stoi_clean=horzcat(stoi_clean,stoi_clean_current);

snr_seg_noise=horzcat(snr_seg_noise,snr_seg_noise_current);
snr_seg_clean=horzcat(snr_seg_clean,snr_seg_clean_current);

snr_noise=horzcat(snr_noise,snr_noise_current);
snr_clean=horzcat(snr_clean,snr_clean_current);

noisy_signals=horzcat(noisy_signals,noise_aud1);
clean_signals=horzcat(clean_signals,full_signal);


end


















%use full signal to test snr and segmental snr and stoi
out= audioplayer(n,16000);
play(out);
%out= audioplayer(noise_aud1,16000);
%play(out);


%stoi_noisy=stoi(aud1,noise_aud1,16000);
%stoi_clean=stoi(aud1,full_signal,16000);


%subplot(2,1,1)
%stem(abs(fft(noise_aud1)))
%title('noisy signal fft')
%subplot(2,1,2)
%stem(abs(fft(clean_signalf)))
% title('filtered fft')
% 
% 
% 
% subplot(3,1,1)
% stem(noise_aud1)
% title('noisy signal')
% subplot(3,1,2)
% stem(clean_signalf)
% title('filtered signal')
%subplot(3,1,3)
%stem(aud1)
%title('original signal')
