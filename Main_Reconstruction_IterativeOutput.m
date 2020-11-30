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
bitplanes=zeros(256,256,256,Loop_Num);
CHI_Maps=zeros(256,256,Loop_Num);
HeatMaps=zeros(256,256,Loop_Num);
CHI_Sum=zeros(256,256,Loop_Num);
ME_results=zeros(2,Loop_Num);
MotionMap=zeros(256,256,2);
%%
Verosity=-36;
%% Obj Selection
%Obj='test'
%Obj='toyplane'
%Obj='car_bus_heri'
%Obj='doubledoor'
%Obj='bird'
%Obj='IEEE_traffic'
%Obj='IEEE_sky_Z_chi'
%Obj='IEEE_limitation'
%Obj='IEEE_traffic_Z_chi'
%% こっち
%Obj='IEEE_traffic_Z_chi16'
Obj='IEEE_sky_Z_chi16'
%Obj='PCSJ_ppt_Scene'

for i=0:Loop_Num-1
    load(['../Images/Output/',Obj,'/IterativeOutput_',num2str(i+1),'times_bitplaneStyle']);
    load(['../Images/Output/',Obj,'/HeatMap_',num2str(i+1),'times_bitplaneStyle']);
    load(['../Images/Output/',Obj,'/Iterative_ME_Result_',num2str(i+1),'times']);
    bitplanes(:,:,:,i+1)=bitplane_MC;
    HeatMaps(:,:,i+1)=Heat_map;
    ME_results(1,i+1)=mean(mean(ME_Result(:,:,1)));
    ME_results(2,i+1)=mean(mean(ME_Result(:,:,2)));
    %[img_norm,img]=Function_Reconstruction_SUM(bitplane_MC);
    [img]=Function_Reconstruction_MLE(bitplane_MC,alpha,q);
%     figure
%     imshow(uint8(img))
    
    [chi_2D]=Function_Module_Chi2MapCul(bitplane_MC,Down_Sample_Rate_Reconstruction);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');
    CHI_Maps(:,:,i+1)=chi_2D;
%   figure
%   imshow(uint8(CHI_Maps(:,:,i+1)*5))
  imwrite(uint8(CHI_Maps(:,:,i+1)*3),['../Images/Output/',Obj,'/ChiMap_Noisy',num2str(i+1),'.png'])
end
 imshow(uint8(CHI_Maps(:,:,1)*2))
 figure
imshow(uint8(CHI_Maps(:,:,10)*2))
 imwrite(uint8(CHI_Maps(:,:,1)*3),['../Images/Output/',Obj,'/ChiMap_Noisy.png'])
%% chi no update ver
img_result_no_update=zeros(SIZE);
w_total=zeros(SIZE);
for i=0:Loop_Num-1
    %[img_norm,img]=Function_Reconstruction_SUM(bitplanes(:,:,:,i+1));
    [img]=Function_Reconstruction_MLE(bitplanes(:,:,:,i+1),alpha,q);
    img=double(img);
    w_tmp=exp(double(-CHI_Maps(:,:,i+1))/sigma_chi);
    img_result_no_update=img_result_no_update+w_tmp.*img;
    w_total=w_total+w_tmp;
end
figure('Name','exp_weight_image_chi_no_update')
imshow(uint8(img_result_no_update./w_total))

%% chi map update
for f_num=1:Loop_Num
%     for update_cycle=1:Cycle_update
%         %[image_pint_norm,image_pint]=Function_Reconstruction_SUM(bitplanes(:,:,:,f_num));
%         [image_pint]=Function_Reconstruction_MLE(bitplanes(:,:,:,f_num),alpha,q);
%         chi_map_pint=CHI_Maps(:,:,f_num);
%         %% ChiMap update process
%         chi_map_pint_update=Function_GuideFilter_ChiMap_Update(image_pint,chi_map_pint,Kernel_size,sigma);
%         %chi_map_pint_update = filter2(fspecial('average',Kernel_size),chi_map_pint);
%         %chi_map_pint_update=Function_Bilateral(chi_map_pint,Kernel_size,sigma_pix,sigma_dist);
%         CHI_Maps(:,:,f_num)=chi_map_pint_update;
%     end
    CHI_Maps(:,:,f_num) =imboxfilt(CHI_Maps(:,:,f_num),5);
    imwrite(uint8(CHI_Maps(:,:,f_num)*3),['../Images/Output/',Obj,'/ChiMap_Denoise',num2str(f_num),'.png'])
