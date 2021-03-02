clear
close all

%%
alpha_bright=1;
alpha_low=0.1;
output_subframe_number=256;
max_photon_number=1;
min_photon_number=0;
SIZE=[512 512];
q=1;

%%
Obj_Size=[400 1]; %たてｘよこ
StartPix=[64 70 40]; %たて　よこ　インターバル
Mov_Obj=[0 0];
Back_color=177;
Obj_color=177;

Hist_data_chi_bright(1:SIZE(1)*SIZE(2))=0;
Hist_data_var_bright(1:SIZE(1)*SIZE(2))=0;
Hist_data_chi_low(1:SIZE(1)*SIZE(2))=0;
Hist_data_var_low(1:SIZE(1)*SIZE(2))=0;
%% param proposed
M=16; %num. of pixs within a group

[Imgs,ROI]=Function_Dist_ImgGen(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix,1);

bitplane_bright=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha_bright,0);
Photon_level_bright = round(sum(sum(sum(bitplane_bright)))/SIZE(1)/SIZE(2)/output_subframe_number,1);
bitplane_low=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha_low,0);
Photon_level_low = round(sum(sum(sum(bitplane_low)))/SIZE(1)/SIZE(2)/output_subframe_number,1);
%%
[chi_2D,Grouped_bitplane]=Function_Module_Chi2MapCul_Mpixel(bitplane_bright,0,M);
Chi_bright=chi_2D;
diff=(Grouped_bitplane-(Grouped_bitplane*0+sum(Grouped_bitplane,3)/size(Grouped_bitplane,3)));
Var_bright=1/size(Grouped_bitplane,3)*sum((diff.*diff),3);
%%
[chi_2D,Grouped_bitplane]=Function_Module_Chi2MapCul_Mpixel(bitplane_low,0,M);
Chi_low=chi_2D;
diff=(Grouped_bitplane-(Grouped_bitplane*0+sum(Grouped_bitplane,3)/size(Grouped_bitplane,3)));
Var_low=1/size(Grouped_bitplane,3)*sum((diff.*diff),3);


for i=1:SIZE(1)
    Hist_data_chi_bright((i-1)*SIZE(1)+1:(i)*SIZE(1))=Chi_bright(i,:);
    Hist_data_var_bright((i-1)*SIZE(1)+1:(i)*SIZE(1))=Var_bright(i,:);
    Hist_data_chi_low((i-1)*SIZE(1)+1:(i)*SIZE(1))=Chi_low(i,:);
    Hist_data_var_low((i-1)*SIZE(1)+1:(i)*SIZE(1))=Var_low(i,:);
end
 figure('Name','Chi')
 histogram(Hist_data_chi_bright,'Binwidth',1.5)
 hold on
 histogram(Hist_data_chi_low,'Binwidth',1.5)
 

h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;
h_axes.XAxis.FontName = 'Helvetica';
h_axes.YAxis.FontName = 'Helvetica';


ylabel('Counts','interpreter','latex','FontSize',20,'Color','k')
xlabel('$\chi^2$','interpreter','latex','FontSize',20,'Color','k')
l=legend(['Photon-level:',num2str(Photon_level_bright)],['Photon-level:',num2str(Photon_level_low)]);
l.FontSize=16.0;
Ex_chi_bright=round(sum(Hist_data_chi_bright)/size(Hist_data_chi_bright,2),2);
Ex_chi_low=round(sum(Hist_data_chi_low)/size(Hist_data_chi_low,2),2);
print(gcf,'-dpng', '-r500','../Images/Output/MS_report/Chi_vs_Var_Dist_Chi.png')
csv=[Ex_chi_bright Ex_chi_low];
csvwrite('../Images/Output/MS_report/Chi_vs_Var_Dist_Chi_Expectation.csv',csv)

 figure('Name','Var')
 histogram(Hist_data_var_bright,'Binwidth',0.3)
 hold on
 histogram(Hist_data_var_low,'Binwidth',0.3)
 
 
h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;
h_axes.XAxis.FontName = 'Helvetica';
h_axes.YAxis.FontName = 'Helvetica';

ylabel('Counts','interpreter','latex','FontSize',20,'Color','k')
xlabel('$\sigma^2$','interpreter','latex','FontSize',20,'Color','k')

l=legend(['Photon-level:',num2str(Photon_level_bright)],['Photon-level:',num2str(Photon_level_low)]);
l.FontSize=16.0;
Ex_var_bright=round(sum(Hist_data_var_bright)/size(Hist_data_var_bright,2),2);
Ex_var_low=round(sum(Hist_data_var_low)/size(Hist_data_var_low,2),2);
csv=[Ex_var_bright Ex_var_low];
csvwrite('../Images/Output/MS_report/Chi_vs_Var_Dist_Var_Expectation.csv',csv)
print(gcf,'-dpng', '-r500','../Images/Output/MS_report/Chi_vs_Var_Dist_Var.png')
    








