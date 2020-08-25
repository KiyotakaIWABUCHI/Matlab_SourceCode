clear
close all
%% paramater(all)
output_subframe_number=256; %number of bitplane image
max_photon_number=5;      %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                     %threashold
alpha=2; %0.4                    %paramater for contralling incident photon
SIZE=[256 256];
Down_Sample_Rate_Reconstruction=2;
%%
sigma_chi=2;
%% chi update ver param
Kernel_size=5; %10 dolfine %car heri 3
sigma=100; %100
Cycle_update=1; %car he2
%% Rank Min reconst param
rank_num=1;
%% Previously Heatmap param
Th_HeatMap=0.0;
%% Heatmap_diff
K_sigmoid_centor=10;
STEP_sigmoid=0.5;
K_DIV=2;
%%
Loop_Num=10;
%%
bitplanes=zeros(256,256,256,Loop_Num);
CHI_Maps=zeros(256,256,Loop_Num);
HeatMaps=zeros(256,256,Loop_Num);
CHI_Sum=zeros(256,256,Loop_Num);
ME_results=zeros(2,Loop_Num);
%%
Verosity=-36;
%% Obj Selection
%Obj='test'
%Obj='toyplane'
%Obj='car_bus_heri'
%Obj='doubledoor'
%Obj='bird'
%Obj='IEEE_traffic'
Obj='IEEE_sky'
%Obj='IEEE_limitation'

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
  figure
  imshow(uint8(CHI_Maps(:,:,i+1)*5))
end
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
    for update_cycle=1:Cycle_update
        %[image_pint_norm,image_pint]=Function_Reconstruction_SUM(bitplanes(:,:,:,f_num));
        [image_pint]=Function_Reconstruction_MLE(bitplanes(:,:,:,f_num),alpha,q);
        chi_map_pint=CHI_Maps(:,:,f_num);
        %% ChiMap update process
        chi_map_pint_update=Function_GuideFilter_ChiMap_Update(image_pint,chi_map_pint,Kernel_size,sigma);
        CHI_Maps(:,:,f_num)=chi_map_pint_update;
    end
end

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
    end
end

figure('Name','exp_weight_rank_image_update')
imshow(uint8(img_result_rank./w_total_rank))
img_min_chi=img_result_rank./w_total_rank;

%% Using Previously Heatmap > Th
img_result_PrevHeatMap=zeros(SIZE);
w_total_PrevHeatMap=zeros(SIZE);

for i=0:Loop_Num-1
    HeatMap_upperTh=double(HeatMaps(:,:,i+1)<=Th_HeatMap);
    w_tmp_PrevHeatMap=exp(double(-(HeatMap_upperTh*realmax+CHI_Maps(:,:,i+1)))/sigma_chi);
    img_result_PrevHeatMap=img_result_PrevHeatMap+w_tmp_PrevHeatMap.*double(imgs(:,:,i+1));
    w_total_PrevHeatMap=w_total_PrevHeatMap+w_tmp_PrevHeatMap;
end
figure('Name','exp weight Previously Heatmap ')
imshow(uint8(img_result_PrevHeatMap./w_total_PrevHeatMap))

%% test あとで消去
img_result_test=zeros(SIZE);
w_total_test=zeros(SIZE);
for i=0:4:4
    w_tmp_test=exp(double(-(CHI_Maps(:,:,i+1)))/sigma_chi);
    img_result_test=img_result_test+w_tmp_test.*double(imgs(:,:,i+1));
    w_total_test=w_total_test+w_tmp_test;
end
figure('Name','exp weight test ')
imshow(uint8(img_result_test./w_total_test))
%% Ref Neighbor Pixel
Kernel_i=3;
Kernel_j=3;
img_result_Neighbor=zeros(SIZE);
Frame_Num_Neiber=zeros(SIZE);
Frame_Num_Centor=zeros(SIZE);
for i=1+Kernel_i:SIZE(1)-Kernel_i
    for j=1+Kernel_j:SIZE(2)-Kernel_j
        cost_min_Neighbor=realmax;
        cost_min_centor=realmax;
        for c=1:10
            cost_tmp=CHI_Maps(i,j,c);
            cost_Neighbor_tmp=sum(sum(CHI_Maps(i-Kernel_i:i+Kernel_i,j-Kernel_j:j+Kernel_j,c)));
            if(cost_min_Neighbor>cost_Neighbor_tmp)
                cost_min_Neighbor=cost_Neighbor_tmp;
                c_Neighbor=c;
            end
            if(cost_min_centor>cost_tmp)
                cost_min_centor=cost_tmp;
                c_centor=c;
            end         
        end
        w_neighbor=exp(double(-(CHI_Maps(i,j,c_Neighbor)))/sigma_chi);
        w_centor=exp(double(-(CHI_Maps(i,j,c_Neighbor)))/sigma_chi)*0;
        img_result_Neighbor(i,j)=w_neighbor*double(imgs(i,j,c_Neighbor))+w_centor*double(imgs(i,j,c_centor));
        img_result_Neighbor(i,j)=img_result_Neighbor(i,j)/(w_neighbor+w_centor);
        Frame_Num_Neiber(i,j)=c_Neighbor;
        Frame_Num_Centor(i,j)=c_centor;
    end
end
figure('Name','exp weight Neighber ')
imshow(uint8(img_result_Neighbor))
%%
imwrite(uint8(img_WeightedIntegtion_all),['../Images/Output/',Obj,'/ReconstractedImage_WeightedIntegration.png'])
imwrite(uint8(img_min_chi),['../Images/Output/',Obj,'/ReconstractedImage_MinumumChiMap.png'])
%imwrite(uint8(img_result_test./w_total_test),['../Images/Output/',Obj,'/Ideal_2frame.png'])
imwrite(uint8(CHI_Maps(:,:,1)*3),['../Images/Output/',Obj,'/ChiMap_Denoise.png'])