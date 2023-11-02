function [clean_signalf,clean_signal_fft,acc_H_test] = clean_speech(noisy_signal,frame_size,threshold)
%with multiplication of the filter in the frequency domain.
subframe_size=frame_size/10;

acc_H_test=zeros(frame_size,1);
num_frames= int32(length(noisy_signal)/frame_size);
i= [1:frame_size];
isf=[1:subframe_size];
clean_signal= zeros(1);
clean_signal_fft=zeros(1);
for n = 0:num_frames-1
    
    frame=noisy_signal(i+double(n*frame_size));

    subframe_energy=zeros(1,10);
    
    subframe_identity=zeros(1,10);
    for j = 1:10
      subframe=frame(isf+double(j*10));
      subframe_energy(j)= sum(abs(subframe).^2);
      if(subframe_energy(j)>threshold)
        subframe_identity(j)=1;
      end

    end

    n_noise=0;
    n_fft=zeros(frame_size,1);
    n_sn=0;
    sn_fft=zeros(frame_size,1);
    
    for j=1:10
        subframe=frame(isf+double(j*10));
        if(subframe_identity(j)==1)
            n_sn=n_sn+1;
            sn_fft=horzcat(sn_fft,abs(fft(subframe,frame_size)).^2);
        else
           
            n_noise=n_noise+1;
            n_fft=horzcat(n_fft,abs(fft(subframe,frame_size)).^2);

        end
          
     end
     
    if(n_noise~=0)

    avg_n_per=sum(n_fft,2)/(n_noise*subframe_size);

    else
    avg_n_per=zeros(frame_size,1);
    end
  
    if(n_sn~=0)

    avg_sn_per=sum(sn_fft,2)/(n_sn*subframe_size);
    else
     avg_sn_per=zeros(frame_size,1);
    end 
    n_power=sum(abs(avg_n_per).^2); % check for normalization by 2pi
    n_sn_power=sum(abs(avg_sn_per).^2) ;
    %designing the wiener filter using the two power spectral densities
    if (avg_sn_per==0)
        avg_sn_per=avg_n_per;
    end
   
    psd_speech= avg_sn_per-avg_n_per;
     
    for x = 1:length(psd_speech)
    if psd_speech(x) < 0
      psd_speech(x)=0;
    end
    end

    psd_noise=avg_n_per;
     
    H = psd_speech./(psd_speech+psd_noise);
    %problem arises when a subframe is entirely noise. Then the denominator
    %is zero and the division results in inf. 
    
    
    acc_H_test=horzcat(acc_H_test,H);
    frame_fft= fft(frame);
    clean_frame_fft= H.* frame_fft;
    clean_signal_fft=vertcat(clean_signal_fft,clean_frame_fft);
    clean_frame = ifft(clean_frame_fft);
    clean_signal=vertcat(clean_signal,clean_frame);
    
    %if(length(clean_frame)~=length(frame))
     % break;
    %end
  % is_complex= ~isreal(clean_frame);
   % if(any(is_complex))
    % break;
     %end

end

clean_signalf=clean_signal(2:end);

end

