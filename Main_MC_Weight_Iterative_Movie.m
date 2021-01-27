clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=256*3; %number of bitplane image
max_photon_number=1;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=2.0; %0.4               %paramater for contralling incident photon
block_size_MLE=10;
SIZE=[512 512];

%% parameter ME Prop.
down_sample_rate=0;
Down_Sample_Rate_Grav=2;
Range_x=[-50*2 50*2 4]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird /traffic[-52 52 4]
Range_y=[0 0 4]; %range_y=[-20 20 4]; dolfin car_bus bird eagle -50 50 /traffic[-20 20 4] airplane_bridge -50*2 50*2 4
Range_rotate=[-0 0 2]; %なし eagle -20 20
Range_scale=[0 0 10]; %なし

%% Iterative Loop Num
T_LOOP=5;  %注意 Resolution測定時，1
n=128;
%% Map Update
Down_Sample_Rate_MapUpdate=1;
%K_sigmoid_centor=7.82;
K_sigmoid_centor=30.58;
STEP_sigmoid=0.25; %注意 Resolution測定時，Map指定のためコメントアウト
K_DIV=0.5; %注意0.5はほぼ閾値判定
%% Read Images
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
disp('image_reading_now...')
for t_tmp=1:output_subframe_number
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_long_movie/airplane_bridge_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_IE_ppt/IE_ppt_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
end
imwrite(uint8(Imgs(:,:,1)),['../Images/Output/test_movie/FirstFrameGroudTruth.png'])
imwrite(uint8(Imgs(:,:,315)),['../Images/Output/test_movie/nth_FrameGroudTruth.png'])
imwrite(uint8(Imgs(:,:,end)),['../Images/Output/test_movie/LastFrameGroudTruth.png'])
disp('bitplane_generating_now...')
DC_rate=0; % DC_rate =>Dark Count Rate
[bitplanes_all]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
% for t=1:256*2
%     tmp=Function_Reconstruction_SUM(bitplanes(:,:,t:t+256-1));
%     imshow(uint8(tmp))
% end
save(['../Images/Output/test_movie/Original_bitplanes'],'bitplanes_all')
disp('iterativecycle_now...')
%%%%%%%%% Iterative MC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for set=1:3
    bitplanes=bitplanes_all(:,:,(set-1)*256+1:(set)*256);
    Heat_map=ones(SIZE); % Heatmap Initialize
    ME_Result=zeros(SIZE(1),SIZE(2),2);
    for i=0:T_LOOP-1
        %% 出力
        %     imwrite(uint8(Heat_map*255),['../Images/Output/test_movie/IterativeHeatMap_',num2str(i+1),'times.png'])
        %     save(['../Images/Output/test_movie/HeatMap_',num2str(i+1),'times_bitplaneStyle'],'Heat_map')
        %% 高速化時・並進のみ
        [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,down_sample_rate,n);
        %% 並進＋回転・拡大あり
%         O_obj=Function_ObjGrav_Cul(bitplanes,Down_Sample_Rate_Grav);
%         [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap_ROTATE_CentorTime(bitplanes,Range_x,Range_y,Range_scale,Range_rotate,O_obj,Heat_map,down_sample_rate,n);
        %% ROI Map Update
        [chi_2D]=Function_Module_Chi2MapCul(bitplane_MC,Down_Sample_Rate_MapUpdate);
        chi_2D=imresize(chi_2D,SIZE,'bicubic');
        %%%%%%%%%%%%%%% 逆シグモイド %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %sigmoid=(ones(size(chi_2D))./(1+exp(-(chi_2D-K_sigmoid_centor)/K_DIV)));
        Heat_map=Heat_map-STEP_sigmoid*double((K_sigmoid_centor>chi_2D));
        Heat_map=double(Heat_map>=0).*Heat_map;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 出力
        ME_Result(:,:,1)=Estimation_x;
        ME_Result(:,:,2)=Estimation_y;
        save(['../Images/Output/test_movie/set',num2str(set),'/IterativeOutput_',num2str(i+1),'times_bitplaneStyle'],'bitplane_MC')
        save(['../Images/Output/test_movie/set',num2str(set),'/Iterative_ME_Result_',num2str(i+1),'times'],'ME_Result')
        imwrite(uint8(Function_Reconstruction_SUM(bitplane_MC)),['../Images/Output/test_movie/set',num2str(set),'/IterativeOutput_',num2str(i+1),'times.png'])
    end
end