clear
close all
%% paramater(all)
q=1;                     %threashold
alpha=2; %0.4                    %paramater for contralling incident photon
SIZE=[512 512];
Down_Sample_Rate_Reconstruction=2;
%%
sigma_chi=2;
% sigma_pix=1000;
% sigma_dist=	100;
%% chi update ver param
K=5;
K_th=30.58;
th_dff=25;
%% Rank Min reconst param
rank_num=1;
%% Previously Heatmap param
Th_HeatMap=0.0;
%%
Loop_Num=5;
Set=3;
%%
ME_results=zeros(2,Loop_Num,Set);
%% Obj Selection
%% こっち
Obj='airplane_bridge512';
load(['../Images/Output/',Obj,'/Original_bitplanes']);
WP=[223 175];%traffic
BP=[1 1];%traffic
bitplanes=bitplanes_all(:,:,257:512);
blur_centor=Function_Reconstruction_MLE(bitplanes,alpha,q);
imshow(uint8(blur_centor))
csv_psnr=zeros(5,201);
csv_ssim=zeros(5,201);
for cnt=1:200
    cnt
    offset=cnt-101;
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_long_movie/airplane_bridge_frame',pad(num2str(257+offset+128-1),4,'left','0'),'.png']));
    GT=imresize(tmp(1:end,1:end),SIZE,'bicubic');
    bitplanes=bitplanes_all(:,:,257+offset:512+offset);
    blur=double(Function_Reconstruction_MLE(bitplanes,alpha,q));
    [blur]=Function_WhiteBalanced(blur,GT,blur_centor,WP,BP);
    denoise_tmp=double(imread(['../Images/Output/',Obj,'/movie_frame_denoising/frame',num2str(cnt,'%03u'),'.png']));
    [denoise_tmp]=Function_WhiteBalanced(denoise_tmp,GT,blur_centor,WP,BP);
    zengo_tmp=double(imread(['../Images/Output/',Obj,'/movie_frame_zengo/frame',num2str(cnt,'%03u'),'.png']));
    [zengo_tmp]=Function_WhiteBalanced(zengo_tmp,GT,blur_centor,WP,BP);
    only_tmp=double(imread(['../Images/Output/',Obj,'/movie_frame_only/frame',num2str(cnt,'%03u'),'.png']));
    [only_tmp]=Function_WhiteBalanced(only_tmp,GT,blur_centor,WP,BP);
    
    ROI=[1 1 SIZE(1) SIZE(2)];
    ROI=[282 28 337-282+1 178-28+1] ;
    [PSNR_Avg,SSIM_Avg]=Function_ROI_PSNR(blur,GT,ROI);
    [PSNR_only,SSIM_only]=Function_ROI_PSNR(only_tmp,GT,ROI);
    [PSNR_zengo,SSIM_zengo]=Function_ROI_PSNR(zengo_tmp,GT,ROI);
    [PSNR_denoise,SSIM_denoise]=Function_ROI_PSNR(denoise_tmp,GT,ROI);
    
    csv_psnr(1,cnt)=cnt;
    csv_psnr(2,cnt)=PSNR_Avg;
    csv_psnr(3,cnt)=PSNR_only;
    csv_psnr(4,cnt)=PSNR_zengo;
    csv_psnr(5,cnt)=PSNR_denoise;
    
    csv_ssim(1,cnt)=cnt;
    csv_ssim(2,cnt)=SSIM_Avg;
    csv_ssim(3,cnt)=SSIM_only;
    csv_ssim(4,cnt)=SSIM_zengo;
    csv_ssim(5,cnt)=SSIM_denoise;
    
%     imshow(uint8(zengo_tmp))
%     imwrite(uint8(zengo_tmp),['../Images/Output/',Obj,'/zengo_70.png'])
%     figure
%     imshow(uint8(only_tmp))
%     imwrite(uint8(only_tmp),['../Images/Output/',Obj,'/only_70.png'])
%     imwrite(uint8(denoise_tmp),['../Images/Output/',Obj,'/denoise_70.png'])
% imwrite(uint8(GT),['../Images/Output/',Obj,'/GT_70.png'])
% imwrite(uint8(blur),['../Images/Output/',Obj,'/blur_70.png'])
% 
Gain=1.0;
% %RoI=[93 144 15 150] %sky_left
% RoI=[282 337 28 178] %sky_right
% zoom_img=imresize(only_tmp(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
% imshow(uint8(zoom_img))
% imwrite(uint8(zoom_img),['../Images/Output/',Obj,'/only_ZoomImg.png'])
% zoom_img=imresize(zengo_tmp(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
% %imshow(uint8(zoom_img))
% imwrite(uint8(zoom_img),['../Images/Output/',Obj,'/zengo_ZoomImg.png'])
% zoom_img=imresize(denoise_tmp(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
% imwrite(uint8(zoom_img),['../Images/Output/',Obj,'/denoise_ZoomImg.png'])
% zoom_img=imresize(GT(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
% imwrite(uint8(zoom_img),['../Images/Output/',Obj,'/GT_ZoomImg.png'])
% zoom_img=imresize(blur(RoI(1):RoI(2),RoI(3):RoI(4)),3,'nearest')*Gain;
% imwrite(uint8(zoom_img),['../Images/Output/',Obj,'/blur_ZoomImg.png'])

    %%
end


save('../Images/Output/airplane_bridge512/Movie_zoom_psnr','csv_psnr')
save('../Images/Output/airplane_bridge512/Movie_zoom_ssim','csv_ssim')

