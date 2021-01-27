clear
close all
%% paramater(all)
q=1;                     %threashold
alpha=2; %0.4                    %paramater for contralling incident photon
SIZE=[512 512];
Down_Sample_Rate_Reconstruction=2;
%%
sigma_chi=2;
% sigma_pix = 1000;
% sigma_dist = 100;
%% chi update ver param
K=1;
K_th=30.58;
th_dff=2;
D=2;
%% Rank Min reconst param
rank_num=1;
%% Previously Heatmap param
Th_HeatMap=0.0;
%%
Loop_Num=5;
Set=3;
%%
ME_results=zeros(2,Loop_Num,Set);
%% Obj Selection
%% こっち
Obj='airplane_bridge512'
load(['../Images/Output/',Obj,'/Original_bitplanes']);

for set=1:3
    for i=0:Loop_Num-1
        load(['../Images/Output/',Obj,'/set',num2str(set),'/Iterative_ME_Result_',num2str(i+1),'times']);
        ME_results(1,i+1,set)=mean(mean(ME_Result(:,:,1)));
        ME_results(2,i+1,set)=mean(mean(ME_Result(:,:,2)));
        %if(ME_results(2,1,1)==16)
            %ME_results(2,1,1)=14;
        %end
    end
end

bitplanes=zeros(size(bitplanes_all,1),size(bitplanes_all,2),256,3);
for set=1:3
    %bitplanes(:,:,:,set)=bitplanes_all(:,:,(set-1)*128+1+128:(set-1)*128+256+128);
end
%%
cnt=0;
for offset=-30:-30
    cnt=cnt+1;
    bitplanes(:,:,:,1)=bitplanes_all(:,:,384-256+1+offset:384+offset);
    bitplanes(:,:,:,2)=bitplanes_all(:,:,257+offset:512+offset);
    bitplanes(:,:,:,3)=bitplanes_all(:,:,384+offset:384+256-1+offset);
    %%
    for set=2:2
        CHI_Maps=zeros(SIZE(1),SIZE(2),Loop_Num);
        CHI_Maps_before=zeros(SIZE(1),SIZE(2),Loop_Num);
        CHI_Maps_after=zeros(SIZE(1),SIZE(2),Loop_Num);
        CHI_Maps_onlycurrent=zeros(SIZE(1),SIZE(2),Loop_Num);
        imgs=zeros(SIZE(1),SIZE(2),Loop_Num);
        imgs_after=zeros(SIZE(1),SIZE(2),Loop_Num);
        imgs_before=zeros(SIZE(1),SIZE(2),Loop_Num);
        imgs_onlycurrent=zeros(SIZE(1),SIZE(2),Loop_Num);
        n=128;
        for i=0:Loop_Num-1
            Motion_x_befor=ME_results(1,i+1,set-1);
            Motion_x=ME_results(1,i+1,set);
            Motion_x_after=ME_results(1,i+1,set+1);
            Motion_y_befor=ME_results(2,i+1,set-1);
            Motion_y=ME_results(2,i+1,set);
            Motion_y_after=ME_results(2,i+1,set+1);
            
            
            Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes(:,:,:,set),Motion_x,Motion_y,n);
            Sift_bitplane_before=Function_ShiftBitplane_Selective_Refframe(bitplanes(:,:,:,set-1),Motion_x_befor,Motion_y_befor,256);
            Sift_bitplane_after=Function_ShiftBitplane_Selective_Refframe(bitplanes(:,:,:,set+1),Motion_x_after,Motion_y_after,1);
            
            %     if(Motion_x==-44)
            %         n_tmp=n;
            %         Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,n_tmp);
            %     else
            %         n_tmp=1;
            %         Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,n_tmp);
            %     end
            %
            [img]=Function_Reconstruction_MLE(Sift_bitplane,alpha,q);
            imwrite(uint8(img),['../Images/Output/',Obj,'/set2/Partially_deblurred_images',num2str(i+1),'.png'])
            [img_before]=Function_Reconstruction_MLE(Sift_bitplane_before,alpha,q);
            imwrite(uint8(img_before),['../Images/Output/',Obj,'/set1/Partially_deblurred_images',num2str(i+1),'.png'])
            [img_after]=Function_Reconstruction_MLE(Sift_bitplane_after,alpha,q);
            imwrite(uint8(img_after),['../Images/Output/',Obj,'/set3/Partially_deblurred_images',num2str(i+1),'.png'])
            %[img]=Function_Reconstruction_SUM(Sift_bitplane);
