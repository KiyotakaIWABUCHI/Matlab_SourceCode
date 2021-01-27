clear
close all
%load(['../../csv/IEEE/20201128_MCError'])
load(['../../csv/IEEE/20201219_MCError'])

A=Dist_Sheet(1,1:end);
B=Dist_Sheet(2,1:end);
[B_sorted,order]=sort(B,'ascend');
C=Dist_Sheet(3,:);
C_sorted=C(order);

X=B_sorted(3:end);
Y=C_sorted(3:end);
plot(X,Y,'o','MarkerSize',6,'LineWidth',2,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','-','Color','b')


h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;
h_axes.XAxis.FontName = 'Helvetica';
h_axes.YAxis.FontName = 'Helvetica';

axis([15 85 0 0.5])
% 
xticks([15:10:85])
yticks([0:0.1:0.5])

%,'in spite of ($\overline{\chi_A^2}<\overline{\chi_B^2}$)'
ylabel({'Error rate: Probability of $(\chi_A^2>\chi_B^2)$'},'interpreter','latex','FontSize',17,'Color','k')
xlabel({'The amount of blur $\overline{\chi_B^2}$ (corresponding to $v_{\textrm{dff}}$) [pixel]'},'interpreter','latex','FontSize',17)
grid on
str = 'The amount of blur $\overline{\chi_B^2}$ corresponding to ';
%xlabel(str,'interpreter','latex','FontSize',17,'Color','k')
l=legend({'$\overline{\chi_A^2}=15$ ($\chi^2$ with free motion blur)'});
l.FontSize=16.0;
set(l,'interpreter','latex')
print(gcf,'-dpng', '-r500','../../Images/Output/Resolution_Chi_vs_Motion/Error_Rate_of_Pixel_Selection_20201221.png')
