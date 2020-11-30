clear
close all


%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=1;      %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                     %threashold
alpha=1; %0.4                    %paramater for contralling incident photon
SIZE=[256 256]*2;
SIZE_3d=[SIZE(1) SIZE(2) output_subframe_number];

Obj_Size=[400 1]; %たてｘよこ
StartPix=[64 70 40]; %たて　よこ　インターバル


Back_color=177/4;
Obj_color=177;

V_num=40;
T=100;


%%
v_cnt=0;
Interval_v=1;

Mov_Obj=[0 0];
Movs=[0 0.75 1.0 2 4 8 14 20 30 40];
DC_rate=0;
[Imgs,ROI]=Function_Dist_ImgGen(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix,1);
[row,col]=find(ROI);

Num=V_num/Interval_v;
Dist_Sheet=zeros(2,size(Movs,2));
for t=1:T
    t
    [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
    
    Imgs_Partial_deblur=zeros(SIZE(1),SIZE(2),V_num);
    Chi_Maps=zeros(SIZE(1),SIZE(2),V_num);
    cnt=0;
    for n=1:size(Movs,2)
        cnt=cnt+1;
        Dist_Sheet(1,cnt)=Movs(n);
        Motion_y=0;
        Motion_x=Movs(n);
        Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,1);
        Img_Partial_deblur=Function_Reconstruction_MLE(Sift_bitplane,alpha,q);
        %figure
        %imshow(uint8(Img_Partial_deblur))
        Imgs_Partial_deblur(:,:,cnt)=Img_Partial_deblur;
        [chi_2D]=Function_Module_Chi2MapCul(Sift_bitplane,0); %ちゅうい
        Chi_Maps(:,:,cnt)=imresize(chi_2D,SIZE,'bicubic');
        %     if(t==1)
        %         imwrite(uint8(Img_Partial_deblur),['../Images/Output/Resolution_MCblur/Image_blur_Mov',num2str(n),'.png'])
        %    end
        %Dist_Sheet(n,(t-1)*128+1:(t)*128)=Chi_Maps(StartPix(1):StartPix(1)+127,StartPix(2),n);
        Dist_Sheet(2,cnt)=Dist_Sheet(2,cnt)+sum(sum(Chi_Maps(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2)-ceil(Motion_x):StartPix(2)+Obj_Size(2)-1,cnt)))/T/Obj_Size(1)/(ceil(Motion_x)+1)/Obj_Size(2);
    end
end

A=Dist_Sheet(1,:);
B=Dist_Sheet(2,:);
plot(A,B,'o','MarkerSize',6,'LineWidth',2,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','-','Color','b')

save(['../csv/IEEE/20201128_Motion_vs_Chi'],'Dist_Sheet')

% Dist_Sheet=round(Dist_Sheet);
% %histogram(Dist_Sheet(1,:))
% pd1 = fitdist(transpose(Dist_Sheet(1,:)),'gamma') ;
% pd2 = fitdist(transpose(Dist_Sheet(2,:)),'gamma') ;
% pd3 = fitdist(transpose(Dist_Sheet(3,:)),'gamma') ;
%histfit(transpose(Dist_Sheet(1,:)),20,'gamma')

% hold on
% histogram(Dist_Sheet(2,:))
% hold on
% histogram(Dist_Sheet(3,:))

%save(['../csv/IEEE/20201127_ChiDist'],'Dist_Sheet')
% 
% x_values = 0:1:100;
% y = pdf(pd1,x_values);
% plot(x_values,y,'LineWidth',2)
% hold on
% y = pdf(pd2,x_values);
% plot(x_values,y,'LineWidth',2)
% y = pdf(pd3,x_values);
% plot(x_values,y,'LineWidth',2)
% 
% %%
% h_axes = gca;
% h_axes.XAxis.FontSize = 16;
% h_axes.YAxis.FontSize = 16;
% 
% average_chi=round(average_chi)
% %h_axes.Position=[0.11 0.15 0.85 0.74];
% l=legend(['Average of chi-square :',num2str(average_chi(1))],['Average of chi-square :',num2str(average_chi(2))],['Average of chi-square :',num2str(average_chi(3))]);
% l.FontSize=16.0;
% %l.NumColumns=1;
% %l.Orientation='horizontal';
% ylabel('Density','FontSize',18,'Color','k')
% xlabel('Value of \chi^2','FontSize',18,'Color','k')
% grid on
% 
