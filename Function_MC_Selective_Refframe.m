function [MC_bitplane]=Function_MC_Selective_Refframe(bitplanes,x_Motion_Map,y_Motion_Map,n)

MC_bitplane=bitplanes;
T=size(bitplanes,3);
TATE=size(x_Motion_Map,1);
YOKO=size(x_Motion_Map,2);

%now=y
for i=1:size(x_Motion_Map,1)
    for j=1:size(x_Motion_Map,2)
        shift_per_bitplane_x=double(x_Motion_Map(i,j))/(T-1);
        shift_per_bitplane_y=double(y_Motion_Map(i,j))/(T-1);
        
        target_x=round(j+shift_per_bitplane_x*(n-1));
        target_y=round(i+shift_per_bitplane_y*(n-1));
        
        for t=1:T
            dx=round((t-n)*shift_per_bitplane_x);
            dy=round((t-n)*shift_per_bitplane_y);
            
            x_shift=round(target_x+dx);
            y_shift=round(target_y+dy);
            
            
            if(y_shift<1)
                y_shift=1;
            end
            if(x_shift<1)
                x_shift=1;
            end
            if(y_shift>TATE)
                y_shift=TATE;
            end
            if(x_shift>YOKO)
                x_shift=YOKO;
            end
           
            
            MC_bitplane(target_y,target_x,t)=bitplanes(y_shift,x_shift,t);
            
        end
    end
end

    
