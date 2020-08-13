clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=10;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=2; %0.4               %paramater for contralling incident photon
block_size_MLE=10;
SIZE=[256 256];
%% parameter ME Prop.
down_sample_rate=1;
Down_Sample_Rate_Grav=2;
Range_x=[-0 0 2]; %[start end] ‚Ý range_x=[-40 40 4]; dolfine car_bus bird
Range_y=[-40 40 4]; %range_y=[-20 20 4]; dolfin car_bus bird
Range_rotate=[-20 20 2]; %‚È‚µ
Range_scale=[0 0 10]; %‚È‚µ
%% Max Kernel Size => for k=0:2:K
K = 5;

%% Read Images
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
ME_Result=zeros(SIZE(1),SIZE(2),2);
for t_tmp=1:output_subframe_number
    %% Choise Images
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_car_bus_heri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_doubledoor/doubledoor_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_dolfin/bird_only_easy_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_pen/pen_only_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_pen',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_pen_mouse',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_hasami/hasami_frame',pad(num2str(output_subframe_number-t_tmp),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_toyplane_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/book_toyplane_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_car_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_doubledoor/doubledoor_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_CarBusHeri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_traffic/traffic_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_animal/animal_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));

     %%
    Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
end
%% Gen bitplane imgs
DC_rate=0; % DC_rate =>Dark Count Rate
%[bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
%tmp=Function_Reconstruction_SUM(bitplanes);
%imshow(uint8(tmp))
%% load bit-plane for Compare
load('../Images/Output/IEEE_traffic/Original_bitplanes');

%% Motion Estimation Pixel Wise Search
for k=0:1:K
    Kernel_Space=2*k+1;
    [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_PixelWise(bitplanes,Range_x,Range_y,Kernel_Space);
    [non,img_output]=Function_Reconstruction_SUM(bitplane_MC);
    save(['../Images/Output/PixelWise/test/PixWiseMC_KernelSize',num2str(Kernel_Space),'_bitplaneStyle'],'bitplane_MC')
    imwrite(uint8(img_output),['../Images/Output/PixelWise/test/PixWiseMC_KernelSize',num2str(Kernel_Space),'.png'])
end


