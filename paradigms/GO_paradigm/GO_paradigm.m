function shapingStage1
% Experiment shapingStage1 --> see document from Catrona

% Tobias Otto
% 1.0
% 12.07.2017

% 12.07.2017, Tobias: first draft
%% Init toolbox
start

%% Init variables
trial.num           = 150;    % Number of trials can be changed here
trial.initTime      = 5;   % Presentation time of the init stimulus in seconds
trial.initKeyPos	= 2;    % The position of the key
trial.initPeck      = 1;    % Number of required pecks on the init stimulus
trial.initDelay     = 0;    % Delay between init peck and the following stimulus

trial.stimTime      = 5;   % Time in s to peck on the stimulus
trial.stimKeyPos    = 2;    % The position of the key
trial.stimPeck      = 1;    % Required number of pecks on the stimulus
trial.feeding       = 0.05;    % Feeding time in seconds, 0.05 deliver one food pellet
trial.iti           = 10; #Iti in seconds

tmp                 = inputdlg('Pigeon #');
trial.pigeon        = tmp{1};
trial.savePath      = '.\Result';

%% Init toolbox
openNetworkIO;
initWindow(2);

%% Load stimuli
snd = loadSound('.\Sound\init.wav');
imInit = loadImage('.\Stimuli\white.png');
imStim = loadImage('.\Stimuli\green.png');
rewsnd = loadSound('.\Sound\Windows XP Error.wav');

d = msgbox('Place window');
waitfor(d);
bIO(5,1)
%% Start main loop
for i=1:trial.num
    %% Present init key and wait
    controlSound(snd);
    showStimuli(imInit, trial.initKeyPos);
    out(i).initPeck = keyBuffer(trial.initTime, 'goodKey', trial.initKeyPos, trial.initPeck);
    
    %% Continue after a peck
    if(out(i).initPeck.goodKey == 1)
        %% Clear screen and wait
        showStimuli;
        % Lets wait before we present the stimulus
        pause(trial.initDelay);
        
        %% Show stimulus and wait for a response
        showStimuli(imStim, trial.stimKeyPos);
        out(i).stimPeck = keyBuffer(trial.stimTime, 'goodKey', trial.stimKeyPos, trial.stimPeck);
        
        %% Reward or not
        % Clear screen
        showStimuli;
        
        % Reward or not
        if(out(i).stimPeck.goodKey == trial.stimPeck)
            controlSound(rewsnd)
            feeding(trial.feeding);
            result = 1;
        else
            pause(trial.feeding);
            result = 0;
        end
    else
        % Copy zeros to result struct
        out(i).stimPeck.ans     = 0;
        out(i).stimPeck.rt      = 0;
        out(i).stimPeck.count   = 0;
        result                  = 0;
    end
    bIO(5,1)
    %% ITI and more user info
    showStimuli;
    pause(trial.iti);
    
    % Save more
    out(i).res = result;
end

%% Save results
save2File(out, trial, 'subject', trial.pigeon, 'path', trial.savePath);

%% Clean up
% Close stimulus window
closeWindow;
closeNetworkIO;

% User info
disp(' -------------------------------------------');
disp(['   Correct trials: ' num2str(sum([out.res] == 1)/trial.num*100) '%']);