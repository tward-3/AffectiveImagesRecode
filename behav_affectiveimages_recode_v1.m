function behav_affectiveimages_recode_v1

%PURPOSE:           Recode triggers for Affective Images (aka IAPS pics) from DevMIND 3.0.
%
%REQUIRED INPUTS:   EVT files for recoding DevMIND 3.0 AffectiveImages triggers.
%
%		    
%
%NOTES:            
%		   
%
%
%                  
%AUTHOR:            Thomas W. Ward, DICoN Lab, Institute for Human Neuroscience- BTNRH 
%VERSION HISTORY:   9/10/2024  v1: First working version of program
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%-Recoded Trigger Legend-%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fixation = 30
% negative image = 21
% positive image = 31
% oddball = 40
% missed oddball = 9931
% late oddball = 9921
% BAD trials = 555

% NOTE: "BAD" trials are those in which the button response to the oddball
% occurred late (i.e., after the fixation of the nex trial), and thus that
% trial's fixation (i.e., baseline) is "contaminated" by the response.
% A late oddball means they responded but not  in time. 
% Missed oddball means they did not respond at all.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dbstop if error

[files,path,~] = uigetfile('*.evt','Please Select EVTs','Multiselect','on');    %select evt files%

evt_header = 'Tmu         	Code	TriNo';    %create header for evt files%
    
cd(path);  
if isa(files,'char')        %set number of iterations based on whether there is one or multiple files%
    iter = 1;
else
    iter = length(files);
end

behavior.number_correctoddball =  NaN(iter,1);
behavior.number_incorrectoddball =  NaN(iter,1);
behavior.contaminated = NaN(iter,1);
behavior.positive_image = NaN(iter,1);
behavior.negative_image = NaN(iter,1);
behavior.contamination_mismatch = NaN(iter,1);
behavior.ACC = NaN(iter,1);
behavior.RT = NaN(iter,1);
behavior.firsttime = NaN(iter,1);

