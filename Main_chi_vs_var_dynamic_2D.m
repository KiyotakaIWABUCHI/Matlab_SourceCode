clear
close all

%%
alpha_bright=1;
alpha_low=1;
output_subframe_number=256;
max_photon_number=1;
min_photon_number=0;
SIZE=[256 256];
q=1;

%%
Obj_Size=[64 64]; %たてｘよこ
StartPix=[60 50 32]; %たて　よこ　インターバル
Mov_Obj=[80 0];
Back_color=85;
Obj_color2=20%30; %51
Obj_color=200%177; %411

Hist_data_chi_bright=zeros(1,1);
Hist_data_var_bright=zeros(1,1);
Hist_data_chi_low=zeros(1,1);
Hist_data_var_low=zeros(1,1);
%% param proposed
M=16; %num. of pixs within a group

[Imgs,ROI]=Function_Dist_ImgGen_2Obj_Inverse(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,Obj_color2,StartPix);
bitplanes=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha_low,0);
Img_blur=Function_Reconstruction_SUM(bitplanes);
imshow(uint8(Img_blur))
imwrite(uint8(Imgs(:,:,1)),'../Images/Output/MS_report/MD_sceneFirst.png')
imwrite(uint8(Img_blur),'../Images/Output/MS_report/MD_blur.png')
imwrite(uint8(Imgs(:,:,end)),'../Images/Output/MS_report/MD_sceneLast.png')
imwrite(uint8(Imgs(:,:,128)),'../Images/Output/MS_report/MD_scene_static.png')
imwrite(uint8(ROI*255),'../Images/Output/MS_report/MD_ideal.png')

Imgs_static=repmat(Imgs(:,:,128),1,1,256);
bitplanes_static=Function_BitplaneGen(Imgs_static,output_subframe_number,max_photon_number,min_photon_number,q,alpha_low,0);
Img_static=Function_Reconstruction_SUM(bitplanes_static);
imshow(uint8(Img_static))

%%
Th_chi=30;
[chi_2D,Grouped_bitplane]=Function_Module_Chi2MapCul_Mpixel(bitplanes,0,M);
Chi_Map=chi_2D;
diff=(Grouped_bitplane-(Grouped_bitplane*0+sum(Grouped_bitplane,3)/size(Grouped_bitplane,3)));
Var_Map=1/size(Grouped_bitplane,3)*sum(diff.*diff,3);
imshow(uint8(Chi_Map))
figure
imshow(uint8(255*ROI))
PRsheet_chi=zeros(2,1);
PRsheet_var=zeros(2,1);


%%
[chi_2D_static,Grouped_bitplane]=Function_Module_Chi2MapCul_Mpixel(bitplanes_static,0,M);
Chi_Map_static=chi_2D_static;
diff=(Grouped_bitplane-(Grouped_bitplane*0+sum(Grouped_bitplane,3)/size(Grouped_bitplane,3)));
Var_Map_static=1/size(Grouped_bitplane,3)*sum(diff.*diff,3);

cnt=1;
%%
max_acc_chi=0;
max_acc_var=0;

