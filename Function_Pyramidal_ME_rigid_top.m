function [bitplane_MC,Estimation_x,Estimation_y,Estimation_theta,Estimation_scale]=Function_Pyramidal_ME_rigid_top(bitplanes,Range_x,Range_y,Range_theta,Range_scale,O_obj,Heat_map,n,M,N_Pyramid,N_sort)

offset_x(1:N_sort)=0;
offset_y(1:N_sort)=0;
offset_theta(1:N_sort)=0;
offset_scale(1:N_sort)=0;
for n_py=N_Pyramid:-1:2
    n_Pyramid=n_py
    if(n_py~=N_Pyramid)
        offset_x=round(next_offset_x/(2^(n_py)));
        offset_y=round(next_offset_y/(2^(n_py)));
        offset_theta=next_offset_theta;
        offset_scale=round(next_offset_scale/(2^(n_py)));
    end
    [bitplane_MC,Estimation_x,Estimation_y,Estimation_theta,Estimation_scale]=Function_Pyramidal_ME_rigid_module(bitplanes,Range_x,offset_x,Range_y,offset_y,Range_theta,offset_theta,Range_scale,offset_scale,O_obj,Heat_map,n,M,n_Pyramid,N_sort);
    next_offset_x=Estimation_x;
    next_offset_y=Estimation_y;
    next_offset_theta=Estimation_theta;
    next_offset_scale=Estimation_scale;
end

end