function[bitplane,incident_photons]=Function_BitplaneGen(img_input,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate) 

%%%%% Normalize Input Images %%%%%%%%
img_DR = (max_photon_number)*(double(img_input))/double(255);
%img_normalized=double(img_DR)/double(max(max(max(img_DR))))*output_subframe_number;
img_normalized=double(img_DR)*output_subframe_number;
bitplane=zeros(size(img_input,1),size(img_input,2),output_subframe_number);
incident_photons=zeros(size(img_input,1),size(img_input,2),output_subframe_number);
%%%%% Creat Bitplane by Photon Counting Sim using Poisson Rondom Function %%%%%%%%
for t=1:output_subframe_number
    incident_photon_average=alpha*(img_normalized(:,:,t)/output_subframe_number);
    incident_photon=poissrnd(incident_photon_average);   
    incident_photons(:,:,t)=incident_photon;
    DC = double(rand(size(bitplane(:,:,t)))< DC_rate); %DC => dark count noise
    bitplane(:,:,t)=double((incident_photon+DC)>=q);   
end