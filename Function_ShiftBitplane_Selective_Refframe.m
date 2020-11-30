function [tmp_bitplane]=Function_ShiftBitplane_Selective_Refframe(bitplanes,Motion_x,Motion_y,n)

tmp_bitplane=bitplanes;
T=size(bitplanes,3);

%now=y
shift_per_bitplane_x=double(Motion_x)/(T-1);
shift_per_bitplane_y=double(Motion_y)/(T-1);

for t=1:T
    dx=round((t-n)*shift_per_bitplane_x);
    dy=round((t-n)*shift_per_bitplane_y);
    
    if(dx<0)
        if(dy<0)
            tmp_bitplane(1-dy:end,1-dx:end,t)=bitplanes(1:end+dy,1:end+dx,t);
        else
            tmp_bitplane(1:end-dy,1-dx:end,t)=bitplanes(1+dy:end,1:end+dx,t);
        end
    else
        if(dy<0)
            tmp_bitplane(1-dy:end,1:end-dx,t)=bitplanes(1:end+dy,1+dx:end,t);
        else
            tmp_bitplane(1:end-dy,1:end-dx,t)=bitplanes(1+dy:end,1+dx:end,t);
        end
    end
    
end

