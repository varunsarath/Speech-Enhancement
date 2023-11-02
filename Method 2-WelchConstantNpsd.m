%an alternate approach- 
%first detect the noise PSD using the welch from the first 1000 frames where we know that
%there is no speech.
%let that psd be constant and then split the signal into frames.
%now, for each frame, consider the entire signal as S+N and compute its
%PSD from the entire frame. Try and use the welch method.
%Filter each frame with the wiener filter but the only difference now
%is that the noise statistics are not updated.


%advantage is that we now do not have the thresholding problem.
%disadvantage is that it obviously wont work with changing noise 
%statistics.

%changelog from previous method is a constant noise PSD estimate, and also
%welch instead of manual bartlett.

%next step is to try and use STOI by making the signal lengths equal.
%also check why the welch returns 129 lengths and then you have to take the
%first 128. Might be causing some effects.
[original,sampleRate]=audioread('clean_speech.wav');
stoi_noise=zeros(1,1);
stoi_clean=zeros(1,1);
snr_seg_noise=zeros(1,1);
snr_seg_clean=zeros(1,1);
snr_noise=zeros(1,1);
snr_clean=zeros(1,1);
noisy_signals=zeros(577664,1);
clean_signals=zeros(577664,1);

noise_levels=[-10,-5,0,5,10,15,20];


for nl=1:7

aud1=original;
noise_aud1=awgn(aud1,noise_levels(nl),'measured');

frame_size=128;
padding_need=frame_size-mod(length(noise_aud1),frame_size);
noise_aud1=padarray(noise_aud1,[padding_need,0],0,'post');
aud1=padarray(aud1,[padding_need,0],0,'post');

length(noise_aud1)
noise=noise_aud1(1:1024);


% Calculate the noise psd-
          
n_psd_welch=pwelch(noise);

avg_n_per=n_psd_welch(2:end);


subframe_size=frame_size/10;

acc_H_test=zeros(frame_size,1);
num_frames= int32(length(noise_aud1)/frame_size)-1;
i= [1:frame_size];
clean_signal= zeros(1);
clean_signal_fft=zeros(1);
test=zeros(128,1);
for n = 0:num_frames
    
    frame=noise_aud1(i+double(n*frame_size));

  try
    
    sn_psd_welch=pwelch(frame);
    avg_sn_per=sn_psd_welch(2:end);
  
  catch exception
      disp(exception)
      disp(n)
      disp(frame)

      break
  end
   
    psd_speech= avg_sn_per-avg_n_per;
    %check negative points and make it 0.
    for x = 1:length(psd_speech)
    if psd_speech(x) < 0
      psd_speech(x)=0;
    end
    end

    psd_noise=avg_n_per;
     
    H = psd_speech./(psd_speech+psd_noise);
    
    
    acc_H_test=horzcat(acc_H_test,H);
    frame_fft= fft(frame);
    clean_frame_fft= H.* frame_fft;
    clean_signal_fft=vertcat(clean_signal_fft,clean_frame_fft);
    clean_frame = real(ifft(clean_frame_fft));
    test=horzcat(test,clean_frame);
    clean_signal=vertcat(clean_signal,clean_frame);

end


clean_signalf2=clean_signal(2:end);

stoi_noise_current= stoi(aud1,noise_aud1,16000);
stoi_clean_current = stoi(aud1,clean_signalf2,16000);

[snr_seg_noise_current,snr_noise_current]=v_snrseg(noise_aud1,aud1,16000);
[snr_seg_clean_current,snr_clean_current]= v_snrseg(clean_signalf2,aud1,16000);

stoi_noise=horzcat(stoi_noise,stoi_noise_current);
stoi_clean=horzcat(stoi_clean,stoi_clean_current);

snr_seg_noise=horzcat(snr_seg_noise,snr_seg_noise_current);
snr_seg_clean=horzcat(snr_seg_clean,snr_seg_clean_current);

snr_noise=horzcat(snr_noise,snr_noise_current);
snr_clean=horzcat(snr_clean,snr_clean_current);

noisy_signals=horzcat(noisy_signals,noise_aud1);
clean_signals=horzcat(clean_signals,clean_signalf2);


end

%out= audioplayer(noise_aud1,16000);
%play(out);


%out= audioplayer(clean_signalf1,16000);
%play(out);
%audiowrite('with_negatives.wav',clean_signalf,16000);
%out= audioplayer(clean_signalf2,16000);
%audiowrite('without_negatives.wav',clean_signalf2,16000);
%play(out);

%print("")