end
figure
imshow(uint8(CHI_Maps(:,:,1)*2))
figure
imshow(uint8(CHI_Maps(:,:,10)*2))

%% Reconstruction
img_result=zeros(SIZE);
w_total=zeros(SIZE);
imgs=zeros(SIZE(1),SIZE(2),Loop_Num);
for i=0:Loop_Num-1
    i_tmp=i+1;
    %[tmp_norm,img]=Function_Reconstruction_SUM(bitplanes(:,:,:,i_tmp));
    [img]=Function_Reconstruction_MLE(bitplanes(:,:,:,i_tmp),alpha,q);
    imgs(:,:,i_tmp)=double(img);
    img_resize=imresize(img,0.5,'bilinear');
    img_resize=imresize(img_resize,SIZE,'bilinear');
    %% 特定の速度以外をぼかす
%     if(ME_results(1,i_tmp)==Verosity)
%         imgs(:,:,i_tmp)=img_resize;
%     end
    w_tmp=exp(double(-CHI_Maps(:,:,i+1))/sigma_chi);
    img_result=img_result+w_tmp.*double(img);
    w_total=w_total+w_tmp;
end

figure('Name','exp_weight_image_update')
imshow(uint8(img_result./w_total))
img_WeightedIntegtion_all=img_result./w_total;

%% Reconstruction Min
[Chis_sort,rank_order]=sort(CHI_Maps,3);
min_chi_array=ones(size(w_total))*realmax;
img_result_min=zeros(size(w_total));
chi_rank=zeros(SIZE(1),SIZE(2),rank_num);

for i=0:Loop_Num-1
    %[tmp_norm,img]=Function_Reconstruction_SUM(bitplanes(:,:,:,i+1));
    [img]=Function_Reconstruction_MLE(bitplanes(:,:,:,i+1),alpha,q);
    img_result_min=double(min_chi_array>CHI_Maps(:,:,i+1)).*double(img)+double(min_chi_array<=CHI_Maps(:,:,i+1)).*img_result_min;
       
    % 最小chi2更新
    min_chi_array=double(min_chi_array>CHI_Maps(:,:,i+1)).*CHI_Maps(:,:,i+1)+double(min_chi_array<=CHI_Maps(:,:,i+1)).*min_chi_array;
end
%% Rank
w_total_rank=zeros(SIZE);
img_result_rank=zeros(SIZE);
w_tmp_rank=0;
sigma_chi_rank=sigma_chi;

for i=1:SIZE(1)
    for j=1:SIZE(2)      
        for r=1:rank_num        
            w_tmp_rank=exp(double(-CHI_Maps(i,j,rank_order(i,j,r)))/sigma_chi_rank);
            img_result_rank(i,j)=img_result_rank(i,j)+w_tmp_rank*imgs(i,j,rank_order(i,j,r));
            w_total_rank(i,j)=w_total_rank(i,j)+w_tmp_rank;
   
        end
        MotionMap(i,j,1)=ME_results(1,rank_order(i,j,1));
        MotionMap(i,j,2)=ME_results(2,rank_order(i,j,1));
    end
end
csvwrite(['../Images/Output/',Obj,'/X_MotionMap.csv'],int8(MotionMap(:,:,1)))
csvwrite(['../Images/Output/',Obj,'/Y_MotionMap.csv'],int8(MotionMap(:,:,2)))


figure('Name','exp_weight_rank_image_update')
imshow(uint8(img_result_rank./w_total_rank))
img_min_chi=img_result_rank./w_total_rank;

%%
imwrite(uint8(img_WeightedIntegtion_all),['../Images/Output/',Obj,'/ReconstractedImage_WeightedIntegration.png'])
imwrite(uint8(img_min_chi),['../Images/Output/',Obj,'/ReconstractedImage_MinumumChiMap.png'])
%imwrite(uint8(img_result_test./w_total_test),['../Images/Output/',Obj,'/Ideal_2frame.png'])
imwrite(uint8(CHI_Maps(:,:,1)*3),['../Images/Output/',Obj,'/ChiMap_Denoise.png'])