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
Range_x=[-40 40 4]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird
Range_y=[-20 20 4]; %range_y=[-20 20 4]; dolfin car_bus bird
Range_rotate=[0 0 2]; %なし
Range_scale=[0 0 10]; %なし

%% Iterative Loop Num
T_LOOP=10;  %注意 Resolution測定時，1

%% Map Update
Down_Sample_Rate_MapUpdate=1;
K_sigmoid_centor=10;
STEP_sigmoid=0.2; %注意 Resolution測定時，Map指定のためコメントアウト
K_DIV=1; %注意0.5はほぼ閾値判定

%% Read Images
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
for t_tmp=1:output_subframe_number
    %% Choise Images
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_car_bus_heri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_doubledoor/doubledoor_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_dolfin/bird_only_easy_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %%
    Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
end
%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Heat_map=ones(SIZE); % Heatmap Initialize
%%%%%%%%%bitplane生成%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DC_rate=0; % DC_rate =>Dark Count Rate
[bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
tmp=Function_Reconstruction_SUM(bitplanes);
imshow(uint8(tmp))
%%%%%%%%% Iterative MC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=0:T_LOOP-1
    %% 出力
    imwrite(uint8(Heat_map*255),['../Images/Output/test/IterativeHeatMap_',num2str(i+1),'times.png'])
    save(['../Images/Output/test/HeatMap_',num2str(i+1),'times_bitplaneStyle'],'Heat_map')  
    %% 高速化時・並進のみ
    %[tmp_bitplane,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,down_sample_rate);
    %% 並進＋回転・拡大あり
    O_obj=Function_ObjGrav_Cul(bitplanes,Down_Sample_Rate_Grav);
    [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap_ROTATE(bitplanes,Range_x,Range_y,Range_scale,Range_rotate,O_obj,Heat_map,down_sample_rate);
    %% ROI Map Update  
    [chi_2D]=Function_Module_Chi2MapCul(bitplane_MC,Down_Sample_Rate_MapUpdate);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');   
    %%%%%%%%%%%%%%% 逆シグモイド %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sigmoid=(ones(size(chi_2D))./(1+exp(-(chi_2D-K_sigmoid_centor)/K_DIV)));
    Heat_map=Heat_map-STEP_sigmoid*(1-sigmoid);
    Heat_map=double(Heat_map>=0).*Heat_map;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% 出力
    save(['../Images/Output/test/IterativeOutput_',num2str(i+1),'times_bitplaneStyle'],'bitplane_MC')
    imwrite(uint8(Function_Reconstruction_SUM(bitplane_MC)),['../Images/Output/test/IterativeOutput_',num2str(i+1),'times.png'])
end
%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%