clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=1;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=2; %0.4               %paramater for contralling incident photon
block_size_MLE=10;
SIZE=[256 256];

%% parameter ME Prop.
down_sample_rate=0;
Down_Sample_Rate_Grav=2;
Range_x=[-0 0 4]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird
Range_y=[-50 50 4]; %range_y=[-20 20 4]; dolfin car_bus bird eagle -50 50
Range_rotate=[-40 40 2]; %なし eagle -20 20
Range_scale=[0 0 10]; %なし

%% Iterative Loop Num
T_LOOP=10;  %注意 Resolution測定時，1
n=128;
%% Map Update
Down_Sample_Rate_MapUpdate=1;
%K_sigmoid_centor=7.82;
K_sigmoid_centor=30.58;
STEP_sigmoid=0.25; %注意 Resolution測定時，Map指定のためコメントアウト
K_DIV=0.5; %注意0.5はほぼ閾値判定
%% Read Images
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
ME_Result=zeros(SIZE(1),SIZE(2),2);
for t_tmp=1:output_subframe_number
    %% Choise Images
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_car_bus_heri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
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
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_wolf/wolf_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_CarBusHeri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_traffic/traffic_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_animal/animal_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_animal/eagle_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_limitation/limitation_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_sky/sky_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_IEEE_Access_rotate/sky_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));

    %%
    Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
    
end
imwrite(uint8(Imgs(:,:,1)),['../Images/Output/test2/FirstFrameGroudTruth.png'])
imwrite(uint8(Imgs(:,:,n)),['../Images/Output/test2/nth_FrameGroudTruth.png'])
imwrite(uint8(Imgs(:,:,end)),['../Images/Output/test2/LastFrameGroudTruth.png'])
%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Heat_map=ones(SIZE); % Heatmap Initialize
%%%%%%%%%bitplane生成%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DC_rate=0; % DC_rate =>Dark Count Rate
[bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
tmp=Function_Reconstruction_SUM(bitplanes);
imshow(uint8(tmp))
save(['../Images/Output/test2/Original_bitplanes'],'bitplanes')
[non,Avg]=Function_Reconstruction_SUM(bitplanes);
imwrite(uint8(Avg),['../Images/Output/test2/Avg_bitplanes.png'])
%%%%%%%%% Iterative MC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=0:T_LOOP-1
    %% 出力
    imwrite(uint8(Heat_map*255),['../Images/Output/test2/IterativeHeatMap_',num2str(i+1),'times.png'])
    save(['../Images/Output/test2/HeatMap_',num2str(i+1),'times_bitplaneStyle'],'Heat_map')  
    %% 高速化時・並進のみ
    %[tmp_bitplane,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,down_sample_rate);
    %% 並進＋回転・拡大あり
    O_obj=Function_ObjGrav_Cul(bitplanes,Down_Sample_Rate_Grav);
    %[bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap_ROTATE(bitplanes,Range_x,Range_y,Range_scale,Range_rotate,O_obj,Heat_map,down_sample_rate);
    [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap_ROTATE_CentorTime(bitplanes,Range_x,Range_y,Range_scale,Range_rotate,O_obj,Heat_map,down_sample_rate,n);
    %% ROI Map Update  
    [chi_2D]=Function_Module_Chi2MapCul(bitplane_MC,Down_Sample_Rate_MapUpdate);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');   
    %imshow(uint8(double(chi_2D>=11)*255))
    %%%%%%%%%%%%%%% 逆シグモイド %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sigmoid=(ones(size(chi_2D))./(1+exp(-(chi_2D-K_sigmoid_centor)/K_DIV)));
    Heat_map=Heat_map-STEP_sigmoid*(1-sigmoid);
    Heat_map=double(Heat_map>=0).*Heat_map;
%     %
%   MM=(double(chi_2D<K_sigmoid_centor)*0.5+double(chi_2D>=K_sigmoid_centor));
%   Heat_map=Heat_map.*MM;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% 出力
    ME_Result(:,:,1)=Estimation_x;
    ME_Result(:,:,2)=Estimation_y;
    save(['../Images/Output/test2/IterativeOutput_',num2str(i+1),'times_bitplaneStyle'],'bitplane_MC')
    save(['../Images/Output/test2/Iterative_ME_Result_',num2str(i+1),'times'],'ME_Result')
    imwrite(uint8(Function_Reconstruction_SUM(bitplane_MC)),['../Images/Output/test2/IterativeOutput_',num2str(i+1),'times.png'])
end
%%%%%%%%%%%%% Main End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%