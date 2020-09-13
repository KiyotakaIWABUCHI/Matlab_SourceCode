clear
close all
D=csvread('../../csv/ObjSize_vs_HeatMap2.csv');
%load('../../csv/IEEE/Resolution_array_Chiaxis_PhotonLevel_over10_4param')
load('../../csv/IEEE/Resolution_array_Chiaxis_Objsize_over10_4param')
f=figure('Name','Resolution');
%Measurement_mean=zeros(1,size(Measurement_Excel,2),size(Measurement_Excel,3))
Measurement_mean=mean(Measurement_Excel(2:end,:,:),1);
X(1:20)=0;
%f.Position=[403 106 460 400]
Fsize=16
Fsize_label=20
h_axes = gca;
h_axes.XAxis.FontSize = 20;
h_axes.YAxis.FontSize = 20;
X(1:size(Measurement_Excel,3))= Measurement_mean(1,2,:)./Measurement_mean(1,3,:);
Measurement_mean(1,2:end,:)=(Measurement_mean(1,2:end,:)/10);

A(1:size(Measurement_Excel,3))= Measurement_mean(1,2,:)./Measurement_mean(1,3,:);
B(1:size(Measurement_Excel,3))=Measurement_mean(1,4,:);
plot(A,B,'b-o','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','b','MarkeredgeColor','b')
hold on
ax = gca;
ax.FontSize=Fsize
B(1:size(Measurement_Excel,3))=Measurement_mean(1,5,:);
plot(A,B,'r-d','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','r','MarkeredgeColor','r')
B(1:size(Measurement_Excel,3))=Measurement_mean(1,6,:);
plot(A,B,'m-^','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','m','MarkeredgeColor','m')
B(1:size(Measurement_Excel,3))=Measurement_mean(1,7,:);
plot(A,B,'c-v','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','c','MarkeredgeColor','c')
%plot(D(2:end,1),D(2:end,10),'c-v','MarkerSize',6,'MarkerFaceColor','c','MarkeredgeColor','c')
%axis([0.05 0.15 0 1.0]);
%l.Box='off';
%l.Location ='northoutside';
h_axes = gca;
h_axes.XAxis.FontSize = 14;
h_axes.YAxis.FontSize = 14;
h_axes.Position=[0.11 0.15 0.85 0.74];
l=legend('Rate-of-Interest 1.5','2.0','4.0','8.0','Position',[170 300 100 1]);
l.FontSize=16.0;
%l.NumColumns=1;
l.Orientation='horizontal';
ylabel('Error Rate of Motion Estimation','FontSize',18,'Color','k')
xlabel('Relative Size of Moving Object','FontSize',18,'Color','k')
grid on
print(gcf,'-dpng', '-r400','../../csv/Resolution_Degree_of_Interest_PhotonLevel.png')
