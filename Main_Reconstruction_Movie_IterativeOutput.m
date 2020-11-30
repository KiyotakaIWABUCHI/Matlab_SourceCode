clear
close all
%% paramater(all)
q=1;                     %threashold
alpha=2; %0.4                    %paramater for contralling incident photon
SIZE=[256 256];
Down_Sample_Rate_Reconstruction=1;
%%
sigma_chi=2;
% sigma_pix=1000;
% sigma_dist=	100;
%% chi update ver param
Kernel_size=4; %10 dolfine %car heri 3  Kernel_Size=4 
sigma=100; %100
Cycle_update=1; %car he2
%% Rank Min reconst param
rank_num=1;
%% Previously Heatmap param
Th_HeatMap=0.0;
%%
Loop_Num=10;
%%
CHI_Maps=zeros(256,256,Loop_Num);
HeatMaps=zeros(256,256,Loop_Num);
CHI_Sum=zeros(256,256,Loop_Num);
ME_results=zeros(2,Loop_Num);
MotionMap=zeros(256,256,2);
%%
Verosity=-36;
%% Obj Selection
%% Ç±Ç¡Çø
Obj='IEEE_traffic_Z_chi16'
%Obj='IEEE_sky_Z_chi16'
%Obj='PCSJ_ppt_Scene'

load(['../Images/Output/',Obj,'/Original_bitplanes']);
for i=0:Loop_Num-1
    load(['../Images/Output/',Obj,'/Iterative_ME_Result_',num2str(i+1),'times']);
    ME_results(1,i+1)=mean(mean(ME_Result(:,:,1)));
    ME_results(2,i+1)=mean(mean(ME_Result(:,:,2)));
end

n=1;
K=5;
for n=1:256
n
imgs=zeros(SIZE(1),SIZE(2),Loop_Num);
for i=0:Loop_Num-1
    Motion_x=ME_results(1,i+1);
    Motion_y=ME_results(2,i+1);
    
    if(Motion_x==-44)
        n_tmp=n;
        Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,n_tmp);
    else
        n_tmp=1;
        Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,n_tmp);
    end
    
    [img]=Function_Reconstruction_MLE(Sift_bitplane,alpha,q);
    [chi_2D]=Function_Module_Chi2MapCul(Sift_bitplane,Down_Sample_Rate_Reconstruction);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');
    chi_2D =imboxfilt(chi_2D,K);
    imgs(:,:,i+1)=double(img);
    CHI_Maps(:,:,i+1)=chi_2D;
end


%% Reconstruction Min
[Chis_sort,rank_order]=sort(CHI_Maps,3);

%% Rank
w_total_rank=zeros(SIZE);
img_result_rank=zeros(SIZE);
sigma_chi_rank=sigma_chi;
% runk_num=1Ç≈ç≈è¨ílëIë
for i=1:SIZE(1)
    for j=1:SIZE(2)      
        for r=1:rank_num        
            w_tmp_rank=exp(double(-CHI_Maps(i,j,rank_order(i,j,r)))/sigma_chi_rank);
            img_result_rank(i,j)=img_result_rank(i,j)+w_tmp_rank*imgs(i,j,rank_order(i,j,r));
            w_total_rank(i,j)=w_total_rank(i,j)+w_tmp_rank;
        end
    end
end

imshow(uint8(img_result_rank./w_total_rank))
imwrite(uint8(img_result_rank./w_total_rank),['../Images/Output/',Obj,'/Movie_Frames_OnlyFast/frame',num2str(n,'%03u'),'.png'])
end
