function gonogo1
% Based on Shaping State 2, but now we introduce catch trials!

% Tobias Otto
% 1.1
% 09.10.2017


%% Init toolbox
start

%% Init variables
trial.num           = 150;    % Number of trials
trial.catch         = 0;     % Change here if you want to add catch trial
trial.initTime      = 5;   % Time in s to peck on the init key
trial.initKeyPos	= 2;    % Number of the init key
trial.initPeck      = 1;    % Number of required pecks on the init stimulus
trial.initDelay     = 0;    % Delay between init peck and the following stimulus

trial.stimTime      = 5;   % Time in s to peck on the stimulus
trial.stimKeyPos    = 2;    % Position of the stimulus
trial.stimPeck      = 1;    % Required number of pecks on the stimulus
trial.feeding       = 0.05;    % Time
trial.timePunish      = 2;        % Time in s for punishment

trial.iti           = 10;

tmp                 = inputdlg('Pigeon #');
trial.pigeon        = tmp{1};
trial.savePath      = '.\Result';

% More variables
result              = 0;

%% Check inputs

if(trial.num < 40)
    error('Number of trials must be at least 40! I give up!');
end

%% Compute buffer
% Define go (1), nogo (2) and catch-go (3), catch-nogo (4)
% No catch trials in the beginning (3 trials) and in the end (6 trials)

% Compute position for catch trials
catchPos = sort(randomOrder(trial.num-2*6, trial.catch))+6;

% Set buffer
trial.buffer = zeros(1, trial.num);
% Copy catch trials
trial.buffer(catchPos) = randomOrder(2, trial.catch)+2;
% Copy go and nogo trials
trial.buffer(trial.buffer==0) = randomOrder(2, trial.num-trial.catch);

%% Init window
openNetworkIO;
initWindow(2);

try
    %% Load stimuli
    snd         = loadSound('.\Sound\init.wav');
    imInit      = loadImage('.\Stimuli\white.png');
    imStimGo    = loadImage('.\Stimuli\green.png');
    imStimNogo  = loadImage('.\Stimuli\red.png');
    
    rewsnd = loadSound('.\Sound\error.wav');

d = msgbox('Place window');
waitfor(d);
bIO(5,1);
bIO(2,1);
bIO(4,1);
    %% Start main loop
    for i=1:trial.num
        %% Present init key and wait
        controlSound(snd);
        showStimuli(imInit, trial.initKeyPos);
        out(i).initPeck = keyBuffer(trial.initTime, 'goodKey', trial.initKeyPos, trial.initPeck);
        
        %% Continue after a peck
        if(out(i).initPeck.goodKey == trial.initPeck)
            %% Clear screen and wait
            showStimuli;
            % Lets wait before we present the stimulus
            pause(trial.initDelay);
            
            %% Show stimulus and wait for a response
            if(trial.buffer(i) == 1)
                showStimuli(imStimGo, trial.stimKeyPos);
                % Wait for a response
                out(i).stimPeck     = keyBuffer(trial.stimTime, 'goodKey', trial.stimKeyPos, trial.stimPeck);
                out(i).catchPeck  	= keyBuffer(0);
            elseif(trial.buffer(i) == 2)
                showStimuli(imStimNogo, trial.stimKeyPos);
                % Wait for a response
                out(i).stimPeck     = keyBuffer(trial.stimTime, 'badKey', trial.stimKeyPos, trial.stimPeck);
                out(i).catchPeck  	= keyBuffer(0);
            elseif(trial.buffer(i) == 3)
                showStimuli(imStimGo, trial.stimKeyPos);
                % Wait for a response
                out(i).catchPeck    = keyBuffer(trial.stimTime, 'goodKey', trial.stimKeyPos, trial.stimPeck);
                out(i).stimPeck     = keyBuffer(0);
            elseif(trial.buffer(i) == 4)
                showStimuli(imStimNogo, trial.stimKeyPos);
                % Wait for a response
                out(i).catchPeck    = keyBuffer(trial.stimTime, 'badKey', trial.stimKeyPos, trial.stimPeck);
                out(i).stimPeck     = keyBuffer(0);
            end
            
            %% Reward or not
            % Clear screen
            showStimuli;
            
            % Reward or not
            if(out(i).stimPeck.goodKey == trial.stimPeck)
                controlSound(rewsnd)
                feeding(trial.feeding);
                result = 1;
                catchT = 0;
            elseif(out(i).stimPeck.badKey > 0)
                punishment(trial.timePunish);
                result = -1;
                catchT = 0;
            elseif(out(i).catchPeck.goodKey > 0)
                result = 0;
                catchT = 1;
                pause(trial.feeding)
            elseif(out(i).catchPeck.badKey > 0)
                result = 0;
                catchT = -1;
                pause(trial.feeding)
            else
                pause(trial.feeding)
                result = 0;
                catchT = 0;
            end
        else
            % Copy zeros to result struct
            out(i).stimPeck     = keyBuffer(0);
            out(i).catchPeck	= keyBuffer(0);
            result              = 0;
            catchT              = 0;
        end
        
        %% ITI and save additional information
        showStimuli;
        pause(trial.iti);
        
        % Save more
        out(i).res      = result;
        out(i).catch    = catchT;
    end

