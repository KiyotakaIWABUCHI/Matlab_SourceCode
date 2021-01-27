function[result_2D,levelM]=Function_Module_Chi2MapCul_Mpixel_Boxfilt(bitplane_origin,down_sample_rate,BoxK,M)

%%%%%%% Bitplane down Sampling %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% down_sample_rate=0 => Without Down Sample
if(down_sample_rate==0)
    bitplane=bitplane_origin;
    down_sample_Pix=2^(down_sample_rate);
else
    bitplane_Downsampled=bitplane_origin;
    for t=1:down_sample_rate
        bitplane_Downsampled=Function_DownSampling_Bitplane(bitplane_Downsampled);
    end
    bitplane=bitplane_Downsampled;
    down_sample_Pix=2^(down_sample_rate);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Cul Chi2Map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
T=size(bitplane,3);
N=down_sample_Pix*down_sample_Pix;
%階層的oneカウント
G=T/M;
levelM=zeros(size(bitplane,1),size(bitplane,2),G);
for m=1:G
   levelM(:,:,m)=imboxfilt(sum(bitplane(:,:,(m-1)*M+1:m*M),3),BoxK) ;
end

p_hat=sum(levelM,3)/size(bitplane,3)/down_sample_Pix/down_sample_Pix;
p_hat_not=((T*down_sample_Pix*down_sample_Pix)-sum(levelM,3))/size(bitplane,3)/down_sample_Pix/down_sample_Pix;
% 
% level2_2D=bitplane(:,:,1:2:end)+bitplane(:,:,2:2:end);
% level3_2D=level2_2D(:,:,1:2:end)+level2_2D(:,:,2:2:end);
% level4_2D=level3_2D(:,:,1:2:end)+level3_2D(:,:,2:2:end);
% level5_2D=level4_2D(:,:,1:2:end)+level4_2D(:,:,2:2:end);
% level6_2D=level5_2D(:,:,1:2:end)+level5_2D(:,:,2:2:end);
% level7_2D=level6_2D(:,:,1:2:end)+level6_2D(:,:,2:2:end);
%level8_2D=level7_2D(:,:,1:2:end)+level7_2D(:,:,2:2:end);

%階層的zeroカウント
% hanten_level2_2D=hanten_bitplane(:,:,1:2:end)+hanten_bitplane(:,:,2:2:end);
% hanten_level3_2D=hanten_level2_2D(:,:,1:2:end)+hanten_level2_2D(:,:,2:2:end);
% hanten_level4_2D=hanten_level3_2D(:,:,1:2:end)+hanten_level3_2D(:,:,2:2:end);
% hanten_level5_2D=hanten_level4_2D(:,:,1:2:end)+hanten_level4_2D(:,:,2:2:end);
% hanten_level6_2D=hanten_level5_2D(:,:,1:2:end)+hanten_level5_2D(:,:,2:2:end);
%hanten_level7_2D=hanten_level6_2D(:,:,1:2:end)+hanten_level6_2D(:,:,2:2:end);
%hanten_level8_2D=hanten_level7_2D(:,:,1:2:end)+hanten_level7_2D(:,:,2:2:end);

%カイ二乗計算
% kai2_level2_2D=(level2_2D-p_hat*2).*(level2_2D-p_hat*2)./(p_hat*2)+(hanten_level2_2D-p_hat_not*2).*(hanten_level2_2D-p_hat_not*2)./(p_hat_not*2);
% kai2_level3_2D=(level3_2D-p_hat*4).*(level3_2D-p_hat*4)./(p_hat*4)+(hanten_level3_2D-p_hat_not*4).*(hanten_level3_2D-p_hat_not*4)./(p_hat_not*4);
% kai2_level4_2D=(level4_2D-p_hat*8).*(level4_2D-p_hat*8)./(p_hat*8)+(hanten_level4_2D-p_hat_not*8).*(hanten_level4_2D-p_hat_not*8)./(p_hat_not*8);
% kai2_level5_2D=(level5_2D-p_hat*16).*(level5_2D-p_hat*16)./(p_hat*16)+(hanten_level5_2D-p_hat_not*16).*(hanten_level5_2D-p_hat_not*16)./(p_hat_not*16);
%kai2_level6_2D=(level6_2D-p_hat*32*N).*(level6_2D-p_hat*32*N)./(p_hat*32*N+1)+(hanten_level6_2D-p_hat_not*32*N).*(hanten_level6_2D-p_hat_not*32*N)./(p_hat_not*32*N+1);
%% Fixed
%Z_ki=(level7_2D-p_hat*64*N);
Z_ki_16=(levelM-p_hat*M*N);
%Z_ki=(level7_2D-p_hat*64*N);
%kai2_level7_2D=(Z_ki.*Z_ki);
kai2_level5_2D=(Z_ki_16.*Z_ki_16);
%+(hanten_level6_2D-p_hat_not*32*N).*(hanten_level6_2D-p_hat_not*32*N)./(p_hat_not*32*N+1);
%kai2_level7_2D=(level7_2D-p_hat*64*N).*(level7_2D-p_hat*64*N)./(p_hat*64*N+1)+(hanten_level7_2D-p_hat_not*64*N).*(hanten_level7_2D-p_hat_not*64*N)./(p_hat_not*64*N+1);
%kai2_level8_2D=(level8_2D-p_hat*128*N).*(level8_2D-p_hat*128*N)./(p_hat*128*N+1)+(hanten_level8_2D-p_hat_not*128*N).*(hanten_level8_2D-p_hat_not*128*N)./(p_hat_not*128*N+1);

%result_2D=sum(kai2_level8_2D,3)+sum(kai2_level7_2D,3)+sum(kai2_level6_2D,3);
%result_2D=sum(kai2_level7_2D,3)./(64*N*p_hat.*p_hat_not+0.000000001);
result_2D=sum(kai2_level5_2D,3)./(M*N*p_hat.*p_hat_not+0.000000001);