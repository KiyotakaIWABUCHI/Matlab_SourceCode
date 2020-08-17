clear
close all
%%
alpha=2;
q=1;


Obj='IEEE_traffic'

%% Original Bit-plane
load(['../Images/Output/',Obj,'/Original_bitplanes']);
%% GT
GT=double(imread(['../Images/Output/',Obj,'/FirstFrameGroudTruth.png']));
WP=[156 90];
BP=[27 151];
%% Avg
%[non,Avg_row]=Function_Reconstruction_SUM(bitplanes);
Avg_row=Function_Reconstruction_MLE(bitplanes,alpha,q);
[Avg]=Function_WhiteBalanced(Avg_row,GT,Avg_row,WP,BP);
%% Prop
Prop_row=double(imread(['../Images/Output/',Obj,'/ReconstractedImage_MinumumChiMap.png']));
[Prop]=Function_WhiteBalanced(Prop_row,GT,Avg_row,WP,BP);
%% ObjWise
%ObjWise_row=double(imread(['../Images/Output/ObjWise/',Obj,'/ObjWiseMC_1times.png']));
load(['../Images/Output/ObjWise/',Obj,'/ObjWiseMC_1times_bitplaneStyle']);
ObjWise_row=Function_Reconstruction_MLE(tmp_bitplane,alpha,q);
[ObjWise]=Function_WhiteBalanced(ObjWise_row,GT,Avg_row,WP,BP);
%% PixelWise
% PixWiseK1_row=double(imread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize1.png']));
% PixWiseK3_row=double(imread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize3.png']));
load(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize1_bitplaneStyle']);
PixWiseK1_row=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
[PixWiseK1]=Function_WhiteBalanced(PixWiseK1_row,GT,Avg_row,WP,BP);
load(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize3_bitplaneStyle']);
PixWiseK3_row=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
[PixWiseK3]=Function_WhiteBalanced(PixWiseK3_row,GT,Avg_row,WP,BP);
%% PSNR ‘S‘Ì
ROI=[1 1 256 256];
[PSNR_Avg,SSIM_Avg]=Function_ROI_PSNR(Avg,GT,ROI);
[PSNR_prop,SSIM_prop]=Function_ROI_PSNR(Prop,GT,ROI);
[PSNR_Objwise,SSIM_Objwise]=Function_ROI_PSNR(ObjWise,GT,ROI);
[PSNR_PixwiseK1,SSIM_PixwiseK1]=Function_ROI_PSNR(PixWiseK1,GT,ROI);
[PSNR_PixwiseK3,SSIM_PixwiseK3]=Function_ROI_PSNR(PixWiseK3,GT,ROI);


%% imshow
figure('Name','GT')
imshow(uint8(GT))
figure('Name','Avg')
imshow(uint8(Avg))
figure('Name','Prop')
imshow(uint8(Prop))
figure('Name','ObjWise')
imshow(uint8(ObjWise))
figure('Name','PixWiseK1')
imshow(uint8(PixWiseK1))
figure('Name','PixWiseK3')
imshow(uint8(PixWiseK3))
