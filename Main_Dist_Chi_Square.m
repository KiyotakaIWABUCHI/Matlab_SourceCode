clear
close all


%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=1;      %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                     %threashold
alpha=1; %0.4                    %paramater for contralling incident photon
SIZE=[256 256];
SIZE_3d=[256 256 output_subframe_number];
M=16;
Obj_Size=[128 1]; %たてｘよこ
StartPix=[70 128/2 128]; %たて　よこ　インターバル


Back_color=255/8; % 255/8
Obj_color=255;

mv=[0 2 8 16];
N_num=size(mv,2);%6
V_num=10;
T=1;


%%
v_cnt=0;

Mov_Obj=[0 0];
DC_rate=0;
%画像出力用
[Imgs,ROI]=Function_Dist_ImgGen(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix,2);
%[Imgs,ROI]=Function_Dist_ImgGen(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix,2);
[row,col]=find(ROI);
Dist_Sheet=zeros(N_num,T*Obj_Size(2));
Sample=size(Dist_Sheet,2);
average_chi(1:N_num)=0;
average_mv(1:N_num)=0;

for t=1:T
    
    [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
    
    Imgs_Partial_deblur=zeros(SIZE(1),SIZE(2),N_num);
    Chi_Maps=zeros(SIZE(1),SIZE(2),N_num);
    
    
    
    for n=1:N_num
        
        Motion_y=0;
        Motion_x=mv(n);
        Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,128);
        Img_Partial_deblur=Function_Reconstruction_MLE(Sift_bitplane,alpha,q);
        %figure
        %imshow(uint8(Img_Partial_deblur))
        Imgs_Partial_deblur(:,:,n)=Img_Partial_deblur;
        %[chi_2D]=Function_Module_Chi2MapCul(Sift_bitplane,0); %ちゅうい
        [chi_2D]=Function_Module_Chi2MapCul_Mpixel(Sift_bitplane,0,M); %ちゅうい
        Chi_Maps(:,:,n)=imresize(chi_2D,SIZE,'bicubic');
            if(t==1)
                gamma=1.5;
%                 imwrite(uint8(Img_Partial_deblur),['../Images/Output/Resolution_MCblur/Partial',num2str(n),'_Access_Image_blur_Mov',num2str(mv(2)),'.png'])
%                 imwrite(imresize(uint8(Img_Partial_deblur(128-20:128+20,64-20:64+20)),3,'nearest'),['../Images/Output/Resolution_MCblur/Partial',num2str(n),'_Scale_Access_Image_blur_Mov',num2str(mv(2)),'.png'])
%                 imwrite(uint8(Chi_Maps(:,:,n)*gamma),['../Images/Output/Resolution_MCblur/Partial',num2str(n),'_Access_Chi_Mov',num2str(mv(2)),'.png'])
%                 imwrite(imresize(uint8(Chi_Maps(128-20:128+20,64-20:64+20,n)*gamma),3,'nearest'),['../Images/Output/Resolution_MCblur/Partial',num2str(n),'_Scale_Access_Chi_Mov',num2str(mv(2)),'.png'])
            end
        Dist_Sheet(n,(t-1)*128+1:(t)*128)=Chi_Maps(StartPix(1):StartPix(1)+127,StartPix(2),n);
        average_chi(n)=average_chi(n)+sum(sum(Chi_Maps(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2):StartPix(2)+Obj_Size(2)-1,n)))/T/Obj_Size(1)/Obj_Size(2);
        average_mv(n)=Motion_x; %%注意
        
       
    end
    
%      img_result=double(Chi_Maps(:,:,1)<Chi_Maps(:,:,2)).*Imgs_Partial_deblur(:,:,1)+double(Chi_Maps(:,:,1)>=Chi_Maps(:,:,2)).*Imgs_Partial_deblur(:,:,2);
%      imwrite(imresize(uint8(img_result(128-20:128+20,64-20:64+20)*gamma),3,'nearest'),['../Images/Output/Resolution_MCblur/Output_Scale_Access_Image_blur_Mov',num2str(mv(2)),'.png'])
%      
    
end

Dist_Sheet=round(Dist_Sheet);
%histogram(Dist_Sheet(1,:))
pd1 = fitdist(transpose(Dist_Sheet(1,:)),'gamma') ;
pd2 = fitdist(transpose(Dist_Sheet(4,:)),'gamma') ;
pd3 = fitdist(transpose(Dist_Sheet(3,:)),'gamma') ;
pd4 = fitdist(transpose(Dist_Sheet(2,:)),'gamma') ;
%histfit(transpose(Dist_Sheet(1,:)),20,'gamma')

% hold on
% histogram(Dist_Sheet(2,:))
% hold on
% histogram(Dist_Sheet(3,:))

%save(['../csv/IEEE/202012019_ChiDist'],'Dist_Sheet')

x_values = 0:1:120;
y = pdf(pd1,x_values);
plot(x_values,y,'LineWidth',2)
hold on
y = pdf(pd4,x_values);
plot(x_values,y,'LineWidth',2)
y = pdf(pd3,x_values);
plot(x_values,y,'LineWidth',2)
y = pdf(pd2,x_values);
plot(x_values,y,'LineWidth',2)

%%
h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;
h_axes.XAxis.FontName = 'Helvetica';
h_axes.YAxis.FontName = 'Helvetica';

average_mv=round(average_mv)
average_chi=round(average_chi)
%h_axes.Position=[0.11 0.15 0.85 0.74];
l=legend(['$v_{\textrm{dff}}$ =',num2str(average_mv(1)),' ($\overline{\chi^2}=$',num2str(average_chi(1)),')'],['$v_{\textrm{dff}}$ =',num2str(average_mv(2)),' ($\overline{\chi^2}=$',num2str(average_chi(2)),')'],['$v_{\textrm{dff}}$ =',num2str(average_mv(3)),' ($\overline{\chi^2}=$',num2str(average_chi(3)),')'],['$v_{\textrm{dff}}$ =',num2str(average_mv(4)),' ($\overline{\chi^2}=$',num2str(average_chi(4)),')',]);
title(l,'Difference of translation $v_{\textrm{dff}}$','interpreter','latex')
set(l,'Interpreter','latex');
l.FontSize=16.0;
%l.NumColumns=1;
%l.Orientation='horizontal';
ylabel('Density','interpreter','latex','FontSize',18,'Color','k')
xlabel('Value of $\chi^2$','interpreter','latex','FontSize',18,'Color','k')
grid on
print(gcf,'-dpng', '-r500','../Images/Output/Resolution_Chi_vs_Motion/ChiSquare_Dist_20201221.png')
