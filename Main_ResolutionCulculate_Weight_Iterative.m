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

%% parameter ME Prop.
blocksize_estimation=4;
kernel_T_estimation=8;
range_x=[0 0 4]; %[start end] 刻み range_x=[-40 40 4]; dolfine car_bus bird
range_y=[-40 40 1]; %range_y=[-20 20 4]; dolfin car_bus bird
range_rotate=[0 0 2]; %なし
range_scale=[0 0 10]; %なし

%% Image Gen
Back_color=100;
Obj_color_back=200;
Obj_color_target=200;
Obj_Back_Size=[100 100];
Obj_Target_Size=[80 80];
Mov_back=[0 0];
Mov_target=[10 0];

%% Iterative Loop Num
T_LOOP=1;

%%

%%%%%%%%%%%%% Initializes Ed%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%ImageGen%%%%%%%%%%%%%%%%%%%%%
[Imgs]=Function_TOP_ResolutionCulculate_ImgGen(SIZE,output_subframe_number,Obj_Back_Size,Obj_Target_Size,Mov_back,Mov_target,Back_color,Obj_color_back,Obj_color_target);
%%%%%%%%%bitplane生成%%%%%%%%%%%%%%%%%%
DC_rate=0; % DC_rate =>Dark Count Rate 
bitplane=Function_BitplaneGen(Imgs,output_subframe_number,max_photon_number,min_photon_number,q,alpha,DC_rate);

%tmp=Function_Reconstruction_SUM(bitplane);
%imshow(uint8(tmp))

%%
Diff_kousin_Step=0.5;
for i=0:T_LOOP
    %% ME
   figure
   imshow(uint8(weight_map)*255)
   
   figure
   %% 高速化時・並進のみ
   [tmp_bitplane,estimation_x,estimation_y]=function_weight_balance_ME(bitplane,range_x,range_y,weight_map);
   %% MD
    if(down_samplerate==0)
        leveled_bitplane=tmp_bitplane;
    else
        [leveled_bitplane]=function_downsumple_bitplane(tmp_bitplane,down_samplerate);
    end
    [chi_2D]=function_motion_estimation_chai(leveled_bitplane,2^(down_samplerate));
    chi_2D=imresize(chi_2D,SIZE,'bicubic');
    for d=1:8
        chi_2D=medfilt2(chi_2D);
    end

    %% 逆シグモイド
    K_sigmoid_centor=10;
    %STEP_sigmoid=0.5; %注意
    K_DIV=0.5; %0.5
    sigmoid=(ones(size(chi_2D))./(1+exp(-(chi_2D-K_sigmoid_centor)/K_DIV)));
    weight_map=weight_map-Diff_kousin_Step*(1-sigmoid);
    weight_map=double(weight_map>=0).*weight_map;
   
    
    %% Chi_2D cul
    down_samplerate_mix=2;
    if(down_samplerate_mix==0)
        leveled_bitplane=tmp_bitplane;
    else
        [leveled_bitplane]=function_downsumple_bitplane(tmp_bitplane,down_samplerate_mix);
    end
    [chi_2D]=function_motion_estimation_chai(leveled_bitplane,2^(down_samplerate_mix));
    chi_2D=imresize(chi_2D,SIZE,'bicubic');
    for d=1:7
        chi_2D=medfilt2(chi_2D);
    end
end
