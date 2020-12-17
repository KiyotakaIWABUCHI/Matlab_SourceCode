clear
close all
%%
alpha=2;
q=1;
%Obj='IEEE_Access_traffic_Z_chi16'
Obj='IEEE_Access_sky_Z_chi16'
%Obj='IEEE_limitation';
%% Original Bit-plane
load(['../Images/Output/',Obj,'/Original_bitplanes']);
%% GT
GT=double(imread(['../Images/Output/',Obj,'/nth_FrameGroudTruth.png']));
%WP=[156 77];%traffic
%WP=[30 116];%limitation
WP=[171 133];%sky
%BP=[26 153];%traffic
%BP=[238 21];%limitation
BP=[4 190];%sky
%% Avg
%[non,Avg_row]=Function_Reconstruction_SUM(bitplanes);
Avg_row=Function_Reconstruction_MLE(bitplanes,alpha,q);
%Avg_row = wiener2(Avg_row,[2 2]);
[Avg]=Function_WhiteBalanced(Avg_row,GT,Avg_row,WP,BP);

%% Prop
Prop_row=double(imread(['../Images/Output/',Obj,'/ReconstractedImage_MinumumChiMap.png']));
%Prop_row = wiener2(Prop_row,[2 2]);
[Prop]=Function_WhiteBalanced(Prop_row,GT,Avg_row,WP,BP);
Prop_row_weight=double(imread(['../Images/Output/',Obj,'/ReconstractedImage_Futurework.png']));
%Prop_row_weight = wiener2(Prop_row_weight,[2 2]);
[Prop_Weight]=Function_WhiteBalanced(Prop_row_weight,GT,Avg_row,WP,BP);
%% ObjWise
%ObjWise_row=double(imread(['../Images/Output/ObjWise/',Obj,'/ObjWiseMC_1times.png']));
load(['../Images/Output/ObjWise/',Obj,'/ObjWiseMC_1times_bitplaneStyle']);
ObjWise_row=Function_Reconstruction_MLE(tmp_bitplane,alpha,q);
%ObjWise_row = wiener2(ObjWise_row,[2 2]);
[ObjWise]=Function_WhiteBalanced(ObjWise_row,GT,Avg_row,WP,BP);
%% PixelWise
% PixWiseK1_row=double(imread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize1.png']));
% PixWiseK3_row=double(imread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize3.png']));
load(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize1_bitplaneStyle']);
PixWiseK1_row=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
[PixWiseK1]=Function_WhiteBalanced(PixWiseK1_row,GT,Avg_row,WP,BP);
load(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize3_bitplaneStyle']);
PixWiseK3_row=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
%PixWiseK3_row = wiener2(PixWiseK3_row,[2 2]);
[PixWiseK3]=Function_WhiteBalanced(PixWiseK3_row,GT,Avg_row,WP,BP);
load(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize7_bitplaneStyle']);
PixWiseK7_row=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
%PixWiseK7_row = wiener2(PixWiseK7_row,[2 2]);
[PixWiseK7]=Function_WhiteBalanced(PixWiseK7_row,GT,Avg_row,WP,BP);

%% PSNR 全体
ROI=[1 1 256 256];
[PSNR_Avg,SSIM_Avg]=Function_ROI_PSNR(Avg,GT,ROI);
[PSNR_prop,SSIM_prop]=Function_ROI_PSNR(Prop,GT,ROI);
[PSNR_prop_Weight,SSIM_prop_Weight]=Function_ROI_PSNR(Prop_Weight,GT,ROI);
[PSNR_Objwise,SSIM_Objwise]=Function_ROI_PSNR(ObjWise,GT,ROI);
[PSNR_PixwiseK1,SSIM_PixwiseK1]=Function_ROI_PSNR(PixWiseK1,GT,ROI);
[PSNR_PixwiseK3,SSIM_PixwiseK3]=Function_ROI_PSNR(PixWiseK3,GT,ROI);
[PSNR_PixwiseK7,SSIM_PixwiseK7]=Function_ROI_PSNR(PixWiseK7,GT,ROI);

%% imshow
figure('Name','GT')
imshow(uint8(GT))
figure('Name','Avg')
imshow(uint8(Avg))
figure('Name','Prop')
imshow(uint8(Prop))
figure('Name','Prop_Weight')
imshow(uint8(Prop_Weight))
figure('Name','ObjWise')
imshow(uint8(ObjWise))
figure('Name','PixWiseK1')
imshow(uint8(PixWiseK1))
figure('Name','PixWiseK3')
imshow(uint8(PixWiseK3))
figure('Name','PixWiseK7')
imshow(uint8(PixWiseK7))

result_psnr(1,:)=[PSNR_Avg,PSNR_prop,PSNR_prop_Weight,PSNR_Objwise,PSNR_PixwiseK1,PSNR_PixwiseK3,PSNR_PixwiseK7];
result_psnr(2,:)=[SSIM_Avg,SSIM_prop,SSIM_prop_Weight,SSIM_Objwise,SSIM_PixwiseK1,SSIM_PixwiseK3,SSIM_PixwiseK7];
result_table=table(["Avg";"Prop";"Prop_Weight";"ObjWise";"PixWiseK1";"PixWiseK3";"PixWiseK7"],[PSNR_Avg;PSNR_prop;PSNR_prop_Weight;PSNR_Objwise;PSNR_PixwiseK1;PSNR_PixwiseK3;PSNR_PixwiseK7],[SSIM_Avg;SSIM_prop;SSIM_prop_Weight;SSIM_Objwise;SSIM_PixwiseK1;SSIM_PixwiseK3;SSIM_PixwiseK7]);
% 
Gain=1.1;
figure
%RoI=[149 194 93 234] %traffic_car
%RoI=[110 154 18 152] %traffic_bus
%RoI=[60 105 114 240] %traffic_sign
%RoI=[16 57 27 127] %traffic_heri
%RoI=[15 60 15 119] %traffic_bus
%RoI=[93 164 15 245] %sky_entire
%RoI=[93 144 15 150] %sky_left
RoI=[93 164 110 245] %sky_right
zoom_img=imresize(bitplanes(RoI(1):RoI(2),RoI(3):RoI(4),1)*255,3,'nearest');
imwrite(uint8(zoom_img),['../IEEE_result/tex/',Obj,'/zoom_img/Fist_bitplane3.png'])
zoom_img=imresize(GT(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
imshow(uint8(zoom_img))
imwrite(uint8(zoom_img),['../IEEE_result/tex/',Obj,'/zoom_img/FirstFrame_ZoomImg3.png'])
zoom_img=imresize(Avg(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
imshow(uint8(zoom_img))
imwrite(uint8(zoom_img),['../IEEE_result/tex/',Obj,'/zoom_img/Avg_ZoomImg3.png'])
zoom_img=imresize(Prop(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
imwrite(uint8(zoom_img),['../IEEE_result/tex/',Obj,'/zoom_img/Prop_ZoomImg3.png'])
zoom_img=imresize(Prop_Weight(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
imwrite(uint8(zoom_img),['../IEEE_result/tex/',Obj,'/zoom_img/Prop_Weight_ZoomImg3.png'])
zoom_img=imresize(ObjWise(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
imwrite(uint8(zoom_img),['../IEEE_result/tex/',Obj,'/zoom_img/ObjWise_ZoomImg3.png'])
zoom_img=imresize(PixWiseK3(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
imwrite(uint8(zoom_img),['../IEEE_result/tex/',Obj,'/zoom_img/PixWiseK3_ZoomImg3.png'])
zoom_img=imresize(PixWiseK7(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
imwrite(uint8(zoom_img),['../IEEE_result/tex/',Obj,'/zoom_img/PixWiseK7_ZoomImg3.png'])


%% ファイル出力
% Gain=1.1;
% imwrite(uint8(GT*Gain),['../IEEE_result/tex/',Obj,'/FirstFrame.png'])
% imwrite(uint8(Avg*Gain),['../IEEE_result/tex/',Obj,'/Avg_TotalFrame.png'])
% imwrite(uint8(Prop*Gain),['../IEEE_result/tex/',Obj,'/Proposed_Chi_Min.png'])
% imwrite(uint8(Prop_Weight*Gain),['../IEEE_result/tex/',Obj,'/Proposed_Weight.png'])
% imwrite(uint8(ObjWise*Gain),['../IEEE_result/tex/',Obj,'/ObjWise.png'])
% imwrite(uint8(PixWiseK1*Gain),['../IEEE_result/tex/',Obj,'/PixWise.png'])
% imwrite(uint8(PixWiseK3*Gain),['../IEEE_result/tex/',Obj,'/BlockWise_3x3.png'])
% imwrite(uint8(PixWiseK7*Gain),['../IEEE_result/tex/',Obj,'/BlockWise_9x9.png'])
% writetable(result_table,['../IEEE_result/tex/',Obj,'/Image_Quality.txt'])
%%