bIO(5,1);
bIO(2,1);
bIO(4,1);
    %% Compute results
    % Get valid trials
    sumGoTrials         = sum(trial.buffer == 1);
    sumNoGoTrials       = sum(trial.buffer == 2);
    sumCatchGoTrials    = sum(trial.buffer == 3);
    sumCatchNogoTrials	= sum(trial.buffer == 4);
    
    initPeck        = [out.initPeck];
    index           = [initPeck.goodKey] == trial.initPeck;
    validBuffer     = trial.buffer(index);
    validStimPeck	= [out(index).stimPeck];
    validCatchPeck  = [out(index).catchPeck];
    
    
    
    % Get all valid go and nogo trials
    if(sum(index) ~= 0)
        validGoAns              = validStimPeck(validBuffer == 1);
        validNoGoAns            = validStimPeck(validBuffer == 2);
        validCatchGoAns      	= validCatchPeck(validBuffer == 3);
        validCatchNogoAns      	= validCatchPeck(validBuffer == 4);
        correctGoTrials         = sum([validGoAns.goodKey] == trial.stimPeck)/sumGoTrials*100;
        correctNoGoTrials       = 100 - sum([validNoGoAns.badKey] == 1)/sumNoGoTrials*100;
        correctCatchGoTrials	= sum([validCatchGoAns.goodKey] == trial.stimPeck)/sumCatchGoTrials*100;
        correctCatchNogoTrials	= 100 - sum([validCatchNogoAns.badKey] == trial.stimPeck)/sumCatchNogoTrials*100;
        
        % Save all to result struct
        res.sumGoTrials             = sumGoTrials;
        res.sumNoGoTrials           = sumNoGoTrials;
        res.sumCatchTrials          = sumCatchGoTrials;
        %         res.sumValidGoTrials        = sum([validGoAns.goodKey] == trial.stimPeck);
        %         res.sumValidNoGoTrials      = sum([validNoGoAns.goodKey] == 0);
        %         res.sumValidCatchGoTrials 	= sum([validCatchGoAns.goodKey] == trial.stimPeck);
        %         res.sumValidCatchNogoTrials =
        res.validGoAns              = validGoAns;
        res.validNoGoAns            = validNoGoAns;
        res.validCatchAns           = validCatchGoAns;
        res.correctGoTrials         = correctGoTrials;
        res.correctNoGoTrials       = correctNoGoTrials;
        res.correctCatchGoTrials	= correctCatchGoTrials;
        res.correctCatchNogoTrials	= correctCatchNogoTrials;
    else
        correctGoTrials             = 0;
        correctNoGoTrials           = 0;
        correctCatchTrials          = 0;
        res.sumGoTrials             = sumGoTrials;
        res.sumNoGoTrials           = sumNoGoTrials;
        res.sumCatchTrials          = sumCatchGoTrials;
        %         res.sumValidGoTrials        = 0;
        %         res.sumValidNoGoTrials      = 0;
        %         res.sumValidCatchTrials     = 0;
        res.validGoAns              = 0;
        res.validNoGoAns            = 0;
        res.validCatchAns           = 0;
        res.correctGoTrials         = 0;
        res.correctNoGoTrials       = 0;
        res.correctCatchGoTrials	= 0;
        res.correctCatchNogoTrials	= 0;
    end
    
    %% Save results
    save2File(out, trial, res, 'subject', trial.pigeon, 'path', trial.savePath);
    
    %% Clean up and user info
    closeWindow;
    closeNetworkIO;
    %% User info
    disp(' -------------------------------------------');
    disp([' Pigeon: ' trial.pigeon]);
    disp([' Number of total go trials: ' num2str(sumGoTrials)]);
    disp([' Number of total nogo trials: ' num2str(sumNoGoTrials)]);
    disp([' Number of total catch go trials: ' num2str(sumCatchGoTrials)]);
    disp([' Number of total catch nogo trials: ' num2str(sumCatchNogoTrials)]);
    %     disp([' Number of valid go trials: ' num2str(res.sumValidGoTrials)]);
    %     disp([' Number of valid nogo trials: ' num2str(res.sumValidNoGoTrials)]);
    %     disp([' Number of valid catch go trials: ' num2str(res.sumValidCatchTrials)]);
    %     disp([' Number of valid catch nogo trials: ' num2str(res.sumValidCatchTrials)]);
    disp([' Correct go trials: ' num2str(correctGoTrials) '%']);
    disp([' Correct nogo trials: ' num2str(correctNoGoTrials) '%']);
    disp([' Correct catch go trials: ' num2str(correctCatchGoTrials) '%']);
    disp([' Correct catch nogo trials: ' num2str(correctCatchNogoTrials) '%']);
    
catch
    closeWindow;
    bioErrorSave
end