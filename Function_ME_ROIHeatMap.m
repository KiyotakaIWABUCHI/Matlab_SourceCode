function [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap(bitplanes,Range_x,Range_y,Heat_map,down_sample_rate)
%%%%%%%%%%%%%%%%%%%%% initialize St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TATE=size(bitplanes,1);
YOKO=size(bitplanes,2);
number_frame=size(bitplanes,3);
T=number_frame;
cost_min=realmax;
tmp_bitplane=bitplanes;
bitplane_MC=bitplanes;
Estimation_x=zeros(TATE,YOKO);
Estimation_y=zeros(TATE,YOKO);
%%%%%%%%%%%%%%%%%%%%% initialize Ed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% For Fast Search %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
register_dx(1:number_frame)=0;
register_dy(1:number_frame)=0;

for x=Range_x(1):Range_x(3):Range_x(2)
    Enable_Area=zeros(TATE,YOKO);
    now=x
    for y=Range_y(1):Range_y(3):Range_y(2)
        %now=y
        shift_per_bitplane_x=double(x)/(T-1);
        shift_per_bitplane_y=double(y)/(T-1);
        
        %%%%%%%%%%%%%%%%%%%% 有効画素範囲決定 %%%%%%%%%%%%%%%%%%%%
        y_margin=round(y/4);
        x_margin=round(x/4);
        
        if(y<0)
            if(x_margin<0)
                Enable_Area(1-y_margin:end,1-x_margin:end)=1; %まいなすならひだり部分，うえ部分
            else
                Enable_Area(1-y_margin:end,1:end-x_margin)=1;
            end
        else
            if(x_margin<0)
                Enable_Area(1:end-y_margin,1-x_margin:end)=1; %まいなすならひだり部分，うえ部分
            else
                Enable_Area(1:end-y_margin,1:end-x_margin)=1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%
        
        for t=1:T
            dx=round((t-1)*shift_per_bitplane_x);
            dy=round((t-1)*shift_per_bitplane_y);
            
            if(register_dx(t)~=dx || register_dy(t)~=dy )
                if(x<0)
                    if(y<0)
                        tmp_bitplane(1-dy:end,1-dx:end,t)=bitplanes(1:end+dy,1:end+dx,t);
                    else
                        tmp_bitplane(1:end-dy,1-dx:end,t)=bitplanes(1+dy:end,1:end+dx,t);
                    end
                else
                    if(y<0)
                        tmp_bitplane(1-dy:end,1:end-dx,t)=bitplanes(1:end+dy,1+dx:end,t);
                    else
                        tmp_bitplane(1:end-dy,1:end-dx,t)=bitplanes(1+dy:end,1+dx:end,t);
                    end
                end
                
                register_dx(t)=dx;
                register_dy(t)=dy;
            end
            
        end
        %imshow(uint8(Function_Reconstruction_SUM(tmp_bitplane)))
        
        %% コスト計算
        [result_2D]=Function_Module_Chi2MapCul(tmp_bitplane,down_sample_rate);
        result_2D=imresize(result_2D,[TATE YOKO],'bicubic');
        %% 重みつけ
        result_2D_yuukou=double(result_2D.*Enable_Area);
        weight_map_yuukou=double(Heat_map.*Enable_Area);
        result_2D_weighted=weight_map_yuukou.*result_2D_yuukou;
        total_cost=sum(sum(result_2D_weighted))/sum(sum(Enable_Area));
        
        %% cost更新
        if(cost_min>total_cost)
            bitplane_MC=tmp_bitplane;
            cost_min=total_cost;
            Estimation_x=x;
            Estimation_y=y;
        end
        
        imshow(uint8(Function_Reconstruction_SUM(bitplane_MC)))
    end
end


end