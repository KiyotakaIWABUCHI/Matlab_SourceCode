clear
close all
%%
alpha=1;%1.5 or 2
q=1;

%Obj='IEEE_Access_traffic_Z_chi16'
%Obj='IEEE_Access_sky_Z_chi16'
Obj='MSrep_traffic'
%Obj='MSrep_sky'
%Obj='test'

%Obj='MSrep_sky'
%Obj='IEEE_Access_limitation_Z_chi16'
%Obj='IEEE_sky_Z_chi16'
%Obj='IEEE_limitation_Z_chi16';
%% Original Bit-plane
folder='IE'
[status, msg, msgID] = mkdir(['../MSrep/tex/',Obj,'/',folder]);
load(['../Images/Output/',Obj,'/Original_bitplanes']);
photon_average=sum(sum(sum(bitplanes,3)))/256/256/256;
%% GT
GT_first=double(imread(['../Images/Output/',Obj,'/FirstFrameGroudTruth.png']));
GT_last=double(imread(['../Images/Output/',Obj,'/LastFrameGroudTruth.png']));
%WP=[156 77];%traffic
%WP=[30 116];%limitation
%WP=[171 133];%sky
%BP=[26 153];%traffic
%BP=[238 21];%limitation
%BP=[4 190];%sky
%% Avg
%[non,Avg_row]=Function_Reconstruction_SUM(bitplanes);
GT=imread(['../Images/Output/',Obj,'/nth_FrameGroudTruth.png']);
CIS_long=imread(['../Images/Output/',Obj,'/CIS_long.png']);
CIS_short=imread(['../Images/Output/',Obj,'/CIS_short.png']);
Avg=imread(['../Images/Output/',Obj,'/OIS_blur.png']);
Ours=imread(['../Images/Output/',Obj,'/OIS_Ours.png']);
Ours_advence=imread(['../Images/Output/',Obj,'/OIS_Ours_advance.png']);
%Ours_advence_highth=imread(['../Images/Output/',Obj,'/OIS_Ours_advance_highth.png']);
Ours_advence_highth=imread(['../Images/Output/',Obj,'/MF/OIS_Ours_advance_MF_IE.png']);
Ours_advence_lowth=imread(['../Images/Output/',Obj,'/OIS_Ours_advance_lowth.png']);
%Ours_advence_lowth=imread(['../Images/Output/',Obj,'/MF/OIS_Ours_advance_motion_filter_Sign_deblur.png']);
Objwise=imread(['../Images/Output/ObjWise/',Obj,'/ObjWiseMC_1times.png']);
Pixwise_small=imread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize11.png']);
Pixwise_large=imread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize31.png']);
imshow(uint8(Avg))
for t=1:1
    imshow(uint8(GT))
    if(t==1)
        ROI_user_point=[450 90 610 530];%bus
        %ROI_user_point=[360 340 660 960];% right wing
    elseif(t==2)
        %ROI_user_point=[230 430 410 930];%sign
        %ROI_user_point=[360 80 630 450];% right wing
    else
        %ROI_user_point=[590 410 769 940];%car
    end
    %ROI=[1 1 size(GT,1)  size(GT,2)];
    ROI=[ROI_user_point(1) ROI_user_point(2) ROI_user_point(3)-ROI_user_point(1)  ROI_user_point(4)-ROI_user_point(2)];
    [PSNR_CIS_long,SSIM_CIS_long,ROI_CIS_long,ROI_GT]=Function_ROI_PSNR(CIS_long,GT,ROI);
    [PSNR_CIS_short,SSIM_CIS_short,ROI_CIS_short]=Function_ROI_PSNR(CIS_short,GT,ROI);
    [PSNR_Avg,SSIM_Avg,ROI_Avg]=Function_ROI_PSNR(Avg,GT,ROI);
    [PSNR_prop,SSIM_prop,ROI_Ours]=Function_ROI_PSNR(Ours,GT,ROI);
    [PSNR_prop_Weight,SSIM_prop_Weight,ROI_Ours_advence]=Function_ROI_PSNR(Ours_advence,GT,ROI);
    [PSNR_prop_Weight_high,SSIM_prop_Weight_high,ROI_Ours_advence_highth]=Function_ROI_PSNR(Ours_advence_highth,GT,ROI);
    [PSNR_prop_Weight_low,SSIM_prop_Weight_low,ROI_Ours_advence_lowth]=Function_ROI_PSNR(Ours_advence_lowth,GT,ROI);
    [PSNR_Objwise,SSIM_Objwise,ROI_Objwise]=Function_ROI_PSNR(Objwise,GT,ROI);
    [PSNR_Pixwise_small,SSIM_Pixwise_small,ROI_Pixwise_small]=Function_ROI_PSNR(Pixwise_small,GT,ROI);
    [PSNR_Pixwise_large,SSIM_Pixwise_large,ROI_Pixwise_large]=Function_ROI_PSNR(Pixwise_large,GT,ROI);
    
    
    % %[Avg]=Function_WhiteBalanced(Avg_row,GT,Avg_row,WP,BP);
    % %% Prop
    % Prop_row=double(imread(['../Images/Output/',Obj,'/ReconstractedImage_MinumumChiMap.png']));
    % [Prop]=Function_WhiteBalanced(Prop_row,GT,Avg_row,WP,BP);
    % Prop_row_weight=double(imread(['../Images/Output/',Obj,'/ReconstractedImage_Futurework.png']));
    % [Prop_Weight]=Function_WhiteBalanced(Prop_row_weight,GT,Avg_row,WP,BP);
    % %% ObjWise
    % %ObjWise_row=double(imread(['../Images/Output/ObjWise/',Obj,'/ObjWiseMC_1times.png']));
    % load(['../Images/Output/ObjWise/',Obj,'/ObjWiseMC_1times_bitplaneStyle']);
    % ObjWise_row=Function_Reconstruction_MLE(tmp_bitplane,alpha,q);
    % [ObjWise]=Function_WhiteBalanced(ObjWise_row,GT,Avg_row,WP,BP);
    % %% PixelWise
    % % PixWiseK1_row=double(imread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize1.png']));
    % % PixWiseK3_row=double(imread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize3.png']));
    % load(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize1_bitplaneStyle']);
    % PixWiseK1_row=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
    % [PixWiseK1]=Function_WhiteBalanced(PixWiseK1_row,GT,Avg_row,WP,BP);
    % load(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize3_bitplaneStyle']);
    % PixWiseK3_row=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
    % [PixWiseK3]=Function_WhiteBalanced(PixWiseK3_row,GT,Avg_row,WP,BP);
    % load(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize7_bitplaneStyle']);
    % PixWiseK7_row=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
    % [PixWiseK7]=Function_WhiteBalanced(PixWiseK7_row,GT,Avg_row,WP,BP);
    %% PSNR 全体
    % ROI=[1 1 256 256];
    % [PSNR_Avg,SSIM_Avg]=Function_ROI_PSNR(Avg,GT,ROI);
    % [PSNR_prop,SSIM_prop]=Function_ROI_PSNR(Prop,GT,ROI);
    % [PSNR_prop_Weight,SSIM_prop_Weight]=Function_ROI_PSNR(Prop_Weight,GT,ROI);
    % [PSNR_Objwise,SSIM_Objwise]=Function_ROI_PSNR(ObjWise,GT,ROI);
    % [PSNR_Pixwise_large,SSIM_Pixwise_small]=Function_ROI_PSNR(PixWiseK1,GT,ROI);
    % [PSNR_Pixwise_large,SSIM_Pixwise_large]=Function_ROI_PSNR(PixWiseK3,GT,ROI);
    % [PSNR_PixwiseK7,SSIM_PixwiseK7]=Function_ROI_PSNR(PixWiseK7,GT,ROI);
    
    %% imshow
    % figure('Name','GT')
    % imshow(uint8(GT))
    % figure('Name','Avg')
    % imshow(uint8(Avg))
    % figure('Name','Prop')
    % imshow(uint8(Prop))
    % figure('Name','Prop_Weight')
    % imshow(uint8(Prop_Weight))
    % figure('Name','ObjWise')
    % imshow(uint8(ObjWise))
    % figure('Name','PixWiseK1')
    % imshow(uint8(PixWiseK1))
    % figure('Name','PixWiseK3')
    % imshow(uint8(PixWiseK3))
    % figure('Name','PixWiseK7')
    % imshow(uint8(PixWiseK7))
    
    
    result_psnr(1,:)=[PSNR_CIS_long,PSNR_CIS_short,PSNR_Avg,PSNR_prop,PSNR_prop_Weight,PSNR_Objwise,PSNR_Pixwise_small,PSNR_Pixwise_large];
    result_psnr(2,:)=[SSIM_CIS_long,SSIM_CIS_short,SSIM_Avg,SSIM_prop,SSIM_prop_Weight,SSIM_Objwise,SSIM_Pixwise_small,SSIM_Pixwise_large];
    result_table=table(["CIS_long";"CIS_short";"Avg";"Prop";"Prop_adv";"Prop_adv_high";"Prop_adv_low";"ObjWise";"PixWise_small";"PixWise_large"],[PSNR_CIS_long;PSNR_CIS_short;PSNR_Avg;PSNR_prop;PSNR_prop_Weight;PSNR_prop_Weight_high;PSNR_prop_Weight_low;PSNR_Objwise;PSNR_Pixwise_small;PSNR_Pixwise_large],[SSIM_CIS_long;SSIM_CIS_short;SSIM_Avg;SSIM_prop;SSIM_prop_Weight;SSIM_prop_Weight_high;SSIM_prop_Weight_low;SSIM_Objwise;SSIM_Pixwise_small;SSIM_Pixwise_large]);
    
    % %% ファイル出力
    %imwrite(uint8(ROI_Pixwise_small*1.1),['../Images/Output/',Obj,'/BlockWise_small_',num2str(t),'.png'])
    Gain=1.1;
%     imwrite(uint8(ROI_CIS_long*Gain),['../MSrep/tex/',Obj,'/',folder,'/CIS_long_',num2str(t),'.png'])
%     imwrite(uint8(ROI_CIS_short*Gain),['../MSrep/tex/',Obj,'/',folder,'/CIS_short_',num2str(t),'.png'])
%     imwrite(uint8(bitplanes(:,:,size(bitplanes,3)/2)*255),['../MSrep/tex/',Obj,'/',folder,'/nth_bitplane_',num2str(t),'.png'])
%     imwrite(uint8(ROI_GT*Gain),['../MSrep/tex/',Obj,'/',folder,'/nth_Frame_',num2str(t),'.png'])
%     imwrite(uint8(GT_first*Gain),['../MSrep/tex/',Obj,'/',folder,'/FirstFrame_',num2str(t),'.png'])
%     imwrite(uint8(GT_last*Gain),['../MSrep/tex/',Obj,'/',folder,'/LastFrame_',num2str(t),'.png'])
%     imwrite(uint8(ROI_Avg*Gain),['../MSrep/tex/',Obj,'/',folder,'/Avg_',num2str(t),'.png'])
%     imwrite(uint8(ROI_Ours*Gain),['../MSrep/tex/',Obj,'/',folder,'/Ours_',num2str(t),'.png'])
%     imwrite(uint8(ROI_Ours_advence*Gain),['../MSrep/tex/',Obj,'/',folder,'/Ours_advance_',num2str(t),'.png'])
     imwrite(uint8(ROI_Ours_advence_lowth*Gain),['../MSrep/tex/',Obj,'/',folder,'/Ours_advance_lowth_',num2str(t),'.png'])
     imwrite(uint8(ROI_Ours_advence_highth*Gain),['../MSrep/tex/',Obj,'/',folder,'/Ours_advance_highth_',num2str(t),'.png'])
%     imwrite(uint8(ROI_Objwise*Gain),['../MSrep/tex/',Obj,'/',folder,'/ObjWise_',num2str(t),'.png'])
%     imwrite(uint8(ROI_Pixwise_small*Gain),['../MSrep/tex/',Obj,'/',folder,'/BlockWise_11x11_',num2str(t),'.png'])
%     imwrite(uint8(ROI_Pixwise_large*Gain),['../MSrep/tex/',Obj,'/',folder,'/BlockWise_31x31_',num2str(t),'.png'])
%     writetable(result_table,['../MSrep/tex/',Obj,'/',folder,'/Image_Quality_',num2str(t),'.txt'])
end