function [bitplane_MC,Estimation_x,Estimation_y]=Function_ME_PixelWise(bitplanes,range_x,range_y,K)
%%%%%%%%%%%%%%%%%%%%%%%%%
%���� bitplane�摜(bitplane)
%���x���t�����ꂽ���̈�
%���U�v�Z�̍ۂ̃J�[�l���T�C�Y
%�e���̈�̏d�S
%�ǂ̓��̈�̓�����������邩�̔ԍ�
% mode ���U����ϊ��I�� mode 2�ȊO������
%%%%%%%%%%%%%%%%%%%%%%%%%

TATE=size(bitplanes,1);
YOKO=size(bitplanes,2);
number_frame=size(bitplanes,3);
T=number_frame;
%% ������
costmin=ones(TATE,YOKO)*realmax;

%%
tmp_bitplane=bitplanes;
bitplane_MC=bitplanes;
Estimation_x=zeros(TATE,YOKO);
Estimation_y=zeros(TATE,YOKO);

register_dx(1:number_frame)=0;
register_dy(1:number_frame)=0;
%% �v�Z
for x=range_x(1):range_x(3):range_x(2) %-60:20 
    now=x
     for y=range_y(1):range_y(3):range_y(2)
        yukou_range=zeros(TATE,YOKO);
        %now=y
        shift_per_bitplane_x=double(x)/(T-1);
        shift_per_bitplane_y=double(y)/(T-1);
        y_margin=round(y);
        x_margin=round(x);
        if(y<0)
            if(x_margin<0)
               yukou_range(1-y_margin:end,1-x_margin:end)=1; %�܂��Ȃ��Ȃ�Ђ��蕔���C��������
            else
               yukou_range(1-y_margin:end,1:end-x_margin)=1;
            end
        else
            if(x_margin<0)
               yukou_range(1:end-y_margin,1-x_margin:end)=1; %�܂��Ȃ��Ȃ�Ђ��蕔���C��������
            else
               yukou_range(1:end-y_margin,1:end-x_margin)=1;
            end
        end
        
        %imshow(uint8(yukou_range*255))
        for t=1:T
%             dx=fix((t-1)*shift_per_bitplane_x);
%             dy=fix((t-1)*shift_per_bitplane_y);
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
        %imshow(uint8(function_reconstruced_SUM(tmp_bitplane)))
       %% �R�X�g�v�Z
        [result_2D]=Function_Module_Chi2MapCul(tmp_bitplane,0);         
       %% �k�g�ŋߖT��f�l��
       if(y<0)
            if(x<0)
               A=result_2D(1-y_margin:end,1-x_margin:end); %�܂��Ȃ��Ȃ�Ђ��蕔���C��������
            else
               A=result_2D(1-y_margin:end,1:end-x_margin);
            end
        else
            if(x<0)
               A=result_2D(1:end-y_margin,1-x_margin:end); %�܂��Ȃ��Ȃ�Ђ��蕔���C��������
            else
               A=result_2D(1:end-y_margin,1:end-x_margin);
            end
        end
        A_shulink=imresize(A,1/K,'bilinear');
        result_2D_yukou=imresize(A_shulink,size(A),'bilinear');
        result_2D(:,:)=realmax/2;
       if(y<0)
            if(x<0)
               result_2D(1-y_margin:end,1-x_margin:end)=result_2D_yukou; %�܂��Ȃ��Ȃ�Ђ��蕔���C��������
            else
               result_2D(1-y_margin:end,1:end-x_margin)=result_2D_yukou;
            end
        else
            if(x<0)
               result_2D(1:end-y_margin,1-x_margin:end)=result_2D_yukou; %�܂��Ȃ��Ȃ�Ђ��蕔���C��������
            else
               result_2D(1:end-y_margin,1:end-x_margin)=result_2D_yukou;
            end
       end
       %imshow(uint8(double(costmin>result_2D)*255))
       %% �r�b�g�v���[���X�V
         tmp_3D=repmat(double(costmin>result_2D),[1 1 T]);
         bitplane_MC=tmp_3D.*tmp_bitplane+(1-tmp_3D).*bitplane_MC;
        %% estimation result
         Estimation_x=double(costmin>result_2D)*x+double(costmin<=result_2D).*Estimation_x;
         Estimation_y=double(costmin>result_2D)*y+double(costmin<=result_2D).*Estimation_y;
        %% �R�X�g�X�V
        costmin=double(costmin>result_2D).*(result_2D)+double(costmin<=result_2D).*(costmin);
        imshow(uint8(Function_Reconstruction_SUM(bitplane_MC)))
     end
end


