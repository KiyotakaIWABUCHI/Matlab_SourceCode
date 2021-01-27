function [bitplane_MC,Estimation_x_results,Estimation_y_results]=Function_Pyramidal_ME_module(bitplanes,Range_x,Range_x_offset,Range_y,Range_y_offset,Heat_map,n,M,N_Pyramid,N_Sort)


%%%%%%% Bitplane down Sampling %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% down_sample_rate=0 => Without Down Sample
if(N_Pyramid==0)
    bitplane=bitplanes;
    down_sample_Pix=2^(N_Pyramid);
else
    bitplane_Downsampled=bitplanes;
    for t=1:N_Pyramid
        bitplane_Downsampled=Function_DownSampling_Bitplane(bitplane_Downsampled);
    end
    bitplane=bitplane_Downsampled;
    down_sample_Pix=2^(N_Pyramid);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Cul Chi2Map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[bitplane_MC,Estimation_x,Estimation_y]=Function_ME_Sort_for_Pyramid(bitplane,down_sample_Pix,Range_x,Range_x_offset,Range_y,Range_y_offset,Heat_map,n,M,N_Sort);
Estimation_x_results=Estimation_x*down_sample_Pix;
Estimation_y_results=Estimation_y*down_sample_Pix;



