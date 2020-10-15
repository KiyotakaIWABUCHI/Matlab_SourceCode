clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=10;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=2; %0.4               %paramater for contralling incident photon
block_size_MLE=10;
SIZE=[256 256];
%% parameter ME Prop.
down_sample_rate=1;
Down_Sample_Rate_Grav=2;
Range_x=[-80 80 2]; %[start end] ‚Ý range_x=[-40 40 4]; dolfine car_bus bird
Range_y=[-0 0 2]; %range_y=[-20 20 4]; dolfin car_bus bird
Range_rotate=[-0 0 2]; %‚È‚µ
Range_scale=[0 0 10]; %‚È‚µ
%% Max Kernel Size => for k=0:2:K
K = 8;

%% Read Images
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
ME_Result=zeros(SIZE(1),SIZE(2),2);
for t_tmp=1:output_subframe_number
    %% Choise Images
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_car_bus_heri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_doubledoor/doubledoor_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_dolfin/bird_only_easy_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_pen/pen_only_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_pen',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_pen_mouse',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_hasami/hasami_frame',pad(num2str(output_subframe_number-t_tmp),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_toyplane_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/book_toyplane_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_newspaper/newspaper_car_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_doubledoor/doubledoor_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_CarBusHeri/car_bus_heri_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_traffic/traffic_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %tmp=rgb2gray(imread(['../Images/Input/3dsmax_animal/animal_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_limitation/limitation_frame',pad(num2str(t_tmp-1),4,'left','0'),'.png']));
    %%
    Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
