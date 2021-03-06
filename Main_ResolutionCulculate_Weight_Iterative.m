clear
close all
%%%%%%%%%%%%% Initializes St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Garamater Public
output_subframe_number=256; %number of bitplane image
max_photon_number=10;      %Max number of total incident photon
min_photon_number=0;        %Min number of total incident photon
q=1;                     %threashold
alpha=2; %0.4                    %paramater for contralling incident photon
block_size_MLE=10;
SIZE=[256 256];
Measurement_Excel=zeros(1,1,1);
for t=1:1
    cnt_excel_seet=0;
    for Mov_tmp=10:10:30
        cnt_excel_seet=cnt_excel_seet+1;
        %% parameter ME Prop.
        down_sample_rate=0;
        Range_x=[0 0 4]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird
        %Range_y=[-20 20 1]; %range_y=[-20 20 4]; dolfin car_bus bird
        Range_y=[-Mov_tmp-10 Mov_tmp+10 1];
        Range_rotate=[0 0 2]; %なし
        Range_scale=[0 0 10]; %なし
        
        %% Image Gen
        Back_color=100;
        Obj_color_back=200;
        Obj_color_target=200;
        Obj_Back_Size=[100 100];
        %Obj_Target_Size=[80 80]; %注意 Resolution測定時，パラメータ
        Mov_back=[Mov_tmp 0];
        %Mov_target=[10 0];
        Mov_target=[0 0];
        %% Iterative Loop Num
        T_LOOP=1;  %注意 Resolution測定時，1
        
        %% Resotion Cul
        Map_update_Step=0.5; %注意 Resolution測定時，パラメータ
        
        %% Map Update
        Down_Sample_Rate_MapUpdate=1;
        K_sigmoid_centor=10;
        %STEP_sigmoid=0.5; %注意 Resolution測定時，Map指定のためコメントアウト
        K_DIV=0.5; %注意0.5はほぼ閾値判定
        
        %%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cnt_obj_size=0; % Count Initialize
        for Obj_Target_Size_tmp=50:50
            cnt_obj_size=cnt_obj_size+1;
            Obj_Target_Size=[Obj_Target_Size_tmp Obj_Target_Size_tmp];
            %Measurement_Excel(cnt_obj_size+1,1)=Obj_Target_Size_tmp; % CSV
            Measurement_Excel(cnt_obj_size+t,1,cnt_excel_seet)=Obj_Target_Size_tmp; % CSV
            
            cnt_Map_step=0; % Count Initialize
            for Map_update_Step_inv=0.5:0.5
                dsp=[Mov_tmp Obj_Target_Size_tmp Map_update_Step_inv]
                cnt_Map_step=cnt_Map_step+1;
                
                Measurement_Excel(1,cnt_Map_step+1,cnt_excel_seet)=Map_update_Step_inv; % CSV
                
                Map_update_Step=Map_update_Step_inv;
                Heat_map=ones(SIZE); % Heatmap Initialize
                %%%%%%%%%ImageGen%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [Imgs]=Function_TOP_ResolutionCulculate_ImgGen(SIZE,output_subframe_number,Obj_Back_Size,Obj_Target_Size,Mov_back,Mov_target,Back_color,Obj_color_back,Obj_color_target);
                %%%%%%%%%bitplane生成%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                DC_rate=0; % DC_rate =>Dark Count Rate
                [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
                
                %tmp=Function_Reconstruction_SUM(bitplane);
                %imshow(uint8(tmp))
                
                %%%%%%%%% Iterative MC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Error_min=realmax;
                for i=0:T_LOOP
                    %figure
                    %% 高速化時・並進のみ
                    [tmp_bitplane,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,down_sample_rate);
                    %% ROI Map Update
                    
                    [chi_2D]=Function_Module_Chi2MapCul(tmp_bitplane,Down_Sample_Rate_MapUpdate);
                    chi_2D=imresize(chi_2D,SIZE,'bicubic');
                    
                    %%%%%%%%%%%%%%% 逆シグモイド %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    imwrite(uint8(Heat_map*255),['../Images/Output/Resolution_HeatMap/HeatMap_Mov',num2str(Mov_tmp),'.png'])
                    sigmoid=(ones(size(chi_2D))./(1+exp(-(chi_2D-K_sigmoid_centor)/K_DIV)));
                    Heat_map=Heat_map-Map_update_Step*(1-sigmoid);
                    Heat_map=double(Heat_map>=0).*Heat_map;
                   
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    Error=sum(abs(Mov_target-[Estimation_y Estimation_x]));
                    if(Error_min>Error)
                        Error_min=Error;
                    end
                end
                
                %%% Measurement Result %%%%%%%%%%%%%
                Measurement_Excel(cnt_obj_size+t,cnt_Map_step+1,cnt_excel_seet)=Error_min;
                %csvwrite(['../csv/tmp/Mov',num2str(Mov_tmp),'_Mov_vs_HeatMapWeight_ObjStop.csv'],Measurement_Excel(:,:,cnt_excel_seet));
            end
        end
    end
end

%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%