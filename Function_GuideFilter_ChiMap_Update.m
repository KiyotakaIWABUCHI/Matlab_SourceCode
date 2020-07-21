function [update_image]=Function_GuideFilter_ChiMap_Update(image_pint,chi_map_pint,Kernel_size,sigma)
SIZE=size(image_pint);
chi_map_pint_update=chi_map_pint;
for i=1+Kernel_size:SIZE(1)-Kernel_size
    for j=1+Kernel_size:SIZE(2)-Kernel_size
        
        w_total=0;
        for k_i=-Kernel_size:Kernel_size
            for k_j=-Kernel_size:Kernel_size
                pix_diff=abs(image_pint(i+k_i,j+k_j)-image_pint(i,j));
                w=exp(-pix_diff/sigma);
                w_total=w_total+w;
                
                chi_map_pint_update(i,j)=chi_map_pint_update(i,j)+w*chi_map_pint(i+k_i,j+k_j);
            end
        end
        if(w_total==0)
        else
            chi_map_pint_update(i,j)=chi_map_pint_update(i,j)/w_total;
        end
    end
end
update_image=chi_map_pint_update;