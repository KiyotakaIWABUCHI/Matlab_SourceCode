clear
close all

%%
alpha_bright=1;
alpha_low=1;
output_subframe_number=256;
max_photon_number=1;
min_photon_number=0;
SIZE=[512 50];
q=1;
T=100;

%%
Obj_Size=[400 1]; %たてｘよこ
StartPix=[64 25 0]; %たて　よこ　インターバル
Mov_Obj=[0 0];
Back_color=27;
Obj_color=177;

Hist_data_chi_bright=zeros(1,1);
Hist_data_var_bright=zeros(1,1);
Hist_data_chi_low=zeros(1,1);
Hist_data_var_low=zeros(1,1);
%% param proposed
M=16; %num. of pixs within a group

[Imgs,ROI]=Function_Dist_ImgGen2(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix);
%[Imgs_static,ROI]=Function_Dist_ImgGen2(SIZE,output_subframe_number,Obj_Size,Mov_Obj*0,Back_color,Obj_color,StartPix);

cnt=1;
for t=1:T
    t
    Motion_x=8;
    Motion_y=0;
    bitplane_static=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha_low,0);
    bitplane_dynamic=Function_ShiftBitplane_Selective_Refframe(bitplane_static,-Motion_x,Motion_y,128);
    %bitplane_dynamic=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha_bright,0);
    Photon_level_dynamic = round(sum(sum(sum(bitplane_dynamic)))/SIZE(1)/SIZE(2)/output_subframe_number,1);
    %bitplane_static=Function_BitplaneGen(Imgs_static,output_subframe_number,max_photon_number,min_photon_number,q,alpha_low,0);
    Photon_level_static = round(sum(sum(sum(bitplane_static)))/SIZE(1)/SIZE(2)/output_subframe_number,1);
    %%
    [chi_2D,Grouped_bitplane]=Function_Module_Chi2MapCul_Mpixel(bitplane_dynamic,0,M);
    Chi_bright=chi_2D(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2));
    diff=(Grouped_bitplane-(Grouped_bitplane*0+sum(Grouped_bitplane,3)/size(Grouped_bitplane,3)));
    Var_bright=1/size(Grouped_bitplane,3)*sum(diff(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2),:).*diff(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2),:),3);
    %%
    [chi_2D,Grouped_bitplane]=Function_Module_Chi2MapCul_Mpixel(bitplane_static,0,M);
    Chi_low=chi_2D(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2));
    diff=(Grouped_bitplane-(Grouped_bitplane*0+sum(Grouped_bitplane,3)/size(Grouped_bitplane,3)));
    Var_low=1/size(Grouped_bitplane,3)*sum(diff(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2),:).*diff(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2),:),3);
    
    for i=1:size(Chi_bright,1)
        Hist_data_chi_bright(cnt)=Chi_bright(i,1);
        Hist_data_var_bright(cnt)=Var_bright(i,1);
        Hist_data_chi_low(cnt)=Chi_low(i,1);
        Hist_data_var_low(cnt)=Var_low(i,1);
        cnt=cnt+1;
    end
end
figure('Name','Chi')
histogram(Hist_data_chi_bright,'Binwidth',3)
hold on
histogram(Hist_data_chi_low,'Binwidth',3)


h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;
h_axes.XAxis.FontName = 'Helvetica';
h_axes.YAxis.FontName = 'Helvetica';


ylabel('Counts','interpreter','latex','FontSize',20,'Color','k')
xlabel('$\chi^2$','interpreter','latex','FontSize',20,'Color','k')
l=legend(['Movment：',num2str(Motion_x),' pixel'],['Movment：',num2str(0),' pixel']);
l.FontSize=16.0;
Ex_chi_bright=round(sum(Hist_data_chi_bright)/size(Hist_data_chi_bright,2),2);
Ex_chi_low=round(sum(Hist_data_chi_low)/size(Hist_data_chi_low,2),2);
print(gcf,'-dpng', '-r500','../Images/Output/MS_report/Chi_vs_Var_Dist_Chi_dynamic.png')
csv=[Ex_chi_bright Ex_chi_low];
csvwrite('../Images/Output/MS_report/Chi_vs_Var_Dist_Chi_Expectation_dynamic.csv',csv)

figure('Name','Var')
histogram(Hist_data_var_bright,'Binwidth',0.4)
hold on
histogram(Hist_data_var_low,'Binwidth',0.4)


h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;
h_axes.XAxis.FontName = 'Helvetica';
h_axes.YAxis.FontName = 'Helvetica';

ylabel('Counts','interpreter','latex','FontSize',20,'Color','k')
xlabel('$\sigma^2$','interpreter','latex','FontSize',20,'Color','k')

l=legend(['Movment：',num2str(Motion_x),' pixel'],['Movment：',num2str(0),' pixel']);
l.FontSize=16.0;
Ex_var_bright=round(sum(Hist_data_var_bright)/size(Hist_data_var_bright,2),2);
Ex_var_low=round(sum(Hist_data_var_low)/size(Hist_data_var_low,2),2);
csv=[Ex_var_bright Ex_var_low];
csvwrite('../Images/Output/MS_report/Chi_vs_Var_Dist_Var_Expectation_dynamic.csv',csv)
print(gcf,'-dpng', '-r500','../Images/Output/MS_report/Chi_vs_Var_Dist_Var_dynamic.png')









