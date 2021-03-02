clear
close all
%load(['../../csv/IEEE/20201128_MCError'])
%load(['../../Images/Output/airplane_bridge512/Movie_zoom_psnr'])
%load(['../../Images/Output/test_proposed/Movie_skate_psnr'])
load(['../../Images/Output/test_proposed/Movie_psnr'])
%csv_psnr=csv_ssim;
A=csv_psnr(1,1:end);
B=csv_psnr(2,1:end);
plot(A,B,'r-o','MarkerSize',2,'LineWidth',1,'MarkerFaceColor','r','MarkeredgeColor','r')
hold on
B=csv_psnr(3,1:end);
plot(A,B,'m-o','MarkerSize',2,'LineWidth',1,'MarkerFaceColor','m','MarkeredgeColor','m')
B=csv_psnr(4,1:end);
plot(A,B,'b-o','MarkerSize',2,'LineWidth',1,'MarkerFaceColor','b','MarkeredgeColor','b')
%B=csv_psnr(5,1:end);
%plot(A,B,'r-o','MarkerSize',3,'LineWidth',0.8,'MarkerFaceColor','r','MarkeredgeColor','r')
Fsize_label=18;
axis([1 100 24 32])
ax = gca;
ax.FontSize=16;
xlabel('Frame number','interpreter','latex','FontSize',Fsize_label)
ylabel({'SSIM'},'interpreter','latex','FontSize',Fsize_label)
l=legend('w/o deblurring','-T/2 to T/2 only','Proposed');
%title(l,'Cost for ME')
set(l,'interpreter','latex')
l.FontSize=Fsize_label;
%l.Box='off';
l.Location ='northoutside';
l.NumColumns = 2;
grid on
%print(gcf,'-dpng', '-r500','../../Images/Output/airplane_bridge512/Movie_SSIM.png')