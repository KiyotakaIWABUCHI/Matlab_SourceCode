clear
close all
%% paramater(all)
q=1;                     %threashold
alpha=2; %0.4                    %paramater for contralling incident photon
SIZE=[720 1280];
%% Obj Selection
%% こっち
WP=[15 1058];%traffic
BP=[28 920];%traffic
csv_psnr=zeros(4,39);
csv_ssim=zeros(4,39);
cnt=0;
for f=2:40
    cnt=cnt+1;
    img_only=imread(['../Images/Output/test_proposed/Re_img_only/frame',num2str(f,'%03u'),'.png']);
    img_zengo=imread(['../Images/Output/test_proposed/Re_img_zengo/frame',num2str(f,'%03u'),'.png']);
    img_blur=imread(['../Images/Output/test_proposed/Re_img_blur/frame',num2str(f,'%03u'),'.png']);
    load(['../Images/Output/test_proposed/set',num2str(f),'/bitplane_range'])
    n=(sum(bitplane_range)+1)/2-1;
    GT=rgb2gray(imread(['D:/Input/frames2/frame_',pad(num2str(n),4,'left','0'),'.bmp']));
     imshow(uint8(img_zengo))
%     figure
%     imshow(uint8(GT))
    
%     [img_blur_WB]=Function_WhiteBalanced(img_blur,GT,img_blur,WP,BP);
%     [img_only_WB]=Function_WhiteBalanced(img_only,GT,img_blur,WP,BP);
%     [img_zengo_WB]=Function_WhiteBalanced(img_zengo,GT,img_blur,WP,BP);
    
   
    ROI=[1 1 SIZE(1) SIZE(2)];
    %ROI=[282 28 337-282+1 178-28+1] ;
    %ROI=[390 692 628-390+1 839-692+1] ;% [Y,X,Height,Width]
    %ROI=[645 509 715-645+1 821-509+1] ;% [Y,X,Height,Width]
    [PSNR_Avg,SSIM_Avg,imgRoI,GTRoI]=Function_ROI_PSNR(img_blur,GT,ROI);
    %imwrite(uint8(imgRoI),['../Images/Output/test_proposed/blur_shadow.png'])
    [PSNR_only,SSIM_only,imgRoI,GTRoI]=Function_ROI_PSNR(img_only,GT,ROI);
    %imwrite(uint8(imgRoI),['../Images/Output/test_proposed/only_shadow.png'])
    [PSNR_zengo,SSIM_zengo,imgRoI,GTRoI]=Function_ROI_PSNR(img_zengo,GT,ROI);
    %imwrite(uint8(imgRoI),['../Images/Output/test_proposed/zengo_shadow.png'])
    %imwrite(uint8(GTRoI),['../Images/Output/test_proposed/GT_shadouw.png'])
    
    
    
    
    csv_psnr(1,cnt)=cnt;
    csv_psnr(2,cnt)=PSNR_Avg;
    csv_psnr(3,cnt)=PSNR_only;
    csv_psnr(4,cnt)=PSNR_zengo;
    
    csv_ssim(1,cnt)=cnt;
    csv_ssim(2,cnt)=SSIM_Avg;
    csv_ssim(3,cnt)=SSIM_only;
    csv_ssim(4,cnt)=SSIM_zengo;
    
     
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


save('../Images/Output/test_proposed//Movie_skate_psnr','csv_psnr')
save('../Images/Output/test_proposed/Movie_skate_ssim','csv_ssim')

