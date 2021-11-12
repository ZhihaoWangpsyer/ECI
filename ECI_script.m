clear;clc;
cwd='D:\ECI_ALEX\beh_data';
cd(cwd)
subjects = {'11','12','14','15','16','17','18','19','20','21','22','23','24','25','26','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','56','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74'};

%% low cognitive demand   
for iSub=1:length(subjects)
  A1=[];
  filename=cell2mat(strcat('ECI_TB_sub',subjects(iSub),'.dat'));
  A1=importdata(filename,',');
  S=zeros(length(A1),6);
  for m=1:length(A1)
    A1_yinhao=strrep(A1(m),'"','');%删除这一行的引号
    A1_spiltcell=regexp(A1_yinhao, ',', 'split');%分割为cell
    % 一response: jk; 二RT; 三answer: fj; 四series; 五bodypart:1hand2foot;
    % 六laterality: 1left2right; 七pain:2pain1nopain
    finalA(1,1)=str2num(A1_spiltcell{1,1}{1,7});% pain:2pain;1nopain
    if A1_spiltcell{1,1}{1,1} == A1_spiltcell{1,1}{1,3}
        finalA(1,2)=1; %correct
    elseif isempty(A1_spiltcell{1,1}{1,1})
        finalA(1,2)=0; %no respone
    else
        finalA(1,2)=-1; %wrong
    end
    
    finalA(1,3)=str2num(A1_spiltcell{1,1}{1,2});% RT
    finalA(1,4)=str2num(A1_spiltcell{1,1}{1,5});% body part:1hand2foot;
    finalA(1,5)=str2num(A1_spiltcell{1,1}{1,6});% laterality:1left2right;
    finalA(1,6)=str2num(A1_spiltcell{1,1}{1,4});% series
    
    S(m,:)=finalA;
    clear A1_yinhao A1_spiltcell finalA
  end
    data=S;%1:{2pain1nopain} 2:Response {1correct;2noresponse;3wrong} 3RT 4bodypart{1hand2foot} 5laterality {1left2right} 6series
    [data num(iSub,1)] = WZ_RT_rej(data,3,2);
%% total
   ACC(iSub,1) = length(intersect(find(data(:,1)==2),find(data(:,2)==1)))/length(find(data(:,1)==2));% for pain 
   ACC(iSub,2) = length(intersect(find(data(:,1)==1),find(data(:,2)==1)))/length(find(data(:,1)==1));% for nopain 
   data_correct = data(find(data(:,2)==1),:);
   RT(iSub,1) =  mean(data_correct(find(data_correct(:,1)==2),3)); %for pain
   RT(iSub,2) =  mean(data_correct(find(data_correct(:,1)==1),3)); %for nopain
   max_RT(iSub,1) = max(data_correct(:,3));
   min_RT(iSub,1) = min(data_correct(:,3));
end
clear A1 filename iSub data data_correct m S

%% high cognitive demand   
for iSub=1:length(subjects)
  A1=[];
  filename=cell2mat(strcat('ECI_TL_sub',subjects(iSub),'.dat'));
  A1=importdata(filename,',');
  S=zeros(length(A1),6);
  for m=1:length(A1)
    A1_yinhao=strrep(A1(m),'"','');%删除这一行的引号
    A1_spiltcell=regexp(A1_yinhao, ',', 'split');%分割为cell
 
    finalA(1,1)=str2num(A1_spiltcell{1,1}{1,7});% pain:2pain1nopain
    if A1_spiltcell{1,1}{1,1} == A1_spiltcell{1,1}{1,3}
        finalA(1,2)=1; %correct
    elseif isempty(A1_spiltcell{1,1}{1,1})
        finalA(1,2)=0; %no respone
    else
        finalA(1,2)=-1; %wrong
    end
    
    finalA(1,3)=str2num(A1_spiltcell{1,1}{1,2});% RT
    finalA(1,4)=str2num(A1_spiltcell{1,1}{1,5});% body part:1hand2foot;
    finalA(1,5)=str2num(A1_spiltcell{1,1}{1,6});% laterality:1left2right;
    finalA(1,6)=str2num(A1_spiltcell{1,1}{1,4});% series
    
    S(m,:)=finalA;
    clear A1_yinhao A1_spiltcell finalA
  end
    data=S;
    [data num(iSub,2)] = WZ_RT_rej(data,3,2);
%% total: high cognitive demand
   ACC(iSub,3) = length(intersect(find(data(:,1)==2),find(data(:,2)==1)))/length(find(data(:,1)==2));% for High&Pain 
   ACC(iSub,4) = length(intersect(find(data(:,1)==1),find(data(:,2)==1)))/length(find(data(:,1)==1));% for High&Nopain 
   data_correct = data(find(data(:,2)==1),:);
   RT(iSub,3) =  mean(data_correct(find(data_correct(:,1)==2),3)); %for High&Pain
   RT(iSub,4) =  mean(data_correct(find(data_correct(:,1)==1),3)); %for High&Nopain
   max_RT(iSub,2) = max(data_correct(:,3));
   min_RT(iSub,2) = min(data_correct(:,3));

end
   clear A1 filename iSub data data_correct m S
   %
   %% ACC/RT or RT/ACC

   ErrorRate = (1-ACC).*100;
   cErrorRate = ErrorRate./RT*10000;
   Interaction_cErrorRate = (cErrorRate(:,3)-cErrorRate(:,4)) - (cErrorRate(:,1)-cErrorRate(:,2));
   Interaction_cACC = (cACC(:,3)-cACC(:,4)) - (cACC(:,1)-cACC(:,2));

   
   cACC = ACC./RT*10000;
   cRT = RT./ACC;
   %integrative index 把每个人的四个条件融合为一个值
   Interaction_ACC = (ACC(:,4)-ACC(:,3)) - (ACC(:,2)-ACC(:,1));
   Interaction_RT = (RT(:,3)-RT(:,4)) - (RT(:,1)-RT(:,2));
   MainEmotion_RT = (RT(:,1)+RT(:,3))-(RT(:,2)+RT(:,4));
   MainEmotion_ACC = (ACC(:,1)+ACC(:,3))-(ACC(:,2)+ACC(:,4));
   MainCognition_RT = (RT(:,3)+RT(:,4))-(RT(:,1)+RT(:,2));
   MainCognition_ACC = (ACC(:,3)+ACC(:,4))-(ACC(:,1)+ACC(:,2));
   
   Interaction_cACC = (cACC(:,4)-cACC(:,3)) - (cACC(:,2)-cACC(:,1));
   Interaction_cRT = (cRT(:,3)-cRT(:,4)) - (cRT(:,1)-cRT(:,2));
   MainEmotion_cRT = (cRT(:,1)+cRT(:,3))-(cRT(:,2)+cRT(:,4));
   MainEmotion_cACC = (cACC(:,1)+cACC(:,3))-(cACC(:,2)+cACC(:,4));
   MainCognition_cRT = (cRT(:,3)+cRT(:,4))-(cRT(:,1)+cRT(:,2));
   MainCognition_cACC = (cACC(:,3)+cACC(:,4))-(cACC(:,1)+cACC(:,2));
   
   
   
   
   