for Th_tmp=0:0.1:50
    Chi_Map_norm=Chi_Map;
    Var_Map_norm=Var_Map;
    Detected_Chi=double(Chi_Map_norm>=Th_tmp);
    Detected_Var=double(Var_Map_norm>=Th_tmp);
    TP_chi= sum(sum(double(logical(ROI) & logical(Detected_Chi))));
    FP_chi= sum(sum(double(logical(1-ROI) & logical(Detected_Chi))));
    TN_chi= sum(sum(double(logical(1-ROI) & logical(1-Detected_Chi))));
    FN_chi= sum(sum(double(logical(ROI))))-TP_chi;
    TP_var= sum(sum(double(logical(ROI) & logical(Detected_Var))));
    FP_var= sum(sum(double(logical(1-ROI) & logical(Detected_Var))));
    FN_var= sum(sum(double(logical(ROI))))-TP_var;
    TN_var= sum(sum(double(logical(1-ROI) & logical(1-Detected_Var))));
    Precision_chi=TP_chi/(TP_chi+FP_chi);
    Precision_var=TP_var/(TP_var+FP_var);
    Recall_chi=TP_chi/(TP_chi+FN_chi);
    Recall_var=TP_var/(TP_var+FN_var);
    Acc_chi=(TP_chi+TN_chi)/(SIZE(1)*SIZE(2));
    Acc_var=(TP_var+TN_var)/(SIZE(1)*SIZE(2));
    
    
    
    if(max_acc_chi<Acc_chi)
        max_acc_chi=Acc_chi;
        th_acc_chi=Th_tmp;
        MD_result_chi=Detected_Chi;
    end
    
    if(max_acc_var<Acc_var)
        max_acc_var=Acc_var;
        th_acc_var=Th_tmp;
        MD_result_var=Detected_Var;
    end
    
    PRsheet_chi(1,cnt) = Recall_chi;
    PRsheet_chi(2,cnt) = Precision_chi;
    PRsheet_var(1,cnt) = Recall_var;
    PRsheet_var(2,cnt) = Precision_var;
    
    cnt=cnt+1;
end

Chi_Map_norm_static=Chi_Map_static;
Var_Map_norm_static=Var_Map_static;
Detected_Chi_static=double(Chi_Map_norm_static>=th_acc_chi);
Detected_Var_static=double(Var_Map_norm_static>=th_acc_var);
imshow(uint8(Detected_Chi_static*255))
imshow(uint8(Detected_Var_static*255))
imwrite(uint8(Detected_Chi_static*255),'../Images/Output/MS_report/MD_Chi_static.png')
imwrite(uint8(Detected_Var_static*255),'../Images/Output/MS_report/MD_Var_static.png')

[sorted,index_chi]=sort(PRsheet_chi(1,:),2);
[sorted,index_var]=sort(PRsheet_var(1,:),2);

X_chi=PRsheet_chi(1,index_chi(1:4:end));
Y_chi=PRsheet_chi(2,index_chi(1:4:end));
plot(X_chi,Y_chi,'o','MarkerSize',2,'LineWidth',1,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','-','Color','b')
hold on 
X_var=PRsheet_var(1,index_var);
Y_var=PRsheet_var(2,index_var);
plot(X_var,Y_var,'o','MarkerSize',2,'LineWidth',1,'MarkerFaceColor','m','MarkeredgeColor','m','LineStyle','-','Color','m')

h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;
h_axes.XAxis.FontName = 'Helvetica';
h_axes.YAxis.FontName = 'Helvetica';

ylabel('Precision','Interpreter','latex')
xlabel('Recall','Interpreter','latex')
l=legend('$\chi^2$','$\sigma^2$','Interpreter','latex','Location','northeast','Box','off');
l.FontSize=16.0;
l.NumColumns =1;
pbaspect([1.4 1 1])

axis([0 1 0 1])
xticks([0:0.2:1])
yticks([0:0.2:1])
grid on
%figure
%imshow(uint8(mat2gray(Chi_Map_norm)*128))
imwrite(uint8(MD_result_chi*255),'../Images/Output/MS_report/MD_Chi.png')
imwrite(uint8(MD_result_var*255),'../Images/Output/MS_report/MD_Var.png')
print(gcf,'-dpng', '-r500','../Images/Output/MS_report/Recall_Precision.png')


% cnt=1;
% for t=1:T
%     t
%     Motion_x=8;
%     Motion_y=0;
%     bitplane_static=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha_low,0);
%     bitplane_dynamic=Function_ShiftBitplane_Selective_Refframe(bitplane_static,-Motion_x,Motion_y,128);
%     %bitplane_dynamic=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha_bright,0);
%     Photon_level_dynamic = round(sum(sum(sum(bitplane_dynamic)))/SIZE(1)/SIZE(2)/output_subframe_number,1);
%     %bitplane_static=Function_BitplaneGen(Imgs_static,output_subframe_number,max_photon_number,min_photon_number,q,alpha_low,0);
%     Photon_level_static = round(sum(sum(sum(bitplane_static)))/SIZE(1)/SIZE(2)/output_subframe_number,1);
%     %%
%     [chi_2D,Grouped_bitplane]=Function_Module_Chi2MapCul_Mpixel(bitplane_dynamic,0,M);
%     Chi_bright=chi_2D(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2));
%     diff=(Grouped_bitplane-(Grouped_bitplane*0+sum(Grouped_bitplane,3)/size(Grouped_bitplane,3)));
%     Var_bright=1/size(Grouped_bitplane,3)*sum(diff(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2),:).*diff(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2),:),3);
%     %%
%     [chi_2D,Grouped_bitplane]=Function_Module_Chi2MapCul_Mpixel(bitplane_static,0,M);
%     Chi_low=chi_2D(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2));
%     diff=(Grouped_bitplane-(Grouped_bitplane*0+sum(Grouped_bitplane,3)/size(Grouped_bitplane,3)));
%     Var_low=1/size(Grouped_bitplane,3)*sum(diff(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2),:).*diff(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2),:),3);
%     
%     for i=1:size(Chi_bright,1)
%         Hist_data_chi_bright(cnt)=Chi_bright(i,1);
%         Hist_data_var_bright(cnt)=Var_bright(i,1);
%         Hist_data_chi_low(cnt)=Chi_low(i,1);
%         Hist_data_var_low(cnt)=Var_low(i,1);
%         cnt=cnt+1;
%     end
% end

