function [tmp_bitplane]=Function_ShiftBitplane_Rigid_Selective_Refframe(bitplanes,Motionx,Motiony,Motiontheta,Motionscale,O_obj,n)

%%%%%%%%%%%%%%%%%%%%% initialize St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TATE=size(bitplanes,1);
YOKO=size(bitplanes,2);
number_frame=size(bitplanes,3);
T=number_frame;
%%%%%%%%%%%%%%%%%%%%% initialize Ed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
jshift=Motionx;
ishift=Motiony;
theta=Motiontheta;
m=Motionscale;

tmp_bitplane=bitplanes;%bitplanetmp初期化
for i=1:TATE
    for j=1:YOKO
        for t=1:T
            ct=cos(((t-n)/(T-1))*theta/360*2*pi);
            st=sin(((t-n)/(T-1))*theta/360*2*pi);
            
            ri=(i-O_obj(1));
            rj=(j-O_obj(2));
            
            arot=(rj*st+ri*ct+O_obj(1));
            brot=(rj*ct-ri*st+O_obj(2));
            
            mi=(i-O_obj(1))/TATE/2;
            mj=(j-O_obj(2))/YOKO/2;
            
            ascl=(mi*m*(t-n)/(T-1));
            bscl=(mj*m*(t-n)/(T-1));
            
            di=ishift/(T-1);
            dj=jshift/(T-1);
            
            apara=di*(t-n);
            bpara=dj*(t-n);
            
            
            y=round(apara+ascl+arot);
            x=round(bpara+bscl+brot);
            if(y<1)
                y=1;
            end
            if(x<1)
                x=1;
            end
            if(y>TATE)
                y=TATE;
            end
            if(x>YOKO)
                x=YOKO;
            end
            
            tmp_bitplane(i,j,t)=bitplanes(y,x,t);            
        end
    end
end


