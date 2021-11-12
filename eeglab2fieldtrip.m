clear all; clc;
%subject number
subnum = [11:12 14:26 28:54 56:74];

j= 1;
for i= subnum
    subName{1,j} = ['sub' num2str(i)];
    j=j+1;
end
outputParentFolder = 'D:\ECI_ALEX\eeg_preprocess_TP9TP10\';
for iSubject = 1:length(subName)
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    outputSubjectFolder = [outputParentFolder subName{iSubject}];
    cd(outputSubjectFolder);
    EEG = pop_loadset('filename',[subName{iSubject} 'ERP_correct800.set'],...
        'filepath',[outputSubjectFolder '/']);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 1 );
    EEG = eeg_checkset( EEG );
    
    EEG_C11 = pop_selectevent( EEG, 'type',{'C 11'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG_C12 = pop_selectevent( EEG, 'type',{'C 12'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG_C21 = pop_selectevent( EEG, 'type',{'C 21'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG_C22 = pop_selectevent( EEG, 'type',{'C 22'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    
    all_EEG_C11{iSubject} = EEG_C11;
    all_EEG_C12{iSubject} = EEG_C12;
    all_EEG_C21{iSubject} = EEG_C21;
    all_EEG_C22{iSubject} = EEG_C22;
end

% eeglab 2 fieldtrip
all_data_C11 = cell(length(subName),1);
all_data_C12 = cell(length(subName),1);
all_data_C21 = cell(length(subName),1);
all_data_C22 = cell(length(subName),1);
for i=1:length(subName)
    all_data_C11{i} = eeglab2fieldtrip(all_EEG_C11{i}, 'preprocessing');
    all_data_C12{i} = eeglab2fieldtrip(all_EEG_C12{i}, 'preprocessing');
    all_data_C21{i} = eeglab2fieldtrip(all_EEG_C21{i}, 'preprocessing');
    all_data_C22{i} = eeglab2fieldtrip(all_EEG_C22{i}, 'preprocessing');
end
save('D:\ECI_ALEX\eeg_preprocess_TP9TP10\data_transformed.mat','all_data_C11','all_data_C12','all_data_C21','all_data_C22');

%% average  FIELDTRIP
subj_num = length(all_data_C11);

all_data_avg_C11 = cell(subj_num,1);
all_data_avg_C12 = cell(subj_num,1);
all_data_avg_C21 = cell(subj_num,1);
all_data_avg_C22 = cell(subj_num,1);

cfg = [];
cfg.channel = 'all';
for i=1:subj_num
    all_data_avg_C11{i} = ft_timelockanalysis(cfg, all_data_C11{i});
    all_data_avg_C12{i} = ft_timelockanalysis(cfg, all_data_C12{i});
    all_data_avg_C21{i} = ft_timelockanalysis(cfg, all_data_C21{i});
    all_data_avg_C22{i} = ft_timelockanalysis(cfg, all_data_C22{i});    
end

%% prepare data for stat
merged_High_diff = all_data_avg_C11{1};% borrow structure from all_data_avg_l3
merged_Low_diff = all_data_avg_C11{1};% borrow structure from all_data_avg_l3
merged_EmotionPain = all_data_avg_C12{1};
merged_EmotionNoPain = all_data_avg_C21{1};
merged_CognitionHigh = all_data_avg_C21{1};
merged_CognitionLow = all_data_avg_C21{1};


C11_trials = [];
C12_trials = [];
C21_trials = [];
C22_trials = [];

for i=1:subj_num
    % subject *  channel * timepoints
    C11_trials(i,:,:) = all_data_avg_C11{i}.avg;
    C12_trials(i,:,:) = all_data_avg_C12{i}.avg;
    C21_trials(i,:,:) = all_data_avg_C21{i}.avg;
    C22_trials(i,:,:) = all_data_avg_C22{i}.avg;
end
% substitute avg for both avg and trial
merged_High_diff.trial = C22_trials - C21_trials;
merged_Low_diff.trial = C12_trials - C11_trials;
merged_EmotionPain.trial = C12_trials + C22_trials;
merged_EmotionNoPain.trial = C11_trials + C21_trials;
merged_CognitionHigh.trial = C21_trials + C22_trials;
merged_CognitionLow.trial = C11_trials + C12_trials;

%% Statistics
% point-to-point statsitics(paired-t-tests)
cfg = [];
cfg.channel     = 'POz';%channel of interest
cfg.statistic   = 'depsamplesT';%statistic method
%cfg.method = 'stats';
%cfg.statistic = 'paired-ttest'
cfg.method = 'montecarlo';% correction of multiple comparison by cluster-based permutation test if needed
cfg.alpha       = 0.05;
% correction method: cluster level
cfg.correctm    = 'cluster';
%cfg.correctm = 'no';
cfg.numrandomization = 2000;

% design matrix
Nsub = 61;% number of subjects
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];%factor
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];% # of subjects
cfg.ivar                = 1; %factor variable, the corresponding row; the row one
cfg.uvar                = 2;%unit variable(i.e., subjects)

% statistics
%stat_interaction = ft_timelockstatistics(cfg, merged_High_diff, merged_Low_diff);
stat_emotion = ft_timelockstatistics(cfg, merged_EmotionPain, merged_EmotionNoPain);
stat_cognition = ft_timelockstatistics(cfg, merged_CognitionHigh, merged_CognitionLow);


figure;
%draw pictures of T values
subplot(321); plot(stat_emotion.time, stat_emotion.stat); ylabel('t-value');
subplot(322); plot(stat_cognition.time, stat_cognition.stat); ylabel('t-value');
subplot(323); plot(stat_emotion.time, stat_emotion.prob); ylabel('prob');%draw pictures of P values(after corrected)
subplot(324); plot(stat_cognition.time, stat_cognition.prob); ylabel('prob');%draw pictures of P values(after corrected)
subplot(325); plot(stat_emotion.time, stat_emotion.mask); ylabel('significant');axis([-0.2 0.8 0 2]);% draw significant timepoints(stat.mask)
subplot(326); plot(stat_cognition.time, stat_cognition.mask); ylabel('significant');axis([-0.2 0.8 0 2]);% draw significant timepoints(stat.mask)