%                         figure('Name','current')
%                         imshow(uint8(img))
%                         figure('Name','befor')
%                         imshow(uint8(img_before))
%                         figure('Name','after')
%                         imshow(uint8(img_after))
            
            imgs_onlycurrent(:,:,i+1)=double(img);
            imgs(:,:,(i+1))=double(img);
            imgs_before(:,:,(i+1))=double(img_before);
            imgs_after(:,:,(i+1))=double(img_after);
            
            [chi_2D]=Function_Module_Chi2MapCul(Sift_bitplane,Down_Sample_Rate_Reconstruction);
            chi_2D=imresize(chi_2D,SIZE,'bicubic');
            chi_2D =imboxfilt(chi_2D,K);
            CHI_Maps(:,:,(i+1))=chi_2D;
            CHI_Maps_onlycurrent(:,:,i+1)=chi_2D;
            [chi_2D]=Function_Module_Chi2MapCul(Sift_bitplane_before,Down_Sample_Rate_Reconstruction);
            chi_2D=imresize(chi_2D,SIZE,'bicubic');
            chi_2D =imboxfilt(chi_2D,K);
            CHI_Maps_before(:,:,(i+1))=chi_2D;
            [chi_2D]=Function_Module_Chi2MapCul(Sift_bitplane_after,Down_Sample_Rate_Reconstruction);
            chi_2D=imresize(chi_2D,SIZE,'bicubic');
            chi_2D =imboxfilt(chi_2D,K);
            CHI_Maps_after(:,:,(i+1))=chi_2D;
        end
        
        
        %% Reconstruction Min
        [Chis_sort,rank_order]=sort(CHI_Maps,3);
        [Chis_sort,rank_order_before]=sort(CHI_Maps_before,3);
        [Chis_sort,rank_order_after]=sort(CHI_Maps_after,3);
        [Chis_sort_onlycurrent,rank_order_onlycurrent]=sort(CHI_Maps_onlycurrent,3);
        
        %% Rank
        w_total_rank=zeros(SIZE);
        img_result_rank=zeros(SIZE);
        img_result_rank_denoise=zeros(SIZE);
        sigma_chi_rank=sigma_chi;
        w_total_rank_onlycurrent=zeros(SIZE);
        img_result_rank_onlycurrent=zeros(SIZE);
        sigma_chi_rank_onlycurrent=sigma_chi;
        % runk_num=1で最小値選択
        cnt_addpixel_denoise=ones(SIZE);
        r=1;
        for i=1:SIZE(1)
            for j=1:SIZE(2)
                img_result_rank(i,j)=imgs(i,j,rank_order(i,j,r));
                ME_x=ME_results(1,rank_order(i,j,r),2);
                ME_y=ME_results(2,rank_order(i,j,r),2);
                dff_CHI_before=CHI_Maps(i,j,rank_order(i,j,r))-CHI_Maps_before(i,j,rank_order_before(i,j,r));
                dff_CHI_after=CHI_Maps(i,j,rank_order(i,j,r))-CHI_Maps_after(i,j,rank_order_after(i,j,r));
                
                if(dff_CHI_before>th_dff)
                    img_result_rank(i,j)=imgs_before(i,j,rank_order_before(i,j,r));
                    ME_x=ME_results(1,rank_order_before(i,j,r),1);
                    ME_y=ME_results(2,rank_order_before(i,j,r),1);
                end
                if(dff_CHI_after>th_dff)
                    if(dff_CHI_after>dff_CHI_before)
                        img_result_rank(i,j)=imgs_after(i,j,rank_order_after(i,j,r));
                        ME_x=ME_results(1,rank_order_after(i,j,r),3);
                        ME_y=ME_results(2,rank_order_after(i,j,r),3);
                    end
                end
                %% denoising process
                img_result_rank_denoise(i,j)=img_result_rank(i,j);
                for t=0:Loop_Num-1
                    if(CHI_Maps(i,j,t+1)<K_th)
                        img_result_rank_denoise(i,j)=img_result_rank_denoise(i,j)+imgs(i,j,t+1);
                        cnt_addpixel_denoise(i,j)=cnt_addpixel_denoise(i,j)+1;
                    end
                    
                    if(ME_results(1,t+1,1)>=ME_x-D && ME_results(1,t+1,1)<=ME_x+D && ME_results(2,t+1,1)<=ME_y-D && ME_results(2,t+1,1)>=ME_y+D)
                        if(CHI_Maps_before(i,j,t+1)<K_th)
                            img_result_rank_denoise(i,j)=img_result_rank_denoise(i,j)+imgs_before(i,j,t+1);
                            cnt_addpixel_denoise(i,j)=cnt_addpixel_denoise(i,j)+1;
                        end
                    end
                   if(ME_results(1,t+1,3)>=ME_x-D && ME_results(1,t+1,3)<=ME_x+D && ME_results(2,t+1,3)<=ME_y-D && ME_results(2,t+1,3)>=ME_y+D)
                        if(CHI_Maps_after(i,j,t+1)<K_th)
                            img_result_rank_denoise(i,j)=img_result_rank_denoise(i,j)+imgs_after(i,j,t+1);
                            cnt_addpixel_denoise(i,j)=cnt_addpixel_denoise(i,j)+1;
                        end
                    end
                end
                
                
            end
        end
        
        % runk_num=1で最小値選択
        for i=1:SIZE(1)
            for j=1:SIZE(2)
                for r=1:rank_num
                    w_tmp_rank_onlycurrent=exp(double(-CHI_Maps_onlycurrent(i,j,rank_order_onlycurrent(i,j,r)))/sigma_chi_rank);
                    img_result_rank_onlycurrent(i,j)=img_result_rank_onlycurrent(i,j)+w_tmp_rank_onlycurrent*imgs_onlycurrent(i,j,rank_order_onlycurrent(i,j,r));
                    w_total_rank_onlycurrent(i,j)=w_total_rank_onlycurrent(i,j)+w_tmp_rank_onlycurrent;
                end
            end
        end
        
        for i=1:SIZE(1)
            for j=1:SIZE(2)
                for t=0:rank_num
                    w_tmp_rank_onlycurrent=exp(double(-CHI_Maps_onlycurrent(i,j,rank_order_onlycurrent(i,j,r)))/sigma_chi_rank);
                    img_result_rank_onlycurrent(i,j)=img_result_rank_onlycurrent(i,j)+w_tmp_rank_onlycurrent*imgs_onlycurrent(i,j,rank_order_onlycurrent(i,j,r));
                    w_total_rank_onlycurrent(i,j)=w_total_rank_onlycurrent(i,j)+w_tmp_rank_onlycurrent;
                end
            end
        end
        
       %% 正規化
        img_min=img_result_rank;
        img_min_currentonly=img_result_rank_onlycurrent./w_total_rank_onlycurrent;
        img_result_rank_denoise=img_result_rank_denoise./cnt_addpixel_denoise;
        
       %% むだ
        Img_future_work= zeros(SIZE);
        cnt_addpixel=ones(SIZE);
        
        for i=1:SIZE(1)
            for j=1:SIZE(2)
                Img_future_work(i,j)=imgs(i,j,rank_order(i,j,r));
                dff_CHI_before=CHI_Maps(i,j,rank_order(i,j,r))-CHI_Maps_before(i,j,rank_order_before(i,j,r));
                dff_CHI_after=CHI_Maps(i,j,rank_order(i,j,r))-CHI_Maps_after(i,j,rank_order_after(i,j,r));
                if(dff_CHI_before>th_dff)
                    Img_future_work(i,j)=imgs_before(i,j,rank_order_before(i,j,r));
                end
                if(dff_CHI_after>th_dff)
                    if(dff_CHI_after>dff_CHI_before)
                        Img_future_work(i,j)=imgs_after(i,j,rank_order_after(i,j,r));
                    end
                end
                for t=1:Loop_Num
                    %% current
                    if(CHI_Maps(i,j,t)<K_th)
                        Img_future_work(i,j)=Img_future_work(i,j)+imgs(i,j,t);
                        cnt_addpixel(i,j)=cnt_addpixel(i,j)+1;
                    end
                 %% zengo
                    %   if(CHI_Maps_before(i,j,t)<K_th)
                    %   Img_future_work(i,j)=Img_future_work(i,j)+imgs_before(i,j,t);
                    %                         cnt_addpixel(i,j)=cnt_addpixel(i,j)+1;
                    %                     end
                    %
                    %                     if(CHI_Maps_after(i,j,t)<K_th)
                    %                         Img_future_work(i,j)=Img_future_work(i,j)+imgs_after(i,j,t);
                    %                         cnt_addpixel(i,j)=cnt_addpixel(i,j)+1;
                    %   end
                end
            end
        end
        Img_future_work=Img_future_work./cnt_addpixel;
        %       figure('Name','Future_works')
        %       imshow(uint8(Img_future_work))
        Img_future_work_currentonly= img_min_currentonly;
        cnt_addpixel_currentonly=ones(SIZE);
        
        for i=1:SIZE(1)
            for j=1:SIZE(2)
                for t=1:Loop_Num
                    if(CHI_Maps_onlycurrent(i,j,t)<K_th)
                        Img_future_work_currentonly(i,j)=Img_future_work_currentonly(i,j)+imgs_onlycurrent(i,j,t);
                        cnt_addpixel_currentonly(i,j)=cnt_addpixel_currentonly(i,j)+1;
                    end
                end
            end
        end
        Img_future_work_currentonly=Img_future_work_currentonly./cnt_addpixel_currentonly;
    end
    imshow(uint8(img_min))
%     imwrite(uint8(img_min),['../Images/Output/',Obj,'/movie_frame_zengo/frame',num2str(cnt,'%03u'),'.png'])
%     imwrite(uint8(img_min_currentonly),['../Images/Output/',Obj,'/movie_frame_only/frame',num2str(cnt,'%03u'),'.png'])
%     imwrite(uint8(img_result_rank_denoise),['../Images/Output/',Obj,'/movie_frame_denoising/frame',num2str(cnt,'%03u'),'.png'])
end