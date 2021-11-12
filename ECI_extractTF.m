clear; clc;
eeglab;
subnum = [11:12 14:26 28:54 56:74];
j= 1;
for i= subnum
    subName{1,j} = ['sub' num2str(i)];
    j=j+1;
end
Cond={'C 11' 'C 12' 'C 21' 'C 22'};  % 4种条件，被试内设计  
file_path='D:\ECI_ALEX\eeg_preprocess_TP9TP10\'; %文件所在路径

f=1:1:30;
winsize=0.25;%0.3
detrend_opt=1;%1;0

for i=1:length(subName)  %被试的循环
    file_name=[subName{i} 'ERP_correct4ERSP.set'];%文件名每次循环都变  
    for j=1:length(Cond)  %条件的循环
        EEG= pop_loadset('filename',file_name,'filepath',[file_path subName{i}]);  %导入目标数据   
        EEG = pop_selectevent( EEG, 'type',{Cond{j}},'deleteevents','off','deleteepochs','on','invertepochs','off');
        %上面这行脚本是在挑取特定条件marker段，这行脚本来源于EEGLAB面板操作中Edit-select epochs or events- 然后选择
        %特定type的marker，操作完后EEG.history得到这个函数，然后对函数的type后面部分进行了修改，使其每次循环时都把某一条件的所有段提取出来。
        %EEG = pop_rmbase( EEG, [-1000     0]); %基线校正        
        x=EEG.data;
        Fs=EEG.srate;
        for CH=1:length(EEG.chanlocs)
            
           for mm=1:size(x,3) 
              [S, U, P, F] = sub_stft(squeeze(x(CH,:,mm)), EEG.times/1000, EEG.times/1000, f, Fs, winsize, detrend_opt);
              for ii=1:30
                  %P_divid(ii,:)=(P(ii,:)-mean(P(ii,126:176)))/mean(P(ii,126:176)); % baseline correction [-500 -300]
                  P_sub(ii,:)=P(ii,:)-mean(P(ii,126:176)); % baseline correction [-500 -300]
              end
              %P_all_divid(:,:,mm)=P_divid; % freq * timepoints * trials
              P_all_sub(:,:,mm)=P_sub; % freq * timepoints * trials
           end
  
        P_avg_divid(CH,:,:,i,j)=mean(P_all_divid,3);
        P_avg_sub(CH,:,:,i,j)=mean(P_all_sub,3);
        clear P_divid P_sub P_all_divid P_all_sub S U P F
        end
    end 
end
save Power1_30_detrend250divide.mat P_avg_sub
times=EEG.times;