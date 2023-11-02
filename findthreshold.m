function threshold = findthreshold(noisy_signal,frame_size)

subframe_size=frame_size/10;


i= [1:frame_size];
isf=[1:subframe_size];


initial_energy=zeros(1);
for n = 1:3
    
    frame=noisy_signal(i+double(n*frame_size));

    subframe_energy=zeros(1,10);
    
    
    for j = 1:10
      subframe=frame(isf+double(j*10));
      subframe_energy(j)= sum(abs(subframe).^2);

    end
     
    inital_energy= horzcat(initial_energy,subframe_energy);
   
end

    threshold=mean(inital_energy);

end

