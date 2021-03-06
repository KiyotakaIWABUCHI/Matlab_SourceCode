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
%% parameter MD Prop.
Down_Sample_Rate_MD=2;
Th_MD=30.58;
Th_Min_Label=3; %動き推定が成功する観点から
Opening_time=20;
n=128;
%% parameter MD Prop.
down_sample_rate=0;
Down_Sample_Rate_Grav=2;
Range_x=[-0 0 2]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird
Range_y=[-50 50 2]; %range_y=[-20 20 4]; dolfin car_bus bird
Range_rotate=[-40 40 2]; %なし
Range_scale=[0 0 10]; %なし

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
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_CarBusHeri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_traffic/traffic_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_animal/animal_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_animal/eagle_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_limitation/limitation_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_sky/sky_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
   
    %%
   % Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
end
%% Gen bitplane imgs
DC_rate=0; % DC_rate =>Dark Count Rate
% [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
% tmp=Function_Reconstruction_SUM(bitplanes);
% imshow(uint8(tmp))
%% load bit-plane for Compare
%load('../Images/Output/IEEE_Access_traffic_Z_chi16/Original_bitplanes');
%load('../Images/Output/IEEE_Access_sky_Z_chi16/Original_bitplanes');
%load('../Images/Output/IEEE_Access_limitation_Z_chi16/Original_bitplanes');
load('../Images/Output/test2/Original_bitplanes');
%load('../Images/Output/IEEE_sky_Z_chi16_central/Original_bitplanes');
%load('../Images/Output/IEEE_limitation_Z_chi16_central/Original_bitplanes');
%load('../Images/Output/PCSJ_ppt_Scene/Original_bitplanes');
%%
tmp_bitplane=bitplanes;
Estimation_x=zeros(size(bitplanes,1),size(bitplanes,2));
Estimation_y=zeros(size(bitplanes,1),size(bitplanes,2));
for loop=1:1
    %% Motion Detection
    [chi_2D]=Function_Module_Chi2MapCul(tmp_bitplane,Down_Sample_Rate_MD);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');
    MD_Map=double(chi_2D>Th_MD);
    [Denoised_MD_Map]=Function_MDMap_NR(MD_Map,Th_Min_Label,Opening_time);
    figure('Name','chi')
    imshow(uint8(Denoised_MD_Map*255))
    % ラベリング&重心計算
    [Labeled_MDmap,Centroid_Point,Num_of_Moving_Area]=Function_Culcurate_Centroid(Denoised_MD_Map);
    
   %% Motion Compensation
    for num=1:1
        %% Select Active Area
        [M,Index]=max(Num_of_Moving_Area);
        Num_of_Moving_Area(Index)=0;
        SelectArea_Number=Index;
        
       %% Motion Estimation Prop. 
        [bitplane_MC,Estimation_x_new,Estimation_y_new]=Function_ME_MDMap_CentorTime(tmp_bitplane,Range_x,Range_y,Range_scale,Range_rotate,Centroid_Point,Labeled_MDmap,SelectArea_Number,down_sample_rate,n);
        Area=double(Labeled_MDmap==SelectArea_Number);
        Estimation_x=Area.*Estimation_x_new+(1-Area).*Estimation_x;
        Estimation_y=Area.*Estimation_y_new+(1-Area).*Estimation_y;     
        tmp_bitplane=bitplane_MC;
    end
    figure('Name','MC_Result')
    [non,img_output]=Function_Reconstruction_SUM(tmp_bitplane);
    imshow(uint8(img_output))
    %% 確認表示
    csvwrite(['../Images/Output/ObjWise/test/x_Motion_Objwise.csv'],int16(Estimation_x));
    csvwrite(['../Images/Output/ObjWise/test/y_Motion_Objwise.csv'],int16(Estimation_y));
    save(['../Images/Output/ObjWise/test/ObjWiseMC_',num2str(loop),'times_bitplaneStyle'],'tmp_bitplane')
    imwrite(uint8(Denoised_MD_Map*255),['../Images/Output/ObjWise/test/ObjWiseMC_MD_Map_',num2str(loop),'times.png'])
    imwrite(uint8(img_output),['../Images/Output/ObjWise/test/ObjWiseMC_',num2str(loop),'times.png']) 
 end