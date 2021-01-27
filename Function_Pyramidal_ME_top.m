function [bitplane_MC,Estimation_x,Estimation_y]=Function_Pyramidal_ME_top(bitplanes,Range_x,Range_y,Heat_map,n,M,N_Pyramid,N_sort)

offset_x=[0 0];
offset_y=[0 0];
for n_py=N_Pyramid:-1:1
    n_Pyramid=n_py;
    if(n_py~=N_Pyramid)
        offset_x=round(next_offset_x/(2^(n_py)));
        offset_y=round(next_offset_y/(2^(n_py)));
    end
    [bitplane_MC,Estimation_x,Estimation_y]=Function_Pyramidal_ME_module(bitplanes,Range_x,offset_x,Range_y,offset_y,Heat_map,n,M,n_Pyramid,N_sort);
    next_offset_x=Estimation_x;
    next_offset_y=Estimation_y;
end

end