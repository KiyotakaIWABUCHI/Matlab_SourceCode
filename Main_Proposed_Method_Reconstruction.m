clear
close all
%% paramater(all)
q=1;                     %threashold
alpha=1; %0.4                    %paramater for contralling incident photon
%SIZE=[512 512];
%SIZE=[720 1280];
SIZE=[512 512]*2;
Num_bitplanes=32;
%%
sigma_chi=2;
%% chi update ver param
K=13;
%% important param
Output_MLE_K=3; %default5
M=4;
K_birateral=1000;
Downsample_chi=2; %default3
K_zengo=10.00; %調節param
K_denoise=18.47; %調節param
Motion_filter=0;
%%
K_th=10.00; %50
K_th_noninst=30.00; %10
D=2;
K_th_denoise=30;
%% Rank Min reconst param
rank_num=1;
%% Previously Heatmap param
Th_HeatMap=0.0;
%%
K_MLE=3;
K_birateral_CIS=1000;
Loop_Num=10;
Set=3;
T=50;
%%
CIS_readnoise=5;
%% Obj Selection
%% こっち
Obj='test_proposed'
[status, msg, msgID] = mkdir(['../Images/Output/',Obj,'/Re_img_blur']);
[status, msg, msgID] = mkdir(['../Images/Output/',Obj,'/Re_img_only']);
[status, msg, msgID] = mkdir(['../Images/Output/',Obj,'/Re_img_zengo']);
[status, msg, msgID] = mkdir(['../Images/Output/',Obj,'/Re_img_denoise']);
[status, msg, msgID] = mkdir(['../Images/Output/',Obj,'/Re_img_Motionfilter_denoise']);
[status, msg, msgID] = mkdir(['../Images/Output/',Obj,'/Re_img_Motionfilter_deblur']);
[status, msg, msgID] = mkdir(['../Images/Output/',Obj,'/Re_CIS_long']);
[status, msg, msgID] = mkdir(['../Images/Output/',Obj,'/Re_CIS_short']);
for r=1:T
    r
    for f=2:2
        ME_results=zeros(2,Loop_Num,Set);
        bitplanes_all=zeros(SIZE(1),SIZE(2),Num_bitplanes,3);
        
        %         ADbit=10;
        %         Full_well=20000;
        %         BitWidth=(Full_well/2^ADbit);
        load(['../Images/Output/',Obj,'/time',num2str(r),'/set',num2str(f),'/Incident_photons']);
        CIS_output=sum(Incident_photons,3)+poissrnd(ones(SIZE)*CIS_readnoise);
        CIS_output=mat2gray(CIS_output)*255;
        CIS_img=imboxfilt(CIS_output,K_MLE);
        CIS_img_long = imresize(imbilatfilt(CIS_img, K_birateral_CIS),SIZE,'bicubic');
        CIS_img_long=mat2gray(CIS_img_long)*255;
        CIS_output=sum(Incident_photons(:,:,1:Num_bitplanes/8),3)+poissrnd(ones(SIZE)*CIS_readnoise);
        CIS_output=mat2gray(CIS_output)*255;
        CIS_img=imboxfilt(CIS_output,K_MLE);
        CIS_img_short = imresize(imbilatfilt(CIS_img, K_birateral_CIS),SIZE,'bicubic');
        CIS_img_short=mat2gray(CIS_img_short)*255;
        imshow(uint8(CIS_img_long))

        %         AD_result=zeros(SIZE);
        %         for ad=1:2^ADbit
        %             AD_result=AD_result+double(CIS_output>ad*BitWidth);
        %         end
        %         AD_result=imboxfilt(AD_result,Output_MLE_K);
        %         CIS_img=mat2gray(AD_result)*255;
        %         CIS_img = imbilatfilt(CIS_img, K_birateral);
        %         imshow(uint8(CIS_img))
        
        for s=1:3
            for i=0:Loop_Num-1
                load(['../Images/Output/',Obj,'/time',num2str(r),'/set',num2str(f+s-2),'/Iterative_ME_Result_',num2str(i+1),'times']);
                ME_results(1,i+1,s)=mean(mean(ME_Result(:,:,1)));
                ME_results(2,i+1,s)=mean(mean(ME_Result(:,:,2)));
            end
            load(['../Images/Output/',Obj,'/time',num2str(r),'/set',num2str(f+s-2),'/Original_bitplanes']);
            bitplanes_all(:,:,:,s)=bitplanes;
            if(s==2)
                img_blur=Function_Reconstruction_MLE_Oversample(bitplanes,alpha,q,Output_MLE_K);
                img_blur = imbilatfilt(img_blur,K_birateral);
            end
        end
        bitplanes_all(:,:,Num_bitplanes/2+1:end,1)=bitplanes_all(:,:,1:Num_bitplanes/2,2);
        bitplanes_all(:,:,1:Num_bitplanes/2,3)=bitplanes_all(:,:,Num_bitplanes/2+1:end,2);
        Photon_level=sum(sum(sum(bitplanes)))/SIZE(1)/SIZE(2)/size(bitplanes,3);
        %%
        for s=2:2
            CHI_Maps=zeros(SIZE(1),SIZE(2),Loop_Num);
            CHI_Maps_before=zeros(SIZE(1),SIZE(2),Loop_Num);
            CHI_Maps_after=zeros(SIZE(1),SIZE(2),Loop_Num);
            CHI_Maps_onlycurrent=zeros(SIZE(1),SIZE(2),Loop_Num);
            imgs=zeros(SIZE(1),SIZE(2),Loop_Num);
            imgs_after=zeros(SIZE(1),SIZE(2),Loop_Num);
            imgs_before=zeros(SIZE(1),SIZE(2),Loop_Num);
            imgs_onlycurrent=zeros(SIZE(1),SIZE(2),Loop_Num);
            n=Num_bitplanes/2;
            for i=0:Loop_Num-1
                Motion_x_befor=ME_results(1,i+1,1);
                Motion_x=ME_results(1,i+1,2);
                Motion_x_after=ME_results(1,i+1,3);
                Motion_y_befor=ME_results(2,i+1,1);
                Motion_y=ME_results(2,i+1,2);
                Motion_y_after=ME_results(2,i+1,3);
                
                
                
                Sift_bitplane=Function_ShiftBitplane_Selective_Refframe(bitplanes_all(:,:,:,s),Motion_x,Motion_y,n);
                Sift_bitplane_before=Function_ShiftBitplane_Selective_Refframe(bitplanes_all(:,:,:,s-1),Motion_x_befor,Motion_y_befor,Num_bitplanes);
                Sift_bitplane_after=Function_ShiftBitplane_Selective_Refframe(bitplanes_all(:,:,:,s+1),Motion_x_after,Motion_y_after,1);
                
                
                [img]=Function_Reconstruction_MLE_Oversample(Sift_bitplane,alpha,q,Output_MLE_K);
                [img_before]=Function_Reconstruction_MLE_Oversample(Sift_bitplane_before,alpha,q,Output_MLE_K);
                [img_after]=Function_Reconstruction_MLE_Oversample(Sift_bitplane_after,alpha,q,Output_MLE_K);
                %
                %                                     figure('Name','current')
