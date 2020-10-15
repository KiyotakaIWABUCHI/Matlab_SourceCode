function [New_Field_i,New_Field_j,Vx,Vy]=Function_Patch_Match(img1,img2,Field_i,Field_j,SIZE,R,K,K_delta,ramda)

img_before=imresize(img1,SIZE);
img_after=imresize(img2,SIZE);
Field_i=round(imresize(Field_i,SIZE,'nearest')/(size(img1,1)/SIZE(1)));
Field_j=round(imresize(Field_j,SIZE,'nearest')/(size(img1,1)/SIZE(1)));

A=transpose(1:SIZE(1));
origin_i=repmat(A,1,SIZE(2));
origin_j=transpose(origin_i);

img_ref=zeros(SIZE(1)+2*(K+R),SIZE(2)+2*(K+R));
img_ref((K+R)+1:(K+R)+SIZE(1),(K+R)+1:(K+R)+SIZE(2))=img_after;
sdd_Min=ones(SIZE)*realmax;

Vx=Field_j-origin_j;
Vy=Field_i-origin_i;

for i=K+1:SIZE(1)-K
    for j=K+1:SIZE(2)-K
        if(Field_i(i,j)<=K)
            Field_i(i,j)=K;
        elseif(Field_i(i,j)>=SIZE(1))
            Field_i(i,j)=SIZE(1);
        end
        
        if(Field_j(i,j)<=K)
            Field_j(i,j)=K;
        elseif(Field_j(i,j)>=SIZE(2))
            Field_j(i,j)=SIZE(2);
        end
    end
end


for i=K+1:SIZE(1)-K
    for j=K+1:SIZE(2)-K
        i_shift_est=0;
        j_shift_est=0;
        for i_shift=-R:R
            for j_shift=-R:R
                tmpVx=(Field_j(i,j)+j_shift-origin_j(i,j));
                ref_Vx=abs(Vx(i-K_delta:i+K_delta,j-K_delta:j+K_delta)-tmpVx);
                ref_Vx(K_delta+1,K_delta+1)=0;
                
                tmpVy=(Field_i(i,j)+i_shift-origin_i(i,j));
                ref_Vy=abs(Vy(i-K_delta:i+K_delta,j-K_delta:j+K_delta)-tmpVy);
                ref_Vy(K_delta+1,K_delta+1)=0;
                
                diff_v=sum(sum(abs(ref_Vx)))+sum(sum(abs(ref_Vy)));
                
                diff=abs(img_ref(((K+R))+Field_i(i,j)+i_shift-K:((K+R))+Field_i(i,j)+i_shift+K,((K+R))+Field_j(i,j)+j_shift-K:((K+R))+Field_j(i,j)+j_shift+K)-img_before(i-K:i+K,j-K:j+K));
                
                ssd=sum(sum(diff))+ramda*diff_v;
                if(sdd_Min(i,j)>ssd)
                    sdd_Min(i,j)=ssd;
                    i_shift_est=i_shift;
                    j_shift_est=j_shift;
                    %                         Vi(i,j)=i_shift;
                    %                         Vj(i,j)=j_shift;
                    
                end
            end
        end
        
        Field_i(i,j)=Field_i(i,j)+i_shift_est;
        Field_j(i,j)=Field_j(i,j)+j_shift_est;
        
        if(Field_i(i,j)<=K)
            Field_i(i,j)=K;
        elseif(Field_i(i,j)>=SIZE(1))
            Field_i(i,j)=SIZE(1);
        end
        
        if(Field_j(i,j)<=K)
            Field_j(i,j)=K;
        elseif(Field_j(i,j)>=SIZE(2))
            Field_j(i,j)=SIZE(2);
        end
    end
end
Vx=Field_j-origin_j;
Vy=Field_i-origin_i;


Vx=imresize(Vx,size(img1),'nearest')/(SIZE(1)/size(img1,1));
Vy=imresize(Vy,size(img1),'nearest')/(SIZE(1)/size(img1,1));
Field_i=round(imresize(Field_i,size(img1),'nearest')/(SIZE(1)/size(img1,1)));
Field_j=round(imresize(Field_j,size(img1),'nearest')/(SIZE(1)/size(img1,1)));

New_Field_i=Field_i;
New_Field_j=Field_j;
