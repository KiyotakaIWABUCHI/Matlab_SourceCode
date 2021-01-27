function [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_Sort_for_Pyramid(bitplanes,down_sample_Pix,Range_x,Offset_x,Range_y,Offset_y,Heat_map,n,M,N_Sort)
%%%%%%%%%%%%%%%%%%%%% initialize St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TATE=size(bitplanes,1);
YOKO=size(bitplanes,2);
number_frame=size(bitplanes,3);
T=number_frame;
cost_min(1:N_Sort)=realmax;
tmp_bitplane=bitplanes;
bitplane_MC=bitplanes;
Estimation_x(1:N_Sort)=realmax;
Estimation_y(1:N_Sort)=realmax;
%%%%%%%%%%%%%%%%%%%%% initialize Ed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% For Fast Search %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
register_dx(1:number_frame)=0;
register_dy(1:number_frame)=0;

for ofs=1:size(Offset_x,2)
    Range_x_ofs=[Range_x(1)+Offset_x(ofs) Range_x(2)+Offset_x(ofs) Range_x(3)];
    Range_y_ofs=[Range_y(1)+Offset_y(ofs) Range_y(2)+Offset_y(ofs) Range_y(3)];
    for x=Range_x_ofs(1):Range_x_ofs(3):Range_x_ofs(2)
        Enable_Area=zeros(TATE,YOKO);
        now=x
        for y=Range_y_ofs(1):Range_y_ofs(3):Range_y_ofs(2)
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
                dx=round((t-n)*shift_per_bitplane_x);
                dy=round((t-n)*shift_per_bitplane_y);
                
                if(register_dx(t)~=dx || register_dy(t)~=dy )
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
                    
                    register_dx(t)=dx;
                    register_dy(t)=dy;
                end
                
            end
            %imshow(uint8(Function_Reconstruction_MLE_Oversample(tmp_bitplane,2,1,5)))
            
            %% コスト計算
            [result_2D]=Function_Module_Chi2MapCul_Mpixel_for_Pyramid(tmp_bitplane,down_sample_Pix,M);
            result_2D=imresize(result_2D,[TATE YOKO],'bicubic');
            %% 重みつけ
            result_2D_yuukou=double(result_2D.*Enable_Area);
            Heat_map=imresize(Heat_map,[TATE YOKO],'bicubic');
            weight_map_yuukou=double(Heat_map.*Enable_Area);
            result_2D_weighted=weight_map_yuukou.*result_2D_yuukou;
            total_cost=sum(sum(result_2D_weighted))/sum(sum(Enable_Area));
            
            %% cost更新
            if(sum(double(Estimation_x==x))==0 && sum(double(Estimation_y==y))==0)
                
                for c=1:N_Sort
                    if(cost_min(c)>total_cost)
                        if(c==1)
                            bitplane_MC=tmp_bitplane;
                        end
                        
                        if(c<N_Sort)
                            for s=0:N_Sort-(c+1)
                                Estimation_x(N_Sort-s)=Estimation_x(N_Sort-1-s);
                                Estimation_y(N_Sort-s)=Estimation_y(N_Sort-1-s);
                                cost_min(N_Sort-s)=cost_min(N_Sort-1-s);
                            end
                        end
                        Estimation_x(c)=x;
                        Estimation_y(c)=y;
                        cost_min(c)=total_cost;
                    end
                    
                end
                
            end
            
        end
        
        %imshow(uint8(Function_Reconstruction_SUM(bitplane_MC)))
    end
end
end
