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

Obj_Size=[128 1]; %たてｘよこ
StartPix=[64 70 40]; %たて　よこ　インターバル


Back_color=177/4;
Obj_color=177;


N_num=4;%6
V_num=10;
T=20;


%%
v_cnt=0;

Mov_Obj=[0 1];
DC_rate=0;
[Imgs,ROI]=Function_Dist_ImgGen(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix,N_num);
[row,col]=find(ROI);
Dist_Sheet=zeros(N_num,T*Obj_Size(2));
Sample=size(Dist_Sheet,2);
average_chi(1:N_num)=0;
for t=1:T
    [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
    
    Imgs_Partial_deblur=zeros(SIZE(1),SIZE(2),N_num);
    Chi_Maps=zeros(SIZE(1),SIZE(2),N_num);
    
    
    
    for n=1:N_num
        
        Motion_y=0;
        Motion_x=((n-1)*Mov_Obj(2))^2;
        Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,1);
        Img_Partial_deblur=Function_Reconstruction_MLE(Sift_bitplane,alpha,q);
        %figure
        %imshow(uint8(Img_Partial_deblur))
        Imgs_Partial_deblur(:,:,n)=Img_Partial_deblur;
        [chi_2D]=Function_Module_Chi2MapCul(Sift_bitplane,0); %ちゅうい
        Chi_Maps(:,:,n)=imresize(chi_2D,SIZE,'bicubic');
        %     if(t==1)
        %         imwrite(uint8(Img_Partial_deblur),['../Images/Output/Resolution_MCblur/Image_blur_Mov',num2str(n),'.png'])
        %    end
        Dist_Sheet(n,(t-1)*128+1:(t)*128)=Chi_Maps(StartPix(1):StartPix(1)+127,StartPix(2),n);
        average_chi(n)=average_chi(n)+sum(sum(Chi_Maps(StartPix(1):StartPix(1)+127,StartPix(2),n)))/T/128;
    end
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

save(['../csv/IEEE/20201128_ChiDist'],'Dist_Sheet')

x_values = 0:1:100;
y = pdf(pd1,x_values);
plot(x_values,y,'LineWidth',2)
hold on
y = pdf(pd2,x_values);
plot(x_values,y,'LineWidth',2)
y = pdf(pd3,x_values);
plot(x_values,y,'LineWidth',2)
y = pdf(pd4,x_values);
plot(x_values,y,'LineWidth',2)

%%
h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;

average_chi=round(average_chi)
%h_axes.Position=[0.11 0.15 0.85 0.74];
l=legend([num2str(average_chi(1))],[num2str(average_chi(4))],[num2str(average_chi(3))],[num2str(average_chi(2))]);
title(l,'Average of \chi^2')
l.FontSize=16.0;
%l.NumColumns=1;
%l.Orientation='horizontal';
ylabel('Density','FontSize',18,'Color','k')
xlabel('Value of \chi^2','FontSize',18,'Color','k')
grid on
print(gcf,'-dpng', '-r400','../Images/Output/Resolution_Chi_vs_Motion/ChiSquare_Dist.png')
