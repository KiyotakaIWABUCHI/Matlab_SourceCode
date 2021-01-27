function [bitplane_MC,Estimation_x,Estimation_y,Estimation_theta,Estimation_scale]=Function_ME_Sort_for_Pyramid_Rigid(bitplanes,down_sample_Pix,Range_x,Offset_x,Range_y,Offset_y,Range_rotation,Offset_rotation,Range_scale,Offset_scale,O_obj,Heat_map,n,M,N_Sort)
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
Estimation_theta(1:N_Sort)=realmax;
Estimation_scale(1:N_Sort)=realmax;
Margin_X=round(YOKO/4);
Margin_Y=round(TATE/4);
%%%%%%%%%%%%%%%%%%%%% initialize Ed %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% For Fast Search %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for ofs=1:size(Offset_x,2)
    Range_x_ofs=[Range_x(1)+Offset_x(ofs) Range_x(2)+Offset_x(ofs) Range_x(3)];
    Range_y_ofs=[Range_y(1)+Offset_y(ofs) Range_y(2)+Offset_y(ofs) Range_y(3)];
    Range_rotation_ofs=[Range_rotation(1)+Offset_rotation(ofs) Range_rotation(2)+Offset_rotation(ofs) Range_rotation(3)];
    Range_sclae_ofs=[Range_scale(1)+Offset_scale(ofs) Range_scale(2)+Offset_scale(ofs) Range_scale(3)];
    for jshift=Range_x_ofs(1):Range_x_ofs(3):Range_x_ofs(2) %-60:20
        %now=jshift
        for ishift=Range_y_ofs(1):Range_y_ofs(3):Range_y_ofs(2)
            y=ishift
            for m_tmp=Range_sclae_ofs(1):Range_sclae_ofs(3):Range_sclae_ofs(2)
                m=m_tmp;
                for theta_tmp=Range_rotation_ofs(1):Range_rotation_ofs(3):Range_rotation_ofs(2) %-180:2:180
                    
                    theta=theta_tmp;
                    tmp_bitplane=bitplanes;%bitplanetmp初期化
                    Enable_Area=ones(TATE,YOKO);
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
                    flag_hit=1;
                    for k=1:N_Sort
                        if ((Estimation_x(k)==jshift) && (Estimation_y(k)==ishift) && (Estimation_theta(k)==theta) &&  (Estimation_scale(k)==m))
                            flag_hit=0;
                        end
                    end
                    if(flag_hit==1)
                        for c=1:N_Sort
                            if(cost_min(c)>total_cost)
                                if(c==1)
                                    bitplane_MC=tmp_bitplane;
                                end
                                
                                if(c<N_Sort)
                                    for s=0:N_Sort-(c+1)
                                        Estimation_x(N_Sort-s)=Estimation_x(N_Sort-1-s);
                                        Estimation_y(N_Sort-s)=Estimation_y(N_Sort-1-s);
                                        Estimation_theta(N_Sort-s)=Estimation_theta(N_Sort-1-s);
                                        Estimation_scale(N_Sort-s)=Estimation_scale(N_Sort-1-s);
                                        cost_min(N_Sort-s)=cost_min(N_Sort-1-s);
                                    end
                                end
                                Estimation_x(c)=jshift;
                                Estimation_y(c)=ishift;
                                Estimation_theta(c)=theta;
                                Estimation_scale(c)=m;
                                cost_min(c)=total_cost;
                            end
                            
                        end
                        
                    end
                    
                end
                
                %imshow(uint8(Function_Reconstruction_SUM(bitplane_MC)))
            end
        end
    end
end