% figure('Name','Chi')
% histogram(Hist_data_chi_bright,40)
% hold on
% histogram(Hist_data_chi_low,40)

% h_axes = gca;
% h_axes.XAxis.FontSize = 16;
% h_axes.YAxis.FontSize = 16;
% h_axes.XAxis.FontName = 'Helvetica';
% h_axes.YAxis.FontName = 'Helvetica';
% 
% 
% ylabel('Counts','interpreter','latex','FontSize',20,'Color','k')
% xlabel('$\chi^2$','interpreter','latex','FontSize',20,'Color','k')
% l=legend(['Movment：',num2str(Motion_x),' pixel'],['Movment：',num2str(0),' pixel']);
% l.FontSize=16.0;
% Ex_chi_bright=round(sum(Hist_data_chi_bright)/size(Hist_data_chi_bright,2),2);
% Ex_chi_low=round(sum(Hist_data_chi_low)/size(Hist_data_chi_low,2),2);
% print(gcf,'-dpng', '-r500','../Images/Output/MS_report/Chi_vs_Var_Dist_Chi_dynamic.png')
% csv=[Ex_chi_bright Ex_chi_low];
% csvwrite('../Images/Output/MS_report/Chi_vs_Var_Dist_Chi_Expectation_dynamic.csv',csv)
% 
% figure('Name','Var')
% histogram(Hist_data_var_bright,40)
% hold on
% histogram(Hist_data_var_low,40)
% 
% 
% h_axes = gca;
% h_axes.XAxis.FontSize = 16;
% h_axes.YAxis.FontSize = 16;
% h_axes.XAxis.FontName = 'Helvetica';
% h_axes.YAxis.FontName = 'Helvetica';
% 
% ylabel('Counts','interpreter','latex','FontSize',20,'Color','k')
% xlabel('$\sigma^2$','interpreter','latex','FontSize',20,'Color','k')
% 
% l=legend(['Movment：',num2str(Motion_x),' pixel'],['Movment：',num2str(0),' pixel']);
% l.FontSize=16.0;
% Ex_var_bright=round(sum(Hist_data_var_bright)/size(Hist_data_var_bright,2),2);
% Ex_var_low=round(sum(Hist_data_var_low)/size(Hist_data_var_low,2),2);
% csv=[Ex_var_bright Ex_var_low];
% csvwrite('../Images/Output/MS_report/Chi_vs_Var_Dist_Var_Expectation_dynamic.csv',csv)
% print(gcf,'-dpng', '-r500','../Images/Output/MS_report/Chi_vs_Var_Dist_Var_dynamic.png')
