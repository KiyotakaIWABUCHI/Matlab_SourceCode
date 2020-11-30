clear
close all
load(['../../csv/IEEE/20201128_Motion_vs_Chi'])

A=Dist_Sheet(1,:);
B=Dist_Sheet(2,:);
plot(A,B,'o','MarkerSize',6,'LineWidth',2,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','-','Color','b')


h_axes = gca;
h_axes.XAxis.FontSize = 16;
h_axes.YAxis.FontSize = 16;

axis([0 30 10 60])

xticks([0:5:30])
yticks([10:5:60])
ylabel('Average Value of \chi^2','FontSize',18,'Color','k')
xlabel('\nuÅFTranslation per 256 bit-planes [pixel] ','FontSize',18,'Color','k')
grid on
print(gcf,'-dpng', '-r400','../../Images/Output/Resolution_Chi_vs_Motion/Motion_vs_Chi.png')
