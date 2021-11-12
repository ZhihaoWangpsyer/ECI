clear; clc;
eeglab;
subnum = [11:12 14:26 28:54 56:74];
j= 1;
for i= subnum
    subName{1,j} = ['sub' num2str(i)];
    j=j+1;
end
Cond={'C 11' 'C 12' 'C 21' 'C 22'};  % 4�����������������  
file_path='D:\ECI_ALEX\eeg_preprocess_TP9TP10\'; %�ļ�����·��

f=1:1:30;
winsize=0.25;%0.3
detrend_opt=1;%1;0

for i=1:length(subName)  %���Ե�ѭ��
    file_name=[subName{i} 'ERP_correct4ERSP.set'];%�ļ���ÿ��ѭ������  
    for j=1:length(Cond)  %������ѭ��
        EEG= pop_loadset('filename',file_name,'filepath',[file_path subName{i}]);  %����Ŀ������   
        EEG = pop_selectevent( EEG, 'type',{Cond{j}},'deleteevents','off','deleteepochs','on','invertepochs','off');
        %�������нű�������ȡ�ض�����marker�Σ����нű���Դ��EEGLAB��������Edit-select epochs or events- Ȼ��ѡ��
        %�ض�type��marker���������EEG.history�õ����������Ȼ��Ժ�����type���沿�ֽ������޸ģ�ʹ��ÿ��ѭ��ʱ����ĳһ���������ж���ȡ������
        %EEG = pop_rmbase( EEG, [-1000     0]); %����У��        
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