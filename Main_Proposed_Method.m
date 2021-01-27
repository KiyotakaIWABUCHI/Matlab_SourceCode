clear
close all
mode=1; %mode0:bitlpane gen %mode1:bitplane load
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=32; %number of bitplane image
max_photon_number=1;       %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                        %threashold
alpha=1.0; %0.4               %paramater for contralling incident photon
block_size_MLE=10;
%SIZE=[720 1280];
SIZE=[512 512]*2;
%SIZE=[1080 1920];
%% parameter ME Prop.
down_sample_rate=2;
Down_Sample_Rate_Grav=2;
%Range_x=[-200 200 8]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird /traffic[-52 52 4]
%Range_y=[-120 120 8]; %range_y=[-20 20 4]; dolfin car_bus bird eagle -50 50 /traffic[-20 20 4] airplane_bridge -50*2 50*2 4
%Range_rotate=[-0 0 2]; %なし eagle -20 20
%Range_scale=[0 0 10]; %なし

%% Iterative Loop Num
T_LOOP=10;
n=output_subframe_number/2;
%% Map Update
Down_Sample_Rate_MapUpdate=1;
K_sigmoid_centor=18.47;
%K_sigmoid_centor=11.345;
%K_sigmoid_centor=30.58;
STEP_sigmoid=0.25; %注意 Resolution測定時，Map指定のためコメントアウト
K_DIV=0.5; %注意0.5はほぼ閾値判定
T=50;
Intv_frame_r=16;
Intv_frame=(output_subframe_number-1)/2;
%% Read Images
frame_cnt=0;
Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
if(mode==0)
    [status, msg, msgID] = mkdir(['../Images/Output/test_proposed/bitplanes']);
    Img_set=zeros(SIZE(1),SIZE(2),60);
    DC_rate=0;
    for f=1:12
        f
        for t=1:60
            %tmp=rgb2gray(imread(['../Images/Input/3dsmax_long_movie/airplane_bridge_frame',pad(num2str(t-1+60*(f-1)),4,'left','0'),'.png']));
            tmp=rgb2gray(imread(['../Images/Input/3dsmax_airplane_heri/airplane_heri_frame',pad(num2str(t-1+60*(f-1)),4,'left','0'),'.png']));
            Img_set(:,:,t)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
        end
        [bitplane,Incident_photons]=Function_BitplaneGen(Img_set,size(Img_set,3),max_photon_number,min_photon_number,q,alpha,DC_rate);
        for t=1:60
            imwrite(uint8(bitplane(:,:,t)*255),['../Images/Output/test_proposed/bitplanes/frame',pad(num2str(t-1+60*(f-1)),4,'left','0'),'.png'])
        end
    end
end

