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
for t=1:10
    for Mov_tmp=10:10
        
        %% parameter ME Prop.
        down_sample_rate=0;
        Range_x=[0 0 4]; %[start end] ���� range_x=[-40 40 4]; dolfine car_bus bird
        %Range_y=[-20 20 1]; %range_y=[-20 20 4]; dolfin car_bus bird
        Range_y=[-Mov_tmp-10 Mov_tmp+10 1];
        Range_rotate=[0 0 2]; %�Ȃ�
        Range_scale=[0 0 10]; %�Ȃ�
        
        %% Image Gen
        Back_color=100;
        Obj_color_back=200;
        Obj_color_target=200;
        Obj_Back_Size=[100 100];
        %Obj_Target_Size=[80 80]; %���� Resolution���莞�C�p�����[�^
        Mov_back=[Mov_tmp 0];
        %Mov_target=[10 0];
        Mov_target=[0 0];
        %% Iterative Loop Num
        T_LOOP=1;  %���� Resolution���莞�C1
        
        %% Resotion Cul
        Map_update_Step=0.5; %���� Resolution���莞�C�p�����[�^
        
        %% Map Update
        Down_Sample_Rate_MapUpdate=0;
        K_sigmoid_centor=10;
        %STEP_sigmoid=0.5; %���� Resolution���莞�CMap�w��̂��߃R�����g�A�E�g
        K_DIV=0.5; %����0.5�͂ق�臒l����
        
        %%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cnt_excel_seet=0;
        for Obj_Target_Size_tmp=10:10:100
            cnt_excel_seet=cnt_excel_seet+1;
            Obj_Target_Size=[Obj_Target_Size_tmp Obj_Target_Size_tmp];
            %Measurement_Excel(cnt_obj_size+1,1)=Obj_Target_Size_tmp; % CSV
            Measurement_Excel(t+1,1,cnt_excel_seet)=Obj_Target_Size_tmp; % CSV
            
            cnt_Map_step=0; % Count Initialize
            for Map_update_Step_inv=0:0.1:1
                dsp=[Mov_tmp Obj_Target_Size_tmp Map_update_Step_inv]
                cnt_Map_step=cnt_Map_step+1;
                
                Measurement_Excel(1,cnt_Map_step+1,cnt_excel_seet)=Map_update_Step_inv; % CSV
                
                Map_update_Step=Map_update_Step_inv;
                Heat_map=ones(SIZE); % Heatmap Initialize
                %%%%%%%%%ImageGen%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [Imgs]=Function_TOP_ResolutionCulculate_ImgGen(SIZE,output_subframe_number,Obj_Back_Size,Obj_Target_Size,Mov_back,Mov_target,Back_color,Obj_color_back,Obj_color_target);
                %%%%%%%%%bitplane����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                DC_rate=0; % DC_rate =>Dark Count Rate
                [bitplanes]=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);
                
                %tmp=Function_Reconstruction_SUM(bitplane);
                %imshow(uint8(tmp))
                
                %%%%%%%%% Iterative MC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Error_min=realmax;
                for i=0:T_LOOP
                    %figure
                    %% ���������E���i�̂�
                    [tmp_bitplane,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,down_sample_rate);
                    %% ROI Map Update
                    
                    [chi_2D]=Function_Module_Chi2MapCul(tmp_bitplane,Down_Sample_Rate_MapUpdate);
                    chi_2D=imresize(chi_2D,SIZE,'bicubic');
                    
                    %%%%%%%%%%%%%%% �t�V�O���C�h %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                Measurement_Excel(t+1,cnt_Map_step+1,cnt_excel_seet)=Error_min;
                csvwrite(['../csv/tmp/ObjSize',num2str(Obj_Target_Size_tmp),'_ObjSize_vs_HeatMapWeight_Mov10.csv'],Measurement_Excel(:,:,cnt_excel_seet));
            end
        end
    end
end

%%%%%%%%%%%%% Main St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%