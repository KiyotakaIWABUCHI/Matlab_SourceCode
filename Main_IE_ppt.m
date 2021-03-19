clear
close all

clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=180; %number of bitplane image
max_photon_number=1;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=1; %0.4               %paramater for contralling incident photon
block_size_MLE=10;
SIZE=[256 256];
%% parameter ME Prop.
%% Max Kernel Size => for k=0:2:K
%% Read Images
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
for t_tmp=1:output_subframe_number
    %% Choise Images
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_car_bus_heri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_limitation/limitation_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_scene_ppt/scene_ppt_frame',pad(num2str(128),4,'left','0'),'.png']));
     %%
    Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
end
%% Gen bitplane imgs
DC_rate=0; % DC_rate =>Dark Count Rate
[bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
tmp=Function_Reconstruction_SUM(bitplanes);
imshow(uint8(tmp))
imwrite(uint8(tmp),['../Images/Output/MS_report/noisy_ppt.png'])
imwrite(uint8(imresize(tmp(50:80,200:230),3,'nearest')),['../Images/Output/MS_report/noisy_ppt_zoom.png'])