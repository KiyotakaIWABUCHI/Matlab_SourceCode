clear
close all
D=csvread('../../csv/ObjSize_vs_HeatMap2_025step.csv');
f=figure('Name','Resolution');

%f.Position=[403 106 460 400]
Fsize=16
Fsize_label=20
h_axes = gca;
h_axes.XAxis.FontSize = 20;
h_axes.YAxis.FontSize = 20;
D(1:end,1)=D(1:end,1)/100;
D(1:end,2:end)=(D(1:end,2:end)/10);
plot(D(1:end,1),D(1:end,2),'b-o','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','b','MarkeredgeColor','b')
hold on
ax = gca;
ax.FontSize=Fsize
plot(D(1:end,1),D(1:end,3),'r-d','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','r','MarkeredgeColor','r')
plot(D(1:end,1),D(1:end,4),'m-^','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','m','MarkeredgeColor','m')
plot(D(1:end,1),D(1:end,5),'c-v','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','c','MarkeredgeColor','c')
%plot(D(2:end,1),D(2:end,10),'c-v','MarkerSize',6,'MarkerFaceColor','c','MarkeredgeColor','c')
axis([0.1 0.9 0 1]);
%l.Box='off';
%l.Location ='northoutside';
h_axes = gca;
h_axes.XAxis.FontSize = 14;
h_axes.YAxis.FontSize = 14;
h_axes.Position=[0.11 0.15 0.85 0.74];
l=legend('Rate-of-Interest 0.25','0.5','0.75','1.0','Position',[170 300 100 1]);
l.FontSize=16.0;
%l.NumColumns=1;
l.Orientation='horizontal';
ylabel('Error Rate of Motion Estimation','FontSize',18,'Color','k')
xlabel('Relative Size of Moving Object','FontSize',18,'Color','k')
grid on
%print(gcf,'-dpng', '-r400','../../csv/Resolution_Degree_of_Interest.png')
