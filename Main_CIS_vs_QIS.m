clear
close all

output_subframe_number=128; %number of bitplane image
max_photon_number=2;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=2; %0.4               %paramater for contralling incident photon
SIZE=[256 256];
%% QIS_setting
DC_rate_QIS=0;
QIS_read_noise=ones(SIZE)*0.2;
QIS_PDP=0.7;
%% CIS_setting
CIS_read_noise=ones(SIZE)*20;
CIS_PDP=0.6;
%% spad_setting
DC_rate_spad=4.5/10000;
spad_read_noise=ones(SIZE)*0;
SPAD_PDP=0.4;
Imgs=zeros([SIZE output_subframe_number] );

for t_tmp=1:2:output_subframe_number
    %% Choise Images
    t_skip=2*t_tmp;
    tmp=rgb2gray(imread(['../Images/Input/3dsmax_overview/overview_frame',pad(num2str(t_skip-1),4,'left','0'),'.png']));
    %%
    Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
end


QIS_electrons=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number*QIS_PDP,min_photon_number,q,alpha,0);
CIS_electrons=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number*CIS_PDP,min_photon_number,q,alpha,0);
SPAD_electrons=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number*SPAD_PDP,min_photon_number,q,alpha,DC_rate_spad);

Read_out_frame=1;
Imgs_summation_CIS_long=zeros(SIZE(1),SIZE(2),Read_out_frame);
F=output_subframe_number/Read_out_frame;
for t=1:Read_out_frame
    Imgs_summation_CIS_long(:,:,t)=sum(CIS_electrons(:,:,(t-1)*F+1:(t)*F),3)+poissrnd(CIS_read_noise);
end

Read_out_frame=16;
Imgs_summation_CIS_short=zeros(SIZE(1),SIZE(2),Read_out_frame);
F=output_subframe_number/Read_out_frame;
for t=1:Read_out_frame
    Imgs_summation_CIS_short(:,:,t)=sum(CIS_electrons(:,:,(t-1)*F+1:(t)*F),3)+poissrnd(CIS_read_noise);
end




Read_out_frame=128;
Imgs_summation_QIS=zeros(SIZE(1),SIZE(2),Read_out_frame);
Imgs_summation_CIS=zeros(SIZE(1),SIZE(2),Read_out_frame);
Imgs_summation_SPAD=zeros(SIZE(1),SIZE(2),Read_out_frame);
F=output_subframe_number/Read_out_frame;
for t=1:Read_out_frame
    Imgs_summation_QIS(:,:,t)=sum(QIS_electrons(:,:,(t-1)*F+1:(t)*F),3)+poissrnd(QIS_read_noise);
    Imgs_summation_CIS(:,:,t)=sum(CIS_electrons(:,:,(t-1)*F+1:(t)*F),3)+poissrnd(CIS_read_noise);
    Imgs_summation_SPAD(:,:,t)=sum(SPAD_electrons(:,:,(t-1)*F+1:(t)*F),3)+poissrnd(spad_read_noise);
end

Motion_x=29;
Motion_y=0;
n_tmp=output_subframe_number/2;
Imgs_summation_QIS_shift=Function_ShiftBitplane_Selective_Refframe(Imgs_summation_QIS,Motion_x,Motion_y,size(Imgs_summation_QIS,3)/2);
Imgs_summation_CIS_shift=Function_ShiftBitplane_Selective_Refframe(Imgs_summation_CIS_short,Motion_x,Motion_y,size(Imgs_summation_CIS_short,3)/2);
Imgs_summation_SPAD_shift=Function_ShiftBitplane_Selective_Refframe(Imgs_summation_SPAD,Motion_x,Motion_y,size(Imgs_summation_SPAD,3)/2);

QIS_img=sum(Imgs_summation_QIS,3);
QIS_img=mat2gray(QIS_img)*255;
CIS_img_long=sum(Imgs_summation_CIS_long,3);
CIS_img_long=mat2gray(CIS_img_long)*255;
CIS_img_short=sum(Imgs_summation_CIS_short,3);
CIS_img_short=mat2gray(CIS_img_short)*255;
CIS_img_short_shift=sum(Imgs_summation_CIS_shift,3);
CIS_img_short_shift=mat2gray(CIS_img_short_shift)*255;
SPAD_img=sum(Imgs_summation_SPAD,3);
SPAD_img=mat2gray(SPAD_img)*255;



%%
SPAD_img_shift=sum(Imgs_summation_SPAD_shift,3);
SPAD_img_shift=mat2gray(SPAD_img_shift)*255;

% imshow(uint8(QIS_img))
% figure
% imshow(uint8(CIS_img))
% figure
% imshow(uint8(SPAD_img_shift))

% imwrite(unit8(CIS_img))
imshow(uint8(CIS_img_long))
figure
imshow(uint8(CIS_img_short))
figure
imshow(uint8(CIS_img_short_shift))
figure
imshow(uint8(SPAD_img))
figure
imshow(uint8(SPAD_img_shift))

imwrite(uint8(Imgs(:,:,1)),'../Images/Output/Overview/Scene.png')
imwrite(uint8(CIS_img_long),'../Images/Output/Overview/CIS_Long.png')
imwrite(uint8(CIS_img_short),'../Images/Output/Overview/CIS_short.png')
imwrite(uint8(CIS_img_short_shift),'../Images/Output/Overview/CIS_short_shift.png')
imwrite(uint8(SPAD_img),'../Images/Output/Overview/SPAD_img.png')
imwrite(uint8(SPAD_img),'../Images/Output/Overview/SPAD_img_ourmethod.png')


