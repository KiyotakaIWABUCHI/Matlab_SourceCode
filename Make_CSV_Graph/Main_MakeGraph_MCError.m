clear
close all
load(['../../csv/IEEE/20201128_MCError'])

A=Dist_Sheet(1,:);
B=Dist_Sheet(2,:);
[B_sorted,order]=sort(B,'ascend');
C=Dist_Sheet(3,:);
C_sorted=C(order);

X=B_sorted(2:end);
Y=C_sorted(2:end);
plot(X,Y,'o','MarkerSize',6,'LineWidth',2,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','-','Color','b')


h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;

axis([15 60 0 0.5])
% 
xticks([15:5:60])
yticks([0:0.1:0.5])
l=legend('\chi_A^2(Average) = 15');
l.FontSize=16.0;
ylabel({'Error Rate of Pixel Selection','(Selecting Min. one of (\chi_A^2 , \chi_B^2))'},'FontSize',18,'Color','k')
xlabel('\chi_B^2(Average)','FontSize',18,'Color','k')
grid on
print(gcf,'-dpng', '-r400','../../Images/Output/Resolution_Chi_vs_Motion/Error_Rate_of_Pixel_Selection.png')
