clear
close all


%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=1;      %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                     %threashold
alpha=1; %0.4                    %paramater for contralling incident photon
SIZE=[256 256];
SIZE_3d=[256 256 output_subframe_number];

Obj_Size=[128 2]; %たてｘよこ
StartPix=[64 128 30]; %たて　よこ　インターバル

Back_color=44;
Obj_color=177;


N_num=2;%6
V_num=10;
T=1;
%%
csv_sheet=zeros(N_num,1);
v_cnt=0;
for v=30:30
    v
    Mov_Obj=[0 v]; %
    v_cnt=v_cnt+1;
    
    
    
    
    %% Function Img Gen
    for t=1:T
        t
        DC_rate=0;
        [Imgs,ROI]=Function_MCResolution_ImgGen(SIZE,output_subframe_number,Obj_Size,Mov_Obj,Back_color,Obj_color,StartPix,1);
        [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
        
        N_List=[1 10 30];
        %N_List=[1 2 3 4 6 12 24];
        n_cnt=0;
        
        for N=1:size(N_List,2)
            
            n_cnt=n_cnt+1;
            csv_sheet(1,n_cnt)=v/N_List(N)+1;
            
            Imgs_Partial_deblur=zeros(SIZE(1),SIZE(2),round(v/N_List(N))+1);
            Chi_Maps=zeros(SIZE(1),SIZE(2),round(v/N_List(N))+1);
            cnt=1;
            for n=0:N_List(N):v
                
                Motion_y=0;
                Motion_x=n;
                Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,1);
                Img_Partial_deblur=Function_Reconstruction_MLE(Sift_bitplane,alpha,q);
                %figure
                %imshow(uint8(Img_Partial_deblur))
                Imgs_Partial_deblur(:,:,cnt)=Img_Partial_deblur;
                [chi_2D]=Function_Module_Chi2MapCul(Sift_bitplane,0); %ちゅうい
                Chi_Maps(:,:,cnt)=imresize(chi_2D,SIZE,'bicubic');
                cnt=cnt+1;
                if(t==1)
                    imwrite(uint8(Img_Partial_deblur),['../Images/Output/Resolution_MCblur/Image_blur_Mov',num2str(n),'.png'])
                    imwrite(uint8(imresize(chi_2D,SIZE,'bicubic')*2),['../Images/Output/Resolution_MCblur/ChiMap_Mov',num2str(n),'.png'])
                end
            end
            
            
            %% Reconstruction Min
            [Chis_sort,rank_order]=sort(Chi_Maps,3);
            w_total_rank=zeros(SIZE);
            img_result_rank=zeros(SIZE);
            % runk_num=1で最小値選択
            for i=1:SIZE(1)
                for j=1:SIZE(2)
                    for r=1:1
                        img_result_rank(i,j)=Imgs_Partial_deblur(i,j,rank_order(i,j,r));
                    end
                end
            end
            %figure
            %imshow(uint8(img_result_rank))
            if(t==1)
            imwrite(uint8(img_result_rank),['../Images/Output/Resolution_MCblur/Result_Num_of_Frame',num2str(v/N_List(N)+1),'.png'])
            end
            GrounTruth=(Imgs(:,:,1))/max(max(Imgs(:,:,1)))*255;
            img_result_rank=img_result_rank/max(max(img_result_rank(:,:,1)))*255;
            %ROI=ones(SIZE);
            %imshow(uint8(ROI*255))
            MSE=sum(sum((ROI.*img_result_rank-ROI.*GrounTruth).*(ROI.*img_result_rank-ROI.*GrounTruth)))/sum(sum(ROI));
            %Psnr=20*log10(255.0/sqrt(MSE))
            csv_sheet(1+v_cnt,n_cnt)=csv_sheet(1+v_cnt,n_cnt)+MSE/T;
        end
    end  
end

%save(['../csv/IEEE/20201125_MCResolution'],'csv_sheet')


