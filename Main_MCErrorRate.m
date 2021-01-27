clear
close all


%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=1;      %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                     %threashold
alpha=1; %0.4                    %paramater for contralling incident photon
SIZE=[256 256]*2;
SIZE_3d=[SIZE(1) SIZE(2) output_subframe_number];
M=16;
Obj_Size=[400 1]; %たてｘよこ
StartPix=[64 70 40]; %たて　よこ　インターバル


Back_color=255/8;
Obj_color=255;

V_num=40;
T=10;


%%
v_cnt=0;
Interval_v=1;

Mov_Obj=[0 0];
Movs=[0 2 4 8 12 16 24 40 50];
DC_rate=0;
[Imgs,ROI]=Function_Dist_ImgGen(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix,1);
[row,col]=find(ROI);

Num=V_num/Interval_v;
Dist_Sheet=zeros(3,size(Movs,2));
for t=1:T
    t
    [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
    
    Imgs_Partial_deblur=zeros(SIZE(1),SIZE(2),V_num);
    Chi_Maps=zeros(SIZE(1),SIZE(2),V_num);
    cnt=0;
    for n=1:size(Movs,2)
        cnt=cnt+1;
        Dist_Sheet(1,cnt)=Movs(n);
        Motion_y=0;
        Motion_x=Movs(n);
        Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,128);
        Img_Partial_deblur=Function_Reconstruction_MLE(Sift_bitplane,alpha,q);
        %figure
        %imshow(uint8(Img_Partial_deblur))
        Imgs_Partial_deblur(:,:,cnt)=Img_Partial_deblur;
        [chi_2D]=Function_Module_Chi2MapCul_Mpixel(Sift_bitplane,0,M); %ちゅうい
        Chi_Maps(:,:,cnt)=imresize(chi_2D,SIZE,'bicubic');
        %     if(t==1)
        %         imwrite(uint8(Img_Partial_deblur),['../Images/Output/Resolution_MCblur/Image_blur_Mov',num2str(n),'.png'])
        %    end
        %Dist_Sheet(n,(t-1)*128+1:(t)*128)=Chi_Maps(StartPix(1):StartPix(1)+127,StartPix(2),n);
        True=Chi_Maps(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2):StartPix(2),1);
        False=Chi_Maps(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2):StartPix(2),cnt);
        
        Error=sum(sum(double(True>False)))/T/Obj_Size(1);
        %Dist_Sheet(2,cnt)=Dist_Sheet(2,cnt)+sum(sum(Chi_Maps(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2)-ceil(Motion_x):StartPix(2)+Obj_Size(2)-1,n)))/T/Obj_Size(1)/(ceil(Motion_x)+1)/Obj_Size(2);
        Dist_Sheet(2,cnt)=Dist_Sheet(2,cnt)+sum(sum(Chi_Maps(StartPix(1):StartPix(1)+Obj_Size(1)-1,StartPix(2):StartPix(2),n)))/T/Obj_Size(1);
        Dist_Sheet(3,cnt)=Dist_Sheet(3,cnt)+Error;
    end
end

A=Dist_Sheet(1,:);
B=Dist_Sheet(2,:);
plot(A,B,'o','MarkerSize',6,'LineWidth',2,'MarkerFaceColor','b','MarkeredgeColor','b','LineStyle','-','Color','b')
save(['../csv/IEEE/20201219_MCError'],'Dist_Sheet')

