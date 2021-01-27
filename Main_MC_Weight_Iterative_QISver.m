clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=16; %number of bitplane image
M=4; %chi-suqare cal param
max_photon_number=1;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=1.0; %0.4               %paramater for contralling incident photon
block_size_MLE=10;
scale=4;
SIZE=[256 256]*scale;
n=output_subframe_number/2;

%% parameter ME Prop.
down_sample_rate=0;
Down_Sample_Rate_Grav=2;
Range_rotate=[-0 0 2]; %なし eagle -20 20
Range_scale=[0 0 10]; %なし

%% Iterative Loop Num
T_LOOP=12;  %注意 Resolution測定時，1
%% Map Update
K_oversample=3;
%K_sigmoid_centor=7.82; 
%K_sigmoid_centor=18.47; %df7
K_sigmoid_centor=11.00; %df3
STEP_sigmoid=0.25; %注意 Resolution測定時，Map指定のためコメントアウト
K_DIV=0.5; %注意0.5はほぼ閾値判定
%% Read Images
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
ME_Result=zeros(SIZE(1),SIZE(2),4);
for t_tmp=1:output_subframe_number
    %% Choise Images
    t_tmp_skip=round(t_tmp*16*3/4);
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_traffic/traffic_frame',pad(num2str(t_tmp_skip-1),4,'left','0'),'.png']));
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_sky/sky_frame',pad(num2str(t_tmp_skip-1),4,'left','0'),'.png']));
      %%
    Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
    
end
imwrite(uint8(mat2gray(Imgs(:,:,1))*255),['../Images/Output/test/FirstFrameGroudTruth.png'])
imwrite(uint8(mat2gray(Imgs(:,:,n))*255),['../Images/Output/test/nth_FrameGroudTruth.png'])
imwrite(uint8(mat2gray(Imgs(:,:,end))*255),['../Images/Output/test/LastFrameGroudTruth.png'])

%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Heat_map=ones(SIZE); % Heatmap Initialize
%%%%%%%%%bitplane生成%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DC_rate=0; % DC_rate =>Dark Count Rate
[bitplanes,Incident_photons]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
% for t=1:256
%     imwrite(uint8(bitplanes(:,:,t)*255),['../Images/Output/bitplanes/PCSJ_Scene/Frame',num2str(t),'.png'])
% end
tmp=Function_Reconstruction_MLE_Oversample(bitplanes,alpha,q,K_oversample);
imshow(uint8(tmp))
save(['../Images/Output/test/Original_bitplanes'],'bitplanes')
save(['../Images/Output/test/Incident_photons'],'Incident_photons')
[non,Avg]=Function_Reconstruction_SUM(bitplanes);
%imwrite(uint8(Avg),['../Images/Output/test/Avg_bitplanes.png'])
%%%%%%%%% Iterative MC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=0:T_LOOP-1
    %% 出力
     imwrite(uint8(Heat_map*255),['../Images/Output/test/IterativeHeatMap_',num2str(i+1),'times.png'])
%     save(['../Images/Output/test/HeatMap_',num2str(i+1),'times_bitplaneStyle'],'Heat_map')  
    %% 高速化時・並進のみ
    N_Pyramid=5;
    Range_x=[-0 0 1];
    Range_y=[-4 4 1];
    Range_theta=[-20 20 2];
    %Range_theta=[-0 0 2];
    Range_scale=[0 0 1];
    N_sort=3;
%     Estimation_theta=0;
%     Estimation_scale=0;
    %[bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,down_sample_rate);
%     [non,Estimation_x,Estimation_y]=Function_Pyramidal_ME_top(bitplanes,Range_x,Range_y,Heat_map,n,M,N_Pyramid,N_sort);
%     bitplane_shifted=Function_ShiftBitplane_Selective_Refframe(bitplanes,Estimation_x(1),Estimation_y(1),n);
%     Re_img=Function_Reconstruction_MLE_Oversample(bitplane_shifted,alpha,q,5);
    %imshow(uint8(Re_img))
    
    %% 並進＋回転・拡大あり
    O_obj=Function_ObjGrav_Cul(bitplanes,N_Pyramid,M);
    [non,Estimation_x,Estimation_y,Estimation_theta,Estimation_scale]=Function_Pyramidal_ME_rigid_top(bitplanes,Range_x,Range_y,Range_theta,Range_scale,O_obj,Heat_map,n,M,N_Pyramid,N_sort);
    bitplane_shifted=Function_ShiftBitplane_Rigid_Selective_Refframe(bitplanes,Estimation_x(1),Estimation_y(1),Estimation_theta(1),Estimation_scale(1),O_obj,n);
    Re_img=Function_Reconstruction_MLE_Oversample(bitplane_shifted,alpha,q,5);
    imshow(uint8(Re_img))
%[bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap_ROTATE_CentorTime(bitplanes,Range_x,Range_y,Range_scale,Range_rotate,O_obj,Heat_map,down_sample_rate,n);
    %% ROI Map Update  
    Down_Sample_Rate_MapUpdate = 3; 
    [chi_2D]=Function_Module_Chi2MapCul_Mpixel(bitplane_shifted,Down_Sample_Rate_MapUpdate,M);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');   
    %imshow(uint8(double(chi_2D>=11)*255))
    %%%%%%%%%%%%%%% 逆シグモイド %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Heat_map=Heat_map-STEP_sigmoid*double((K_sigmoid_centor>chi_2D));
    Heat_map=double(Heat_map>=0).*Heat_map;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% 出力
    ME_Result(:,:,1)=Estimation_x(1);
    ME_Result(:,:,2)=Estimation_y(1);
    ME_Result(:,:,3)=Estimation_theta(1);
    ME_Result(:,:,4)=Estimation_scale(1);
    bitplane_MC=bitplane_shifted;
    save(['../Images/Output/test/IterativeOutput_',num2str(i+1),'times_bitplaneStyle'],'bitplane_MC')
    save(['../Images/Output/test/Iterative_ME_Result_',num2str(i+1),'times'],'ME_Result')
    imwrite(uint8(Re_img),['../Images/Output/test/IterativeOutput_',num2str(i+1),'times.png'])
end
%%%%%%%%%%%%% Main End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%