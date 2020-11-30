clear
close all

load(['../../csv/IEEE/20201125_MCResolution'])
%csv_sheet(2:end,:)=20*log10(255./sqrt(csv_sheet(2:end,:)));
Fsize=16
Fsize_label=20
f=figure('Name','Resolution');
hold on
A(1:size(csv_sheet,2))= csv_sheet(1,:);
B(1:size(csv_sheet,2))= csv_sheet(2,:);
plot(A,B,'o','MarkerSize',6,'LineWidth',2,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','-','Color','b')
% A(1:size(csv_sheet,2))= csv_sheet(1,:);
% B(1:size(csv_sheet,2))= csv_sheet(3,:);
% plot(A,B,'o','MarkerSize',5,'MarkerFaceColor','r','MarkeredgeColor','r','LineStyle','--','Color','r')
% A(1:size(csv_sheet,2))= csv_sheet(1,:);
% B(1:size(csv_sheet,2))= csv_sheet(4,:);
% plot(A,B,'o','MarkerSize',5,'MarkerFaceColor','c','MarkeredgeColor','c','LineStyle','--','Color','c')
% A(1:size(csv_sheet,2))= csv_sheet(1,:);
% B(1:size(csv_sheet,2))= csv_sheet(5,:);
% plot(A,B,'o','MarkerSize',5,'MarkerFaceColor','m','MarkeredgeColor','m','LineStyle','--','Color','m')
ax = gca;
ax.FontSize=Fsize
axis([1 25 12000 22000])
xticks([1:4:25])
%xticklabels({'2','3','5','7','13','25'})
% l=legend('N=2','N=3','N=4','N=5');
% l.Orientation='horizontal';
% l.FontSize=16.0;
ylabel('MSE within Object Area','FontSize',18,'Color','k')
xlabel('Number of the Using Frames for Our Deblurring  ','FontSize',17,'Color','k')
grid on
%ax.YAxis.Exponent = 3;
print(gcf,'-dpng', '-r400','../../Images/Output/Resolution_MCblur/Resolution_MCblur.png')
