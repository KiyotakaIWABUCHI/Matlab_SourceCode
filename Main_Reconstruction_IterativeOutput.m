clear
close all
%% paramater(all)
output_subframe_number=256; %number of bitplane image
max_photon_number=10;      %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                     %threashold
alpha=2; %0.4                    %paramater for contralling incident photon
SIZE=[256 256];
Down_Sample_Rate_Reconstruction=1;
%%
sigma_chi=1;
%% chi update ver param
Kernel_size=10; %10 dolfine %car heri 3
sigma=50; %100
Cycle_update=10; %car he2
%% Rank Min reconst param
rank_num=5;

%%
bitplanes=zeros(256,256,256,10);
CHI_Maps=zeros(256,256,10);
CHI_Sum=zeros(256,256,10);

for i=0:9
    load(['../Images/Output/test/IterativeOutput_',num2str(i+1),'times_bitplaneStyle']);
    bitplanes(:,:,:,i+1)=bitplane_MC;
    [img_norm,img]=Function_Reconstruction_SUM(bitplane_MC);
    figure
    imshow(uint8(img))
    
    [chi_2D]=Function_Module_Chi2MapCul(bitplane_MC,Down_Sample_Rate_Reconstruction);
    chi_2D=imresize(chi_2D,SIZE,'bicubic');
    CHI_Maps(:,:,i+1)=chi_2D;
%   figure
%   imshow(uint8(CHI_Maps(:,:,i+1)*5))
end
 
%% chi no update ver

img_result_no_update=zeros(SIZE);
w_total=zeros(SIZE);
for i=0:9
    [img_norm,img]=Function_Reconstruction_SUM(bitplanes(:,:,:,i+1));
    img=double(img);
    w_tmp=exp(double(-CHI_Maps(:,:,i+1))/sigma_chi);
    img_result_no_update=img_result_no_update+w_tmp.*img;
    w_total=w_total+w_tmp;
end
figure('Name','exp_weight_image_chi_no_update')
imshow(uint8(img_result_no_update./w_total))

%% chi map update
for f_num=1:10
    for update_cycle=1:Cycle_update
        [image_pint_norm,image_pint]=Function_Reconstruction_SUM(bitplanes(:,:,:,f_num));
        chi_map_pint=CHI_Maps(:,:,f_num);
        %% ChiMap update process
        chi_map_pint_update=Function_GuideFilter_ChiMap_Update(image_pint,chi_map_pint,Kernel_size,sigma);
        CHI_Maps(:,:,f_num)=chi_map_pint_update;
    end
end

%% reconstruction

img_result=zeros(SIZE);
w_total=zeros(SIZE);
imgs=zeros(SIZE(1),SIZE(2),11);
for i=0:9
    i_tmp=i+1;
    [tmp_norm,img]=Function_Reconstruction_SUM(bitplanes(:,:,:,i_tmp));
    imgs(:,:,i_tmp)=double(img);
    w_tmp=exp(double(-CHI_Maps(:,:,i+1))/sigma_chi);
    img_result=img_result+w_tmp.*double(img);
    w_total=w_total+w_tmp;
    
end

figure('Name','exp_weight_image_update')
imshow(uint8(img_result./w_total))

%% reconstruction Min
[Chis_sort,rank_order]=sort(CHI_Maps,3);
min_chi_array=ones(size(w_total))*realmax;
img_result_min=zeros(size(w_total));
chi_rank=zeros(SIZE(1),SIZE(2),rank_num);

for i=0:9
    [tmp_norm,img]=Function_Reconstruction_SUM(bitplanes(:,:,:,i+1));
    img_result_min=double(min_chi_array>CHI_Maps(:,:,i+1)).*double(img)+double(min_chi_array<=CHI_Maps(:,:,i+1)).*img_result_min;
       
    % �ŏ�chi2�X�V
    min_chi_array=double(min_chi_array>CHI_Maps(:,:,i+1)).*CHI_Maps(:,:,i+1)+double(min_chi_array<=CHI_Maps(:,:,i+1)).*min_chi_array;
end

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