end
%% Gen bitplane imgs
DC_rate=0; % DC_rate =>Dark Count Rate
% [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
% tmp=Function_Reconstruction_SUM(bitplanes);
% imshow(uint8(tmp))
%% load bit-plane for Compare
load('../Images/Output/IEEE_traffic_Z_chi/Original_bitplanes');
%load('../Images/Output/IEEE_animal/Original_bitplanes');
%load('../Images/Output/IEEE_sky_Z_chi/Original_bitplanes');
%load('../Images/Output/IEEE_limitation_Z_chi/Original_bitplanes');
%% PatchMatch
[non,img_before]=Function_Reconstruction_SUM(bitplanes(:,:,1:size(bitplanes)/2));
[non,img_after]=Function_Reconstruction_SUM(bitplanes(:,:,size(bitplanes)/2+1:end));


img_GT=double(imread('cameraman.tif'));

K=3;
K_delta=2;
R=10;
ramda=100;

img1=imresize(img_GT(1:end-10,1:end-10),SIZE,'nearest');
img2=imresize(img_GT(1:end-10,11:end),SIZE,'nearest');




A=transpose(1:size(img1,1));
origin_i=repmat(A,1,size(img1,1));
origin_j=transpose(origin_i);

Field_i=origin_i+round(rand(SIZE)*4*R-2*R);
Field_j=origin_j+round(rand(SIZE)*4*R-2*R);
imshow(uint8(img2))
hold on;
Vx=Field_j-origin_j;
Vy=Field_i-origin_i;
opflow = opticalFlow(Vx,Vy);
plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
% initialize

SIZE=[32 32];
for t=1:5
    [New_Field_i,New_Field_j,Vx,Vy]=Function_Patch_Match(img1,img2,Field_i,Field_j,SIZE,R,K,K_delta,ramda);
    Field_i=New_Field_i;
    Field_j=New_Field_j;
    imshow(uint8(img2))
    hold on;
    Vx=Field_j-origin_j;
    Vy=Field_i-origin_i;
    opflow = opticalFlow(Vx,Vy);
    plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
    pause(10^-3)
end
%%
SIZE=[64 64];
for t=1:5
    [New_Field_i,New_Field_j,Vx,Vy]=Function_Patch_Match(img1,img2,Field_i,Field_j,SIZE,R,K,K_delta,ramda);
    Field_i=New_Field_i;
    Field_j=New_Field_j;
    imshow(uint8(img2))
    hold on;
    Vx=Field_j-origin_j;
    Vy=Field_i-origin_i;
    opflow = opticalFlow(Vx,Vy);
    plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
    pause(10^-3)
end

SIZE=[128 128];
for t=1:5
    [New_Field_i,New_Field_j,Vx,Vy]=Function_Patch_Match(img1,img2,Field_i,Field_j,SIZE,R,K,K_delta,ramda);
    Field_i=New_Field_i;
    Field_j=New_Field_j;
    imshow(uint8(img2))
    hold on;
    Vx=Field_j-origin_j;
    Vy=Field_i-origin_i;
    opflow = opticalFlow(Vx,Vy);
    plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
    pause(10^-3)
end

SIZE=[256 256];
for t=1:10
    [New_Field_i,New_Field_j,Vx,Vy]=Function_Patch_Match(img1,img2,Field_i,Field_j,SIZE,R,K,K_delta,ramda);
    Field_i=New_Field_i;
    Field_j=New_Field_j;
    imshow(uint8(img2))
    hold on;
    Vx=Field_j-origin_j;
    Vy=Field_i-origin_i;
    opflow = opticalFlow(Vx,Vy);
    plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
    pause(10^-3)
end



% img_ref=zeros(SIZE(1)+2*(K+R),SIZE(2)+2*(K+R));
% img_ref((K+R)+1:(K+R)+SIZE(1),(K+R)+1:(K+R)+SIZE(2))=img_after;
% sdd_Min=ones(SIZE)*realmax;
% Vi=zeros(SIZE);
% Vj=zeros(SIZE);
% imshow(uint8(img2))
% hold on;
% Vx=Field_j-origin_j;
% Vy=Field_i-origin_i;
% opflow = opticalFlow(Vx,Vy);
% plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
% % pause(10^-3)



% Field_i=origin_i;
% Field_j=origin_j;
% frameGray(:,:,1)=Img1;
% frameGray(:,:,2)=Img2;
% % opticFlow=opticalFlowLK();
% % h = figure;
% % movegui(h);
% % hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
% % hPlot = axes(hViewPanel);
% blkMatcher = vision.BlockMatcher;
% blkMatcher.ReferenceFrameSource='Input port';
% Y=blkMatcher(Img2,Img1);
%
%
% for t=1:2
%     flow = estimateFlow(opticFlow,frameGray(:,:,t));
% end
%
% imshow(uint8(frameGray(:,:,2)*2))
% hold on
% plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2,'Parent',hPlot);
% hold off
% for i=K+1:SIZE(1)-K
%     for j=K+1:SIZE(2)-K
%         if(Field_i(i,j)<=K)
%             Field_i(i,j)=K;
%         elseif(Field_i(i,j)>=SIZE(1))
%             Field_i(i,j)=SIZE(1);
%         end
%         
%         if(Field_j(i,j)<=K)
%             Field_j(i,j)=K;
%         elseif(Field_j(i,j)>=SIZE(2))
%             Field_j(i,j)=SIZE(2);
%         end
%     end
% end
% 
% for t=1:10
%     t
%     for i=K+1:SIZE(1)-K
%         for j=K+1:SIZE(2)-K
%             i_shift_est=0;
%             j_shift_est=0;
%             for i_shift=-R:R
%                 for j_shift=-R:R
%                     tmpVx=(Field_j(i,j)+j_shift-origin_j(i,j));
%                     ref_Vx=abs(Vx(i-K:i+K,j-K:j+K)-tmpVx);
%                     ref_Vx(K+1,K+1)=0;
%                     
%                     tmpVy=(Field_i(i,j)+i_shift-origin_i(i,j));
%                     ref_Vy=abs(Vy(i-K:i+K,j-K:j+K)-tmpVy);
%                     ref_Vy(K+1,K+1)=0;
%                     
%                     diff_v=sum(sum(abs(ref_Vx)))+sum(sum(abs(ref_Vy)));
%                 
%                     diff=abs(img_ref(((K+R))+Field_i(i,j)+i_shift-K:((K+R))+Field_i(i,j)+i_shift+K,((K+R))+Field_j(i,j)+j_shift-K:((K+R))+Field_j(i,j)+j_shift+K)-img_before(i-K:i+K,j-K:j+K));
%                     
%                     ssd=sum(sum(diff))+ramda*diff_v;
%                     if(sdd_Min(i,j)>ssd)
%                         sdd_Min(i,j)=ssd;
%                         i_shift_est=i_shift;
%                         j_shift_est=j_shift;
%                         %                         Vi(i,j)=i_shift;
%                         %                         Vj(i,j)=j_shift;
%                         
%                     end
%                 end
%             end
%             
%             Field_i(i,j)=Field_i(i,j)+i_shift_est;
%             Field_j(i,j)=Field_j(i,j)+j_shift_est;
%             
%             if(Field_i(i,j)<=K)
%                 Field_i(i,j)=K;
%             elseif(Field_i(i,j)>=SIZE(1))
%                 Field_i(i,j)=SIZE(1);
%             end
%             
%             if(Field_j(i,j)<=K)
%                 Field_j(i,j)=K;
%             elseif(Field_j(i,j)>=SIZE(2))
%                 Field_j(i,j)=SIZE(2);
%             end
%         end
%     end
%     imshow(uint8(img_after))
%     Vx=Field_j-origin_j;
%     Vy=Field_i-origin_i;
%     opflow = opticalFlow(Vx,Vy);
%     plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
%     pause(10^-3)
% end
% Vx=Field_j-origin_j;
% Vy=Field_i-origin_i;
% opflow = opticalFlow(Vx,Vy);
% plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);

% for k=0:K
%     Kernel_Space=2*k+1;
%     [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_PixelWise(bitplanes,Range_x,Range_y,Kernel_Space);
%     [non,img_output]=Function_Reconstruction_SUM(bitplane_MC);
%     save(['../Images/Output/PixelWise/test/PixWiseMC_KernelSize',num2str(Kernel_Space),'_bitplaneStyle'],'bitplane_MC')
%     imwrite(uint8(img_output),['../Images/Output/PixelWise/test/PixWiseMC_KernelSize',num2str(Kernel_Space),'.png'])
% end


