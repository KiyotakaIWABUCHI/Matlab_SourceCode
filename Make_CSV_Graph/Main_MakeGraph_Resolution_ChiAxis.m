clear
close all
%D=csvread('../../csv/ObjSize_vs_HeatMap2.csv');
%load('../../csv/IEEE/Resolution_array')
%load('../../csv/IEEE/Resolution_array_Chiaxis_PhotonLevel_over10_4param')
%load('../../csv/IEEE/Resolution_array_Chiaxis_Texture_over10_4param')
%load('../../csv/IEEE/Resolution_array_Chiaxis_ObjSize_for_Slid_over10_4param') %0928‚ª‚«‚ê‚¢
%load('../../csv/IEEE/20201008_Resolution_array_Chiaxis_ObjSize2_for_Slid_4param') %0928‚ª‚«‚ê‚¢
%load('../../csv/IEEE/20201008_Resolution_array_Chiaxis_SlidTexure_4param') %0928‚ª‚«‚ê‚¢
%load('../../csv/IEEE/20201005_Resolution_Line_ObjSize') 
%load('../../csv/IEEE/20201005_Resolution_Line_Color')
load('../../csv/IEEE/20201010_Resolution_Line_ObjSize') 

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
%X(1:size(Measurement_Excel,3))= Measurement_mean(1,2,:)./Measurement_mean(1,3,:);
Measurement_mean(1,2:end,:)=(Measurement_mean(1,2:end,:)/10);
% A(1:size(Measurement_Excel,3))= Measurement_mean(1,2,:)./Measurement_mean(1,3,:);
% B(1:size(Measurement_Excel,3))=Measurement_mean(1,4,:);
D=[1 0.8 0.6 0.4 0.2];
for s=1:5
    hold on
    %A((s-1)*size(Measurement_Excel,3)+1:s*size(Measurement_Excel,3))= Measurement_mean(1,2,:)./(D(s)*Measurement_mean(1,3,:));
    %B((s-1)*size(Measurement_Excel,3)+1:s*size(Measurement_Excel,3))=Measurement_mean(1,4+(s-1),:);
    %A(1:size(Measurement_Excel,3))= Measurement_mean(1,2,:)./(D(s)*(Measurement_mean(1,3,:)));
    A(1:size(Measurement_Excel,3))= Measurement_Excel(1,4+(s-1),:);
    B(1:size(Measurement_Excel,3))=Measurement_mean(:,4+(s-1),:);
    if(s==1)
        plot(A,B,'o','MarkerSize',5,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','--','Color','b')
    elseif(s==2)
        plot(A,B,'^','MarkerSize',5,'MarkerFaceColor','r','MarkeredgeColor','r','LineStyle','--','Color','r')
    elseif(s==3)
        plot(A,B,'v','MarkerSize',5,'MarkerFaceColor',[0.9290 0.6940 0.1250],'MarkeredgeColor',[0.9290 0.6940 0.1250],'LineStyle','--','Color',[0.9290 0.6940 0.1250])
    elseif(s==4)
        plot(A,B,'h','MarkerSize',5,'MarkerFaceColor','c','MarkeredgeColor','c','LineStyle','--','Color','c')
    else
        plot(A,B,'d','MarkerSize',5,'MarkerFaceColor','m','MarkeredgeColor','m','LineStyle','--','Color','m')
    end
end
%plot(A,B,'o','MarkerSize',5,'LineWidth',1,'MarkerFaceColor','b','MarkeredgeColor','b')
% hold on
% ax = gca;
% ax.FontSize=Fsize
% B(1:size(Measurement_Excel,3))=Measurement_mean(1,5,:);
% plot(A,B,'d','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','r','MarkeredgeColor','r')
% B(1:size(Measurement_Excel,3))=Measurement_mean(1,6,:);
% plot(A,B,'^','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','m','MarkeredgeColor','m')
% B(1:size(Measurement_Excel,3))=Measurement_mean(1,7,:);
% plot(A,B,'v','MarkerSize',6,'LineWidth',1.5,'MarkerFaceColor','c','MarkeredgeColor','c')
%plot(D(2:end,1),D(2:end,10),'c-v','MarkerSize',6,'MarkerFaceColor','c','MarkeredgeColor','c')
axis([0.7 1.4 0 1.0]);
%l.Box='off';
%l.Location ='northoutside';
h_axes = gca;
h_axes.XAxis.FontSize = 14;
h_axes.YAxis.FontSize = 14;
h_axes.Position=[0.11 0.2 0.85 0.7];
l=legend('1/1','1/0.8','1/0.6','1/0.4','1/0.2','Position',[170 300 100 1]);
l.FontSize=16.0;
%l.NumColumns=1;
l.Orientation='horizontal';
ylabel('Error Rate of Motion Estimation','FontSize',18,'Color','k')
xlabel('Rate of Total \chi^2   (\chi2_A/\chi2_B) ','FontSize',17,'Color','k')
grid on
%print(gcf,'-dpng', '-r400','../../csv/Resolution_Degree_of_Interest_PhotonLevel.png')
%print(gcf,'-dpng', '-r400','../../csv/Resolution_Degree_of_Interest_Objsize.png')
%print(gcf,'-dpng', '-r400','../../csv/Slid_Texture.png')
print(gcf,'-dpng', '-r400','../../csv/Line_ObjSize_Line.png')
%print(gcf,'-dpng', '-r400','../../csv/Sqare_SlidNum.png')