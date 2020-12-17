clear
close all
%load(['../../csv/IEEE/20201128_Motion_vs_Chi'])
load(['../../csv/IEEE/20201215_Motion_vs_Chi'])

A=Dist_Sheet(1,:);
B=Dist_Sheet(2,:);
plot(A,B,'o','MarkerSize',6,'LineWidth',2,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','-','Color','b')


h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;
h_axes.XAxis.FontName = 'Helvetica';
h_axes.YAxis.FontName = 'Helvetica';

axis([0 30 15 60])
yticks([15:5:60])
ylabel('$\overline{\chi^2}$: (average of $\chi^2$)','interpreter','latex','FontSize',20,'Color','k')
xlabel('$v$: Translation per 256 bit-planes [pixel]','interpreter','latex','FontSize',20,'Color','k')
grid on
print(gcf,'-dpng', '-r500','../../Images/Output/Resolution_Chi_vs_Motion/Motion_vs_Chi.png')
%saveas(gcf,'../../Images/Output/Resolution_Chi_vs_Motion/Motion_vs_Chi.pdf')