for i = 1:iter      %loop for files%
    if isa(files,'char')        %read evt data for file i%
        data = readBESAevt(files);
    elseif length(files) > 1
        data = readBESAevt(files{i});
    else
        error('No compatible files selected!')
    end
    
    triggers = data(:,3);
    time = data(:,1);
    
    RT = NaN(1,length(triggers));
    correct_counter = 0;
    incorrect_counter = 0;
    contaminated_counter = 0;
    positive_counter = 0;
    negative_counter = 0;
    contamination_mismatch = 0;
    
    
    for ii = 2:length(triggers)-1  %add stim triggers to 4096 by combining 4096 with triggers immediately preceding
        if triggers(ii) == 4096
            triggers(ii) = 4096 + triggers(ii-1);
            triggers(ii-1) = 999999;
        elseif (triggers(ii) == 4127 && triggers(ii+1) == 4127 && (time(ii+1)-time(ii)) < 13000) %get rid of duplicates
            triggers(ii) = 888888;
        elseif (triggers(ii) == 4126 && triggers(ii+1) == 4126 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii) = 888888;  
        elseif (triggers(ii) == 4117 && triggers(ii+1) == 4117 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii) = 888888;
        elseif (triggers(ii) == 4136 && triggers(ii+1) == 4136 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii) = 888888;
        elseif (triggers(ii) == 40 && triggers(ii+1) == 4136 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii) = 888888;
        elseif (triggers(ii) == 4096 && triggers(ii+1) == 4127 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii) = 888888;
        elseif (triggers(ii) == 4096 && triggers(ii+1) == 4117 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii) = 888888;
        elseif (triggers(ii) == 31 && triggers(ii+1) == 4127 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii) = 888888;  
        elseif (triggers(ii) == 21 && triggers(ii+1) == 4117 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii) = 888888;   
        elseif (triggers(ii) == 31 && triggers(ii+1) == 100 && (time(ii+1)-time(ii)) < 13000) %fixing manual recode
            triggers(ii+1) = 888888;  
        elseif (triggers(ii) == 21 && triggers(ii+1) == 100 && (time(ii+1)-time(ii)) < 13000)
            triggers(ii+1) = 888888;
        elseif triggers(ii) == 4658 
            triggers(ii) = 512; 
        elseif triggers(ii) == 4402
            triggers (ii) = 256;
        elseif triggers(ii) == 4099
            triggers (ii) = 888888;
        end
    end
    
    %Delete unneeded triggers 999999 and stim triggers before propix (61 or 62) from data%
    time(triggers==999999) = [];  
    triggers(triggers==999999) = [];
    time(triggers==61) = [];                     
    triggers(triggers==61) = [];
    time(triggers==62) = [];                     
    triggers(triggers==62) = [];
    time(triggers==4096) = [];                     
    triggers(triggers==4096) = [];
    time(triggers==888888) = [];                     
    triggers(triggers==888888) = [];
    time(triggers==50) = [];                     
    triggers(triggers==50) = [];
    time(triggers==4146) = [];                     
    triggers(triggers==4146) = [];
    time(triggers==7936) = [];                     
    triggers(triggers==7936) = [];
        
    for ii = 1:length(triggers)
        if (triggers(ii) > 2000 && triggers(ii) < 7000)
            triggers(ii) = triggers(ii)-4096;
        else
        end
    end
   
    
    %Recoding the triggers for oddballs
    for ii = 1:length(triggers)-1     
        if triggers(ii) == 40 %Oddball
            if  triggers(ii+1) ==  256 %If the next trigger after oddball stim is a button press, then correct
                triggers(ii) = 40;
                correct_counter = correct_counter+1;
                RT(1,ii) = (time(ii+1)-time(ii))/1000;
            elseif triggers(ii+1) == 30 && triggers(ii+2) == 256
                triggers(ii) = 9921; %late oddball, but "correct" for purposes of accuracy
                correct_counter = correct_counter+1;
            elseif triggers(ii+1) == 30 && triggers(ii+2) ~= 256
                triggers(ii) = 9931; %missed oddball; no response (incorrect)
                incorrect_counter = incorrect_counter+1;
            end
        end
    end   
    
    %Recoding the trial AFTER a late oddball responses- contaminated/"BAD"
    for ii = 1:length(triggers)-1     
        if triggers(ii) == 9921 && triggers(ii+2) == 256 %Oddball + response after next fixation
            if  triggers(ii+1) ==  30 %late response
                triggers(ii+3) = 555;
                contaminated_counter = contaminated_counter+1;
            end
        end
    end
    
    %Setting up trial counters- sanity check (output in Behav.txt)
     for ii = 1:length(triggers)-1     
        if triggers(ii) == 30 && triggers(ii+1) == 31 %positive image
            positive_counter = positive_counter+1;
        end
     end
     for ii = 1:length(triggers)-1     
        if triggers(ii) == 30 && triggers(ii+1) == 21 %negative image
            negative_counter = negative_counter+1;
        end
     end       
     for ii = 1:length(triggers)-1     
        if triggers(ii) == 8222 && triggers(ii+1) == 31 %positive image
            positive_counter = positive_counter+1;
        end
     end
     for ii = 1:length(triggers)-1     
        if triggers(ii) == 8222 && triggers(ii+1) == 21 %negative image
            negative_counter = negative_counter+1;
        end
     end    
     firsttime = time(1,1); %Since the first trial doesnt have a fixation, need to be able to count it towards total trial count
     for ii = 1:length(triggers)-1     
        if triggers(ii) == 21 && time(ii) == firsttime %negative image
            negative_counter = negative_counter+1;
        end
     end         
     
     
    %looking for any weird triggers
    a = [9931 9921 21 22 23 24 30 31 32 33 34 40 256 555 8222];
    if sum(~ismember(triggers,a))>0  
        filetag = '_recoded_check.evt';
    else
        filetag = '_recoded.evt';
    end
    
    
    RT(isnan(RT)) = [];
    if isa(files,'char')
        fprintf('Recoded %d trials for file %s\n',size(RT,2),files);
    else
        fprintf('Recoded %d trials for file %s\n',size(RT,2),files{i});
    end
    
    
    %Additional sanity check- if total clean trial count makes sense (1 if no, 0 if yes)
        if positive_counter + negative_counter ~= (190 - contaminated_counter)
            contamination_mismatch = contamination_mismatch+1;
        end    
    
        
    %Writing behavioral output
    if size(RT,2) > 1 
        behavior.number_correctoddball(i,1) = (correct_counter);
        behavior.number_incorrectoddball(i,1) = (incorrect_counter);
        behavior.contaminated(i,1) = (contaminated_counter);
        behavior.positive_image(i,1) = (positive_counter);
        behavior.negative_image(i,1) = (negative_counter);
        behavior.contamination_mismatch(i,1) = (contamination_mismatch);
        behavior.ACC(i,1) = (correct_counter/19);
        behavior.RT(i,1) = mean(RT,2);
        behavior.firsttime(i,1) = (firsttime);
    end
    
    
    %Writing recoded EVTs
    evt_info = [time,data(1:size(time,1),2),triggers];
    if isa(files,'char')
        filename = strcat(files(1,1:end-4),filetag);
    else
        filename = strcat(files{i}(1,1:end-4),filetag);                             
    end
    fid = fopen(filename,'wt');
    fprintf(fid,'%s\n',evt_header);
    fclose(fid);
    dlmwrite(filename,evt_info,'delimiter','\t','-append','precision','%.0f');

    
%Outputting behavioral results    
t = struct2table(behavior);
writetable(t, 'Behav.txt', 'FileType', 'text', 'Delimiter', '\t')
end

