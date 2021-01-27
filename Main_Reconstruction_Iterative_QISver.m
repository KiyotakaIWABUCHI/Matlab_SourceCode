clear
close all
%% paramater(all)
q=1;                     %threashold
alpha=1; %0.4                    %paramater for contralling incident photon
%SIZE=[512 512];
%SIZE=[720 1280];
SIZE=[512 512]*2;
Down_Sample_Rate_Reconstruction=2;
Num_bitplanes=16;
%%
sigma_chi=2;
%% chi update ver param
K=1;
%% important param
K_MLE=3; %default5
M=4;
K_birateral=1000;%1000
K_birateral_CIS=1000;
Downsample_chi=3; %default3
K_th_denoise=10;
K_th_denoise_low=2;
K_th_denoise_high=30;
%%
Loop_Num=12;
Set=3;
T=41;
%%
CIS_readnoise=2;
%% Obj Selection
%% こっち
%Obj='test_proposed'
%Obj='test'
Obj='MSrep_traffic'
%Obj='MSrep_sky'

ME_results=zeros(4,Loop_Num);
load(['../Images/Output/',Obj,'/Incident_photons']);
CIS_output=sum(Incident_photons,3)+poissrnd(ones(SIZE)*CIS_readnoise);
CIS_output=mat2gray(CIS_output)*255;
CIS_img=imboxfilt(CIS_output,K_MLE);
CIS_img_long = imresize(imbilatfilt(CIS_img, K_birateral_CIS),SIZE,'bicubic');
CIS_img_long=mat2gray(CIS_img_long)*255;
CIS_output=sum(Incident_photons(:,:,1:Num_bitplanes/4),3)+poissrnd(ones(SIZE)*CIS_readnoise);
CIS_output=mat2gray(CIS_output)*255;
CIS_img=imboxfilt(CIS_output,K_MLE);
CIS_img_short = imresize(imbilatfilt(CIS_img, K_birateral_CIS),SIZE,'bicubic');
CIS_img_short=mat2gray(CIS_img_short)*255;
imshow(uint8(CIS_img_short))

for i=0:Loop_Num-1
    load(['../Images/Output/',Obj,'/Iterative_ME_Result_',num2str(i+1),'times']);
    ME_results(1,i+1)=mean(mean(ME_Result(:,:,1)));
    ME_results(2,i+1)=mean(mean(ME_Result(:,:,2)));
    ME_results(3,i+1)=mean(mean(ME_Result(:,:,3)));
    ME_results(4,i+1)=mean(mean(ME_Result(:,:,4)));
end
load(['../Images/Output/',Obj,'/Original_bitplanes']);
img_blur=Function_Reconstruction_MLE_Oversample(bitplanes,alpha,q,K_MLE);
img_blur = imbilatfilt(img_blur,K_birateral);
figure
imshow(uint8(img_blur))

Photon_level=sum(sum(sum(bitplanes)))/SIZE(1)/SIZE(2)/size(bitplanes,3);
%%
CHI_Maps=zeros(SIZE(1),SIZE(2),Loop_Num);
imgs=zeros(SIZE(1),SIZE(2),Loop_Num);

n=Num_bitplanes/2;
for i=0:Loop_Num-1
    Motion_x=ME_results(1,i+1);
    Motion_y=ME_results(2,i+1);
    Motion_theta=ME_results(3,i+1);
    Motion_scale=ME_results(4,i+1);
    load(['../Images/Output/',Obj,'/IterativeOutput_',num2str(i+1),'times_bitplaneStyle']);
    %bitplane_shifted=Function_ShiftBitplane_Rigid_Selective_Refframe(bitplanes,Motion_x,Motion_y,Motion_theta,Motion_scale,O_obj,n);
    [img]=Function_Reconstruction_MLE_Oversample(bitplane_MC,alpha,q,K_MLE);
    %
     %                        figure('Name','current')
         %                   imshow(uint8(img))
    %                         figure('Name','befor')
    %                         imshow(uint8(img_before))
    %                         figure('Name','after')
    %                         imshow(uint8(img_after))
    %

    imgs(:,:,(i+1))=double(img);
    [chi_2D]=Function_Module_Chi2MapCul_Mpixel(bitplane_MC,Downsample_chi,M);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');
    chi_2D =imboxfilt(chi_2D,K);
    CHI_Maps(:,:,(i+1))=chi_2D;
end

%% Reconstruction Min
[Chis_sort,rank_order]=sort(CHI_Maps,3);

%% Rank
img_result_rank=zeros(SIZE);
cnt_advance=ones(SIZE);
cnt_advance_lowth=ones(SIZE);
cnt_advance_highth=ones(SIZE);
cnt_advance_motion_filter=ones(SIZE);

for i=1:SIZE(1)
    for j=1:SIZE(2)
        img_result_rank(i,j)=imgs(i,j,rank_order(i,j,1));
    end
end


