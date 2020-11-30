clear
close all
%% paramater(all)
q=1;                     %threashold
alpha=2; %0.4                    %paramater for contralling incident photon
SIZE=[256 256];
%%
MotionMap=zeros(256,256,2);
%% Obj Selection
%% ‚±‚Á‚¿
Obj='IEEE_traffic_Z_chi16'
%Obj='IEEE_sky_Z_chi16'
%Obj='PCSJ_ppt_Scene'

%%
load(['../Images/Output/',Obj,'/Original_bitplanes']);
%% compare motion map load
K=3;
%x_Motion=csvread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize',num2str(K),'_X_MotionMap.csv']);
%y_Motion=csvread(['../Images/Output/PixelWise/',Obj,'/PixWiseMC_KernelSize',num2str(K),'_Y_MotionMap.csv']);

x_Motion=csvread(['../Images/Output/ObjWise/',Obj,'/x_Motion_Objwise.csv']);
y_Motion=csvread(['../Images/Output/ObjWise/',Obj,'/y_Motion_Objwise.csv']);

%% movie gen
for n=1:256
n
[MC_bitplane]=Function_MC_Selective_Refframe(bitplanes,x_Motion,y_Motion,n);
img_output=Function_Reconstruction_MLE(MC_bitplane,alpha,q);
%imwrite(uint8(img_output),['../Images/Output/PixelWise/',Obj,'/Movie_Frames/frame',num2str(n,'%03u'),'.png'])
imwrite(uint8(img_output),['../Images/Output/ObjWise/',Obj,'/Movie_Frames/frame',num2str(n,'%03u'),'.png'])
end
