clear
close all
D=csvread('../../csv/ObjSize_vs_HeatMap2.csv');
f=figure('Name','Resolution');
f.Position=[403 246 560 460]
h_axes = gca;
h_axes.XAxis.FontSize = 20;
h_axes.YAxis.FontSize = 20;
D(2:end-1,1)=D(2:end-1,1)/100;
D(2:end,2:end)=(D(2:end,2:end)/10);
plot(D(2:end-1,1),D(2:end-1,3),'b-o','MarkerSize',6,'MarkerFaceColor','b','MarkeredgeColor','b')
hold on
plot(D(2:end-1,1),D(2:end-1,5),'r-d','MarkerSize',6,'MarkerFaceColor','r','MarkeredgeColor','r')
plot(D(2:end-1,1),D(2:end-1,7),'m-^','MarkerSize',6,'MarkerFaceColor','m','MarkeredgeColor','m')
plot(D(2:end-1,1),D(2:end-1,9),'c-v','MarkerSize',6,'MarkerFaceColor','c','MarkeredgeColor','c')
ylabel('Error Rate of Motion Estimation','FontSize',12,'Color','k')
xlabel('Relative Size of Moving Subject','FontSize',12,'Color','k')
l=legend('Degree-of-Interest(DoI) 0.2','DoI 0.4','DoI 0.6','DoI 0.8','Position',[210 335 1 1]);
l.FontSize=12.0;
%l.Box='off';
%l.Location ='northoutside';
l.Orientation='horizontal';
%l.NumColumns=4;
h_axes = gca;
h_axes.XAxis.FontSize = 12;
h_axes.YAxis.FontSize = 12;
grid on
print(gcf,'-dpng', '-r400','../../csv/Resolution_Degree_of_Interest.png')
