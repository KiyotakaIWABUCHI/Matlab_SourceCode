function [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_ROIHeatMap_ROTATE(bitplanes,Range_x,Range_y,Range_scale,Range_rotation,O_obj,HeatMap,down_sample_rate)

%%%%%%%%%%%%%%%%%%%%% initialize St%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TATE=size(bitplanes,1);
YOKO=size(bitplanes,2);
number_frame=size(bitplanes,3);
T=number_frame;
cost_min=realmax;
bitplane_MC=bitplanes;
Estimation_x=zeros(TATE,YOKO);
Estimation_y=zeros(TATE,YOKO);
Margin_X=round(YOKO/2);
Margin_Y=round(TATE/2);
%%%%%%%%%%%%%%%%%%%%% initialize Ed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for jshift=Range_x(1):Range_x(3):Range_x(2) %-60:20
    now=jshift
    for ishift=Range_y(1):Range_y(3):Range_y(2)
        for m_tmp=Range_scale(1):Range_scale(3):Range_scale(2)
            m=m_tmp;
            for theta_tmp=Range_rotation(1):Range_rotation(3):Range_rotation(2) %-180:2:180
                
                theta=theta_tmp;
                tmp_bitplane=bitplanes;%bitplanetmp初期化
                Enable_Area=ones(TATE,YOKO);
                for i=1:TATE
                    for j=1:YOKO
                        for t=1:T
                            ct=cos((t/T)*theta/360*2*pi);
                            st=sin((t/T)*theta/360*2*pi);
                            
                            ri=(i-O_obj(1));
                            rj=(j-O_obj(2));
                            
                            arot=(rj*st+ri*ct+O_obj(1));
                            brot=(rj*ct-ri*st+O_obj(2));
                            
                            mi=(i-O_obj(1))/TATE/2;
                            mj=(j-O_obj(2))/YOKO/2;
                            
                            ascl=(mi*m*(t-1)/T);
                            bscl=(mj*m*(t-1)/T);
                            
                            di=ishift/T;
                            dj=jshift/T;
                            
                            apara=di*T*((t-1)/T);
                            bpara=dj*T*((t-1)/T);
                            
                            
                            y=round(apara+ascl+arot);
                            x=round(bpara+bscl+brot);
                            y_extend=y;
                            x_extend=x;
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
                        
                        %%%%%%%%%%%%%%%% Enable Area Setting %%%%%%%%%%%%%%%%
                        if(y_extend<1-Margin_Y)
                            Enable_Area(i,j)=0;
                        end
                        if(x_extend<1-Margin_X)
                            Enable_Area(i,j)=0;
                        end
                        if(y_extend>TATE+Margin_Y)
                            Enable_Area(i,j)=0;
                        end
                        if(x_extend>YOKO+Margin_X)
                            Enable_Area(i,j)=0;
                        end
                        
                        
                        %%%%%%%%%%%%%%%% Enable Area Setting %%%%%%%%%%%%%%%%
                        
                    end
                    
                    
                end
                imshow(uint8(Function_Reconstruction_SUM(tmp_bitplane)))
                
                %% コスト計算
                [result_2D]=Function_Module_Chi2MapCul(tmp_bitplane,down_sample_rate);
                result_2D=imresize(result_2D,[TATE YOKO],'bicubic');
                %% 重みつけ
                result_2D_Enable=double(result_2D.*Enable_Area);
                weight_map_Enable=double(HeatMap.*Enable_Area);
                result_2D_weighted=weight_map_Enable.*result_2D_Enable;
                Total_cost=sum(sum(result_2D_weighted))/sum(sum(Enable_Area));
                
                %% cost更新
                if(cost_min>Total_cost)
                    bitplane_MC=tmp_bitplane;
                    cost_min=Total_cost;
                    Estimation_x=x;
                    Estimation_y=y;
                end
                
                %imshow(uint8(function_reconstruced_SUM(bitplane_MC)))
            end
        end
    end
end


end