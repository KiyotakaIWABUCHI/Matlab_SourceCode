function [update_image]=Function_Bilateral(chi_map_pint,Kernel_size,sigma_pix,sigma_dist)
SIZE=size(chi_map_pint);
chi_map_pint_update=chi_map_pint;
for i=1+Kernel_size:SIZE(1)-Kernel_size
    for j=1+Kernel_size:SIZE(2)-Kernel_size
        
        w_total=0;
        for k_i=-Kernel_size:Kernel_size
            for k_j=-Kernel_size:Kernel_size
                pix_diff=abs(chi_map_pint(i+k_i,j+k_j)-chi_map_pint(i,j));
                dist_diff=sqrt((k_i^2+k_j^2));
                w_pix=exp(-pix_diff/sigma_pix);
                w_dist=exp(-dist_diff/sigma_dist);
                w_total=w_total+w_pix*w_dist;
                
                chi_map_pint_update(i,j)=chi_map_pint_update(i,j)+w_pix*dist_diff*chi_map_pint(i+k_i,j+k_j);
            end
        end
        if(w_total==0)
        else
            chi_map_pint_update(i,j)=chi_map_pint_update(i,j)/w_total;
        end
    end
end
update_image=chi_map_pint_update;