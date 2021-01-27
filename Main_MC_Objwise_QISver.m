clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=16; %number of bitplane image
max_photon_number=1;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=1; %0.4               %paramater for contralling incident photon
Output_MLE_K=3;
scale=4;
SIZE=[256 256]*scale;
n=output_subframe_number/2;
M=4;
K_birateral=1000;
%% parameter MD Prop.
Down_Sample_Rate_MD=3;
Th_MD=8.00;
Th_Min_Label=100; %動き推定が成功する観点から
Opening_time=50;
%% parameter MD Prop.
down_sample_rate=0;
Down_Sample_Rate_Grav=2;
Range_x=[-0 0 2]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird
Range_y=[-50 50 2]; %range_y=[-20 20 4]; dolfin car_bus bird
Range_rotate=[-40 40 2]; %なし
Range_scale=[0 0 10]; %なし


%% Read Images
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
%% Gen bitplane imgs
DC_rate=0; % DC_rate =>Dark Count Rate
% [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
% tmp=Function_Reconstruction_SUM(bitplanes);
% imshow(uint8(tmp))
%% load bit-plane for Compare
%load('../Images/Output/IEEE_Access_traffic_Z_chi16/Original_bitplanes');
%load('../Images/Output/IEEE_Access_sky_Z_chi16/Original_bitplanes');
%load('../Images/Output/IEEE_Access_limitation_Z_chi16/Original_bitplanes');
%load('../Images/Output/MSrep_traffic/Original_bitplanes');
load('../Images/Output/test/Original_bitplanes');
%load('../Images/Output/IEEE_sky_Z_chi16_central/Original_bitplanes');
%load('../Images/Output/IEEE_limitation_Z_chi16_central/Original_bitplanes');
%load('../Images/Output/PCSJ_ppt_Scene/Original_bitplanes');
%%
tmp_bitplane=bitplanes;
Estimation_x=zeros(size(bitplanes,1),size(bitplanes,2));
Estimation_y=zeros(size(bitplanes,1),size(bitplanes,2));
for loop=1:1
    %% Motion Detection
    Down_Sample_Rate_MD=3;
    [chi_2D]=Function_Module_Chi2MapCul_Mpixel(tmp_bitplane,Down_Sample_Rate_MD,M);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');
    MD_Map=double(chi_2D>Th_MD);
    [Denoised_MD_Map]=Function_MDMap_NR(MD_Map,Th_Min_Label,Opening_time);
    figure('Name','chi')
    imshow(uint8(Denoised_MD_Map*255))
    % ラベリング&重心計算
    [Labeled_MDmap,Centroid_Point,Num_of_Moving_Area]=Function_Culcurate_Centroid(Denoised_MD_Map);
    
   %% Motion Compensation
    for num=1:3
        num
        %% Select Active Area
        [non,Index]=max(Num_of_Moving_Area);
        Num_of_Moving_Area(Index)=0;
        SelectArea_Number=Index;
        Heat_map_tmp=double(Labeled_MDmap==SelectArea_Number);
        imshow(uint8(Heat_map_tmp*255));
        centroid_array_tmp = regionprops(uint8(Heat_map_tmp),'centroid');
        tmp=centroid_array_tmp(1).Centroid;
        O_obj=round([tmp(2) tmp(1)]);
        
       %% Motion Estimation Prop. 
        N_Pyramid=5;
        Range_x=[-0 0 1];
        Range_y=[-4 4 1];
        Range_theta=[-14 14 2];
        Range_scale=[0 0 1];
        Heat_map=Heat_map_tmp;
        N_sort=3;
        [non,Estimation_x_new,Estimation_y_new,Estimation_theta_new,Estimation_scale_new]=Function_Pyramidal_ME_rigid_top(tmp_bitplane,Range_x,Range_y,Range_theta,Range_scale,O_obj,Heat_map,n,M,N_Pyramid,N_sort);
        bitplane_shifted=Function_ShiftBitplane_Rigid_Selective_Refframe(bitplanes,Estimation_x_new(1),Estimation_y_new(1),Estimation_theta_new(1),Estimation_scale_new(1),O_obj,n);
        Re_img=Function_Reconstruction_MLE_Oversample(bitplane_shifted,alpha,q,5);
        imshow(uint8(Re_img))
%         [bitplane_MC,Estimation_x_new,Estimation_y_new]=Function_ME_MDMap_CentorTime(tmp_bitplane,Range_x,Range_y,Range_scale,Range_rotate,Centroid_Point,Labeled_MDmap,SelectArea_Number,down_sample_rate,n);
         Area=double(Labeled_MDmap==SelectArea_Number);
         Estimation_x=Area*Estimation_x_new(1)+(1-Area).*Estimation_x;
         Estimation_y=Area*Estimation_y_new(1)+(1-Area).*Estimation_y;
         Area3D=repmat(Area,1,1,output_subframe_number);
         tmp_bitplane=tmp_bitplane.*(1-Area3D)+bitplane_shifted.*Area3D;
    end
    figure('Name','MC_Result')
    Re_img=Function_Reconstruction_MLE_Oversample(tmp_bitplane,alpha,q,Output_MLE_K);
    
    Re_img = imbilatfilt(Re_img,K_birateral);
    Re_img=mat2gray(Re_img)*255;
    imshow(uint8(Re_img))
    %% 確認表示
    csvwrite(['../Images/Output/ObjWise/test/x_Motion_Objwise.csv'],int16(Estimation_x));
    csvwrite(['../Images/Output/ObjWise/test/y_Motion_Objwise.csv'],int16(Estimation_y));
    save(['../Images/Output/ObjWise/test/ObjWiseMC_',num2str(loop),'times_bitplaneStyle'],'tmp_bitplane')
    imwrite(uint8(Denoised_MD_Map*255),['../Images/Output/ObjWise/test/ObjWiseMC_MD_Map_',num2str(loop),'times.png'])
    imwrite(uint8(Re_img),['../Images/Output/ObjWise/test/ObjWiseMC_',num2str(loop),'times.png']) 
 end