function [Denoised_MD_map]=Function_MDMap_NR(MD_Map,Th_Min_Label,Opening_time)

%% ラベリング処理&オープニング処理
    %% ラベリング処理
    [Label,NUM] = bwlabeln(uint8(MD_Map),4);
    for n=1:NUM
        n_label=double(Label==n);
        tempnum=sum(sum(n_label));
        if(tempnum<=Th_Min_Label)
            MD_Map=MD_Map-n_label;
        end
    end

    %% オープニング処理
    for t=1:Opening_time
        y=MD_Map;
        for i=2:size(MD_Map,1)-1
            for j=2:size(MD_Map,2)-1
                cnt=sum(sum(MD_Map(i-1:i+1,j-1:j+1)));
                if(cnt>=4)
                    y(i,j)=1;
                end
            end
        end
        MD_Map=y;
    end
    Denoised_MD_map=MD_Map;