img_result_rank_advance=img_result_rank;
img_result_rank_advance_lowth=img_result_rank;
img_result_rank_advance_highth=img_result_rank;
img_result_rank_advance_motion_filter=img_result_rank;
for i=1:SIZE(1)
    for j=1:SIZE(2)
        for t=1:Loop_Num
            if(CHI_Maps(i,j,t)<=K_th_denoise)
                img_result_rank_advance(i,j)=img_result_rank_advance(i,j)+imgs(i,j,t);
                cnt_advance(i,j)=cnt_advance(i,j)+1;
            end
            
            if(CHI_Maps(i,j,t)<=K_th_denoise_low)
                img_result_rank_advance_lowth(i,j)=img_result_rank_advance_lowth(i,j)+imgs(i,j,t);
                cnt_advance_lowth(i,j)=cnt_advance_lowth(i,j)+1;
            end
            
            if(CHI_Maps(i,j,t)<=K_th_denoise_high)
                img_result_rank_advance_highth(i,j)=img_result_rank_advance_highth(i,j)+imgs(i,j,t);
                cnt_advance_highth(i,j)=cnt_advance_highth(i,j)+1;
            end
        end
    end
end
%% motion filter advance
up_motion_filt=85;%bus20
under_motion_filt=75;%bus14
K_th_denoise_motion=0;
K_th_denoise_static=10;
for i=1:SIZE(1)
    i
    for j=1:SIZE(2)
        Motion=sqrt(ME_results(1,rank_order(i,j,1))*ME_results(1,rank_order(i,j,1))+ME_results(2,rank_order(i,j,1))*ME_results(2,rank_order(i,j,1)));
        for t=1:Loop_Num
            %Motion=sqrt(ME_results(1,t)*ME_results(1,t)+ME_results(2,t)*ME_results(2,t));
            if(Motion<=up_motion_filt && Motion>=under_motion_filt)
                if(CHI_Maps(i,j,t)<=K_th_denoise_motion)
                    img_result_rank_advance_motion_filter(i,j)= img_result_rank_advance_motion_filter(i,j)+imgs(i,j,t);
                    cnt_advance_motion_filter(i,j)=cnt_advance_motion_filter(i,j)+1;
                end
            else
                if(CHI_Maps(i,j,t)<=K_th_denoise_static)
                     img_result_rank_advance_motion_filter(i,j)= img_result_rank_advance_motion_filter(i,j)+imgs(i,j,t);
                     cnt_advance_motion_filter(i,j)=cnt_advance_motion_filter(i,j)+1;
                end
            end
     
        end
    end
end




img_result_rank_advance=img_result_rank_advance./cnt_advance;
img_result_rank_advance_highth=img_result_rank_advance_highth./cnt_advance_highth;
img_result_rank_advance_lowth=img_result_rank_advance_lowth./cnt_advance_lowth;
img_result_rank_advance_motion_filter=img_result_rank_advance_motion_filter./cnt_advance_motion_filter;
img_result_rank = imbilatfilt(img_result_rank,K_birateral);
img_result_rank_advance = imbilatfilt(img_result_rank_advance,K_birateral);
img_result_rank_advance_highth = imbilatfilt(img_result_rank_advance_highth,K_birateral);
img_result_rank_advance_lowth = imbilatfilt(img_result_rank_advance_lowth,K_birateral);
img_result_rank_advance_motion_filter = imbilatfilt(img_result_rank_advance_motion_filter,K_birateral);
%%
img_result_rank=mat2gray(img_result_rank)*255;
img_result_rank_advance=mat2gray(img_result_rank_advance)*255;
img_result_rank_advance_highth=mat2gray(img_result_rank_advance_highth)*255;
img_result_rank_advance_lowth=mat2gray(img_result_rank_advance_lowth)*255;
img_result_rank_advance_motion_filter=mat2gray(img_result_rank_advance_motion_filter)*255;
img_blur=mat2gray(img_blur)*255;

% imwrite(uint8(bitplanes(:,:,size(bitplanes,3)/2)*255),['../Images/Output/',Obj,'/bitplane.png'])
% imwrite(uint8(CIS_img_long),['../Images/Output/',Obj,'/CIS_long.png'])
% imwrite(uint8(CIS_img_short),['../Images/Output/',Obj,'/CIS_short.png'])
% imwrite(uint8(img_blur),['../Images/Output/',Obj,'/OIS_blur.png'])
% imwrite(uint8(img_result_rank),['../Images/Output/',Obj,'/OIS_Ours.png'])
% imwrite(uint8(img_result_rank_advance),['../Images/Output/',Obj,'/OIS_Ours_advance.png'])
% imwrite(uint8(img_result_rank_advance_highth),['../Images/Output/',Obj,'/OIS_Ours_advance_highth.png'])
% imwrite(uint8(img_result_rank_advance_lowth),['../Images/Output/',Obj,'/OIS_Ours_advance_lowth.png'])
imwrite(uint8(img_result_rank_advance_motion_filter),['../Images/Output/',Obj,'/OIS_Ours_advance_motion_filter.png'])
%imwrite(uint8(img_blur),['../Images/Output/',Obj,'/Re_img_blur/frame',num2str(f,'%03u'),'.png'])
% imwrite(uint8(img_result_rank),['../Images/Output/test_proposed/Re_img_only/frame',num2str(f,'%03u'),'.png'])
% imwrite(uint8(img_result_rank_zengo),['../Images/Output/test_proposed/Re_img_zengo/frame',num2str(f,'%03u'),'.png'])


