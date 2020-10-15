clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=1;      %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                     %threashold
alpha=1; %0.4                    %paramater for contralling incident photon
block_size_MLE=10;
SIZE=[256 256];
Measurement_Excel=zeros(1,1,1);
for t=1:100
    for Mov_tmp=10:10
        
        %% parameter ME Prop.
        down_sample_rate=0;
        Range_x=[0 0 4]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird
        %Range_y=[-20 20 1]; %range_y=[-20 20 4]; dolfin car_bus bird
        Range_y=[-Mov_tmp-10 Mov_tmp+10 1];
        Range_y_ans=[Mov_tmp Mov_tmp 1];
        Range_rotate=[0 0 2]; %なし
        Range_scale=[0 0 10]; %なし
        
        %% Image Gen
        Back_color=50;
        Obj_Back_Size=[100 100];
        %Obj_Target_Size=[80 80]; %注意 Resolution測定時，パラメータ
        Mov_back=[0 0];
        %Mov_target=[10 0];
        Mov_target=[Mov_tmp 0];
        Map_update_Step_inv_array=[(1-0.25) (1-0.5) (1-0.75) 0.01];
        %% Iterative Loop Num
        T_LOOP=1;  %注意 Resolution測定時，1
        
        %% Resotion Cul
        Map_update_Step=0.5; %注意 Resolution測定時，パラメータ
        
        %% Map Update
        Down_Sample_Rate_MapUpdate=0;
        K_sigmoid_centor=10;
        %STEP_sigmoid=0.5; %注意 Resolution測定時，Map指定のためコメントアウト
        K_DIV=0.5; %注意0.5はほぼ閾値判定
        
        %%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cnt_excel_seet=0;
        for Obj_Target_Size_tmp=0:4:20
            cnt_excel_seet=cnt_excel_seet+1;
            Obj_color_back=150;
            Obj_color_target=150;
            Obj_color_Texture_width=Obj_Target_Size_tmp;
            Obj_Target_Size=[50 50];
            %Measurement_Excel(cnt_obj_size+1,1)=Obj_Target_Size_tmp; % CSV
            Measurement_Excel(t+1,1,cnt_excel_seet)=Obj_color_Texture_width; % CSV
            
           %% シーン&評価用bit-planeせいせい
            [Imgs,RoIMap]=Function_TOP_ResolutionCulculate_Texture_ImgGen(SIZE,output_subframe_number,Obj_Back_Size,Obj_Target_Size,Mov_back,Mov_target,Back_color,Obj_color_back,Obj_color_target,Obj_color_Texture_width);
            imshow(uint8(RoIMap*255))
            DC_rate=0; % DC_rate =>Dark Count Rate
            [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
            [chi_2D_origin]=Function_Module_Chi2MapCul(bitplanes,Down_Sample_Rate_MapUpdate);
            chi_2D_origin=chi_2D_origin.*double(chi_2D_origin>K_sigmoid_centor);
            target_chi=sum(sum(RoIMap.*chi_2D_origin));
            Range_y_ans=[Mov_tmp Mov_tmp 1];
            [bitplane_ans]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y_ans,ones(SIZE),down_sample_rate);
            [chi_2D_ans]=Function_Module_Chi2MapCul(bitplane_ans,Down_Sample_Rate_MapUpdate);
            chi_2D_ans=chi_2D_ans.*double(chi_2D_ans>K_sigmoid_centor);
            back_chi=sum(sum((1-RoIMap).*chi_2D_ans));       
            Measurement_Excel(t+1,2,cnt_excel_seet)=target_chi; % CSV
            Measurement_Excel(t+1,3,cnt_excel_seet)=back_chi; % CSV
            %%   
            cnt_Map_step=2; % Count Initialize
            for Map_update_Step_inv_cnt=1:size(Map_update_Step_inv_array,2)
                Map_update_Step_inv=Map_update_Step_inv_array(Map_update_Step_inv_cnt);
                dsp=[t Mov_tmp Obj_Target_Size_tmp 1/Map_update_Step_inv]
                cnt_Map_step=cnt_Map_step+1;
                Measurement_Excel(1,cnt_Map_step+1,cnt_excel_seet)=1/Map_update_Step_inv; % CSV
                Map_update_Step=Map_update_Step_inv;
                Heat_map=ones(SIZE); % Heatmap Initialize
                %%%%%%%%% Iterative MC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Error_min=realmax;
                for i=0:0
                    %figure
                    %% 高速化時・並進のみ
                    Heat_map=(1-RoIMap)*Map_update_Step_inv+RoIMap;
                    [tmp_bitplane,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,down_sample_rate);
                    %% ROI Map Update
                    
                    
                    [chi_2D]=Function_Module_Chi2MapCul(tmp_bitplane,Down_Sample_Rate_MapUpdate);
                    chi_2D=imresize(chi_2D,SIZE,'bicubic');
                    
                    %%%%%%%%%%%%%%% 逆シグモイド %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %sigmoid=(ones(size(chi_2D))./(1+exp(-(chi_2D-K_sigmoid_centor)/K_DIV)));
                    %Heat_map=Heat_map-Map_update_Step*(1-sigmoid);
                    %Heat_map=Heat_map-(1-RoIMap)*(Map_update_Step_inv);
                    %Heat_map=double(Heat_map>=0).*Heat_map;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Heat_map=Heat_map-(1-RoIMap)*(Map_update_Step_inv);
%                     imshow(uint8(Heat_map*255))
                    
                    Error=sum(abs(Mov_target-[Estimation_y Estimation_x]));
                    if(Error_min>Error)
                        Error_min=Error;
                    end
                end
                
                %%% Measurement Result %%%%%%%%%%%%%
                Measurement_Excel(t+1,cnt_Map_step+1,cnt_excel_seet)=Error_min;
                %csvwrite(['../csv/IEEE/IEEE20200911_ObjSize',num2str(Obj_Target_Size_tmp),'_ObjSize_vs_HeatMapWeight_Mov10.csv'],Measurement_Excel(:,:,cnt_excel_seet));
            end
        end
    end
    save(['../csv/IEEE/Resolution_array_Chiaxis_TextureWidth_over10_4param'],'Measurement_Excel')
end
%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%