%                                                      imshow(uint8(img))
                %                                     figure('Name','befor')
                %                                     imshow(uint8(img_before))
                %                                     figure('Name','after')
                %                                     imshow(uint8(img_after))
                %             %
                imgs_onlycurrent(:,:,i+1)=double(img);
                imgs(:,:,(i+1))=double(img);
                imgs_before(:,:,(i+1))=double(img_before);
                imgs_after(:,:,(i+1))=double(img_after);
                
                
                
                [chi_2D]=Function_Module_Chi2MapCul_Mpixel(Sift_bitplane,Downsample_chi,M);
                chi_2D=imresize(chi_2D,SIZE,'bicubic');
                chi_2D =imboxfilt(chi_2D,K);
                CHI_Maps(:,:,(i+1))=chi_2D;
                CHI_Maps_onlycurrent(:,:,i+1)=chi_2D;
                [chi_2D]=Function_Module_Chi2MapCul_Mpixel(Sift_bitplane_before,Downsample_chi,M);
                chi_2D=imresize(chi_2D,SIZE,'bicubic');
                chi_2D =imboxfilt(chi_2D,K);
                CHI_Maps_before(:,:,(i+1))=chi_2D;
                [chi_2D]=Function_Module_Chi2MapCul_Mpixel(Sift_bitplane_after,Downsample_chi,M);
                chi_2D=imresize(chi_2D,SIZE,'bicubic');
                chi_2D =imboxfilt(chi_2D,K);
                CHI_Maps_after(:,:,(i+1))=chi_2D;
            end
            
            %% Reconstruction Min
            CHI_Maps_all=zeros([SIZE Loop_Num*3]);
            imgs_all=zeros([SIZE Loop_Num*3]);
            CHI_Maps_all(:,:,1:Loop_Num)=CHI_Maps;
            CHI_Maps_all(:,:,Loop_Num+1:2*Loop_Num)=CHI_Maps_before;
            CHI_Maps_all(:,:,2*Loop_Num+1:3*Loop_Num)=CHI_Maps_after;
            imgs_all(:,:,1:Loop_Num)=imgs;
            imgs_all(:,:,Loop_Num+1:2*Loop_Num)=imgs_before;
            imgs_all(:,:,2*Loop_Num+1:3*Loop_Num)=imgs_after;
            [Chis_sort,rank_order]=sort(CHI_Maps,3);
            [Chis_sort,rank_order_before]=sort(CHI_Maps_before,3);
            [Chis_sort,rank_order_after]=sort(CHI_Maps_after,3);
            [Chis_sort,rank_order_all]=sort(CHI_Maps_all,3);
            
            
            
            %% Rank
            img_result_rank=zeros(SIZE);
            img_result_rank_zengo=zeros(SIZE);
            cnt_denoise=ones(SIZE);
            cnt_denoise_motion_filt_deblur=ones(SIZE);
            cnt_denoise_motion_filt_denoise=ones(SIZE);
            
            for i=1:SIZE(1)
                for j=1:SIZE(2)
                    img_result_rank(i,j)=imgs(i,j,rank_order(i,j,1));
                end
            end
            imshow(uint8(img_result_rank))
            img_result_rank = imbilatfilt(img_result_rank,K_birateral);
            for i=1:SIZE(1)
                for j=1:SIZE(2)
                    
                    %if((CHI_Maps(i,j,rank_order(i,j,1))-CHI_Maps_all(i,j,rank_order_all(i,j,1)))>K_zengo)
                    if(CHI_Maps(i,j,rank_order(i,j,1))<K_zengo)
                        img_result_rank_zengo(i,j)=imgs(i,j,rank_order(i,j,1));
                    else
                        img_result_rank_zengo(i,j)=imgs_all(i,j,rank_order_all(i,j,1));
                    end
                end
            end
            % figure
            imshow(uint8(img_result_rank_zengo))
            img_result_rank_denoise = img_result_rank_zengo;
            img_result_rank_denoise_motion_filt_deblur = img_result_rank_zengo;
            img_result_rank_denoise_motion_filt_denoise  = img_result_rank_zengo;
            img_result_rank_zengo = imbilatfilt(img_result_rank_zengo,K_birateral);
          %% motion filter denoise
            K_denoise_motion=8;
            K_denoise_motion_denoise=15;
            K_denoise_motion_deblur=0;
            K_denoise_static=8;
            Motion_lower=35;
            Motion_upper=45;
            
            for i=1:SIZE(1)
                for j=1:SIZE(2)
                    for t=1:Loop_Num
                        Motion=sqrt(ME_results(1,rank_order(i,j,1),2)*ME_results(1,rank_order(i,j,1),2)+ME_results(2,rank_order(i,j,1),2)*ME_results(2,rank_order(i,j,1),2));
                        if(Motion>=Motion_lower && Motion<=Motion_upper)
                            if(CHI_Maps(i,j,t)<K_denoise_motion)
                                img_result_rank_denoise(i,j)=img_result_rank_denoise(i,j) + imgs(i,j,t);
                                cnt_denoise(i,j)=cnt_denoise(i,j)+1;
                            end
                         %% motion filter denoise
                             if(CHI_Maps(i,j,t)<K_denoise_motion_denoise)
                                img_result_rank_denoise_motion_filt_denoise(i,j)=img_result_rank_denoise_motion_filt_denoise(i,j) + imgs(i,j,t);
                                cnt_denoise_motion_filt_denoise(i,j)=cnt_denoise_motion_filt_denoise(i,j)+1;
                            end
                             %% motion filter deblur
                             if(CHI_Maps(i,j,t)<K_denoise_motion_deblur)
                                img_result_rank_denoise_motion_filt_deblur(i,j)=img_result_rank_denoise_motion_filt_deblur(i,j) + imgs(i,j,t);
                                cnt_denoise_motion_filt_deblur(i,j)=cnt_denoise_motion_filt_deblur(i,j)+1;
                            end
                        else
                            if(CHI_Maps(i,j,t)<K_denoise_static)
                                img_result_rank_denoise(i,j)=img_result_rank_denoise(i,j) + imgs(i,j,t);
                                cnt_denoise(i,j)=cnt_denoise(i,j)+1;
                                img_result_rank_denoise_motion_filt_denoise(i,j)=img_result_rank_denoise_motion_filt_denoise(i,j) + imgs(i,j,t);
                                cnt_denoise_motion_filt_denoise(i,j)=cnt_denoise_motion_filt_denoise(i,j)+1;
                                img_result_rank_denoise_motion_filt_deblur(i,j)=img_result_rank_denoise_motion_filt_deblur(i,j) + imgs(i,j,t);
                                cnt_denoise_motion_filt_deblur(i,j)=cnt_denoise_motion_filt_deblur(i,j)+1;
                            end
                        end
                    end
                end
            end
            img_result_rank_denoise=img_result_rank_denoise./cnt_denoise;
            img_result_rank_denoise_motion_filt_denoise=img_result_rank_denoise_motion_filt_denoise./cnt_denoise_motion_filt_denoise;
            img_result_rank_denoise_motion_filt_deblur=img_result_rank_denoise_motion_filt_deblur./cnt_denoise_motion_filt_deblur;
            img_result_rank_denoise = imbilatfilt(img_result_rank_denoise,K_birateral);
            img_result_rank_denoise_motion_filt_denoise = imbilatfilt(img_result_rank_denoise_motion_filt_denoise,K_birateral);
            img_result_rank_denoise_motion_filt_deblur = imbilatfilt(img_result_rank_denoise_motion_filt_deblur,K_birateral);
        end