for r=1:T
    [status, msg, msgID] = mkdir(['../Images/Output/test_proposed/time',num2str(r)]);
    for f=1:3
        
        [status, msg, msgID] = mkdir(['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f)]);
        Imgs=zeros(SIZE(1),SIZE(2),output_subframe_number);
        bitplanes=zeros(SIZE(1),SIZE(2),output_subframe_number);
        disp('image_reading_now...')
        for t_tmp=1:output_subframe_number
            num_f_tmp=t_tmp-1+floor(Intv_frame*(f-1));
            num_f=num_f_tmp*4+Intv_frame_r*(r-1);
            if(frame_cnt==0)
                first_frame_num=num_f;
            else
                last_frame_num=num_f;
            end
            
            %tmp=rgb2gray(imread(['../Images/Input/3dsmax_long_movie/airplane_bridge_frame',pad(num2str(num_f),4,'left','0'),'.png']));
            tmp=rgb2gray(imread(['../Images/Input/3dsmax_airplane_heri/airplane_heri_frame',pad(num2str(num_f),4,'left','0'),'.png']));
            bitplane_tmp=double((imread(['../Images/Output/test_proposed/bitplanes/frame',pad(num2str(num_f),4,'left','0'),'.png'])))/255;
            %tmp=rgb2gray(imread(['D:/Input/frames2/frame_',pad(num2str(t_tmp-1+Intv_frame*(f-1)),4,'left','0'),'.bmp']));
            Imgs(:,:,t_tmp)=imresize(tmp(1:end,1:end),SIZE,'bicubic');
            bitplanes(:,:,t_tmp)=(bitplane_tmp); %仮
            %imshow(tmp)
            frame_cnt=frame_cnt+1;
        end
        bitplane_range=[first_frame_num last_frame_num];
        save(['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f),'/bitplane_range'],'bitplane_range')
        disp('bitplane_generating_now...')
        DC_rate=0; % DC_rate =>Dark Count Rate
        [non,Incident_photons]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
        save(['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f),'/Original_bitplanes'],'bitplanes')
        save(['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f),'/Incident_photons'],'Incident_photons')
        disp('iterativecycle_now...')
        Re_img=Function_Reconstruction_MLE_Oversample(bitplanes,alpha,q,5);
        imshow(uint8(Re_img))
        imwrite(uint8(Re_img),['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f),'/Re_img_blur.png'])
        %% test
        M=4;
        Downsample=3;
        [chi_2D]=Function_Module_Chi2MapCul_Mpixel(bitplanes,Downsample,M);
        chi_2D=imresize(chi_2D,SIZE,'bicubic');
        %figure
        imshow(uint8(chi_2D>K_sigmoid_centor)*255)
        %%
        Heat_map=ones(SIZE); % Heatmap Initialize
        ME_Result=zeros(SIZE(1),SIZE(2),2);
        for i=0:T_LOOP-1
            %% 出力
            imwrite(uint8(Heat_map*255),['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f),'/IterativeHeatMap_',num2str(i+1),'times.png'])
            %     save(['../Images/Output/test_movie/HeatMap_',num2str(i+1),'times_bitplaneStyle'],'Heat_map')
            %% 高速化時・並進のみ
            N_Pyramid=4;
            Range_x=[-4 4 1];
            Range_y=[-1 1 1];
            N_sort=1;
            
            [bitplane_MC,Estimation_x,Estimation_y]=Function_Pyramidal_ME_top(bitplanes,Range_x,Range_y,Heat_map,n,M,N_Pyramid,N_sort);
            bitplane_shifted=Function_ShiftBitplane_Selective_Refframe(bitplanes,Estimation_x(1),Estimation_y(1),n);
            Re_img=Function_Reconstruction_MLE_Oversample(bitplane_shifted,alpha,q,5);
            imshow(uint8(Re_img))
            %[bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,Downsample,n,M);
            %% 並進＋回転・拡大あり
            %         O_obj=Function_ObjGrav_Cul(bitplanes,Down_Sample_Rate_Grav);
            %         [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap_ROTATE_CentorTime(bitplanes,Range_x,Range_y,Range_scale,Range_rotate,O_obj,Heat_map,down_sample_rate,n);
            %% ROI Map Update
            [chi_2D]=Function_Module_Chi2MapCul_Mpixel(bitplane_shifted,Downsample,M);
            %[chi_2D]=Function_Module_Chi2MapCul(bitplane_MC,Down_Sample_Rate_MapUpdate);
            chi_2D=imresize(chi_2D,SIZE,'bicubic');
            %%%%%%%%%%%%%%% 逆シグモイド %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %sigmoid=(ones(size(chi_2D))./(1+exp(-(chi_2D-K_sigmoid_centor)/K_DIV)));
            Heat_map=Heat_map-STEP_sigmoid*double((K_sigmoid_centor>chi_2D));
            Heat_map=double(Heat_map>=0).*Heat_map;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% 出力
            ME_Result(:,:,1)=Estimation_x(1);
            ME_Result(:,:,2)=Estimation_y(1);
            save(['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f),'/IterativeOutput_',num2str(i+1),'times_bitplaneStyle'],'bitplane_shifted')
            save(['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f),'/Iterative_ME_Result_',num2str(i+1),'times'],'ME_Result')
            imwrite(uint8(Re_img),['../Images/Output/test_proposed/time',num2str(r),'/set',num2str(f),'/IterativeOutput_',num2str(i+1),'times.png'])
        end
    end
end