%         imwrite(uint8(img_blur),['../Images/Output/test_proposed/Re_img_blur/frame',num2str(r,'%03u'),'.png'])
         imwrite(uint8(img_result_rank),['../Images/Output/test_proposed/Re_img_only/frame',num2str(r,'%03u'),'.png'])
         imwrite(uint8(img_result_rank_zengo),['../Images/Output/test_proposed/Re_img_zengo/frame',num2str(r,'%03u'),'.png'])
          imwrite(uint8(img_result_rank_denoise),['../Images/Output/test_proposed/Re_img_denoise/frame',num2str(r,'%03u'),'.png'])
%         imwrite(uint8(CIS_img_short),['../Images/Output/test_proposed/Re_CIS_short/frame',num2str(r,'%03u'),'.png'])
%         imwrite(uint8(CIS_img_long),['../Images/Output/test_proposed/Re_CIS_long/frame',num2str(r,'%03u'),'.png'])
          imwrite(uint8(img_result_rank_denoise_motion_filt_denoise),['../Images/Output/test_proposed/Re_img_Motionfilter_denoise/frame',num2str(r,'%03u'),'.png'])
          imwrite(uint8(img_result_rank_denoise_motion_filt_deblur),['../Images/Output/test_proposed/Re_img_Motionfilter_deblur/frame',num2str(r,'%03u'),'.png'])
    end
end

