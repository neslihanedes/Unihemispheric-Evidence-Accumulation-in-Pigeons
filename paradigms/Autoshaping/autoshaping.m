function autoshaping
% Autoshaping

% Tobias Otto

%% Init variables
trial.num       = 100;  % Number of trials can be changed here
trial.iti       = 10;    % Iti in seconds
trial.stimPres  = 5;    % Presentation time of the stimulus in seconds
trial.feeding   = 0.05;    % Feeding time in seconds, 0.05 deliver one food pellet
trial.peckKey   = [2];    % Input of pecking for autoshaping

% Define output for init and stopSig stimulus
trial.iniPin	= 5;

% Nothing to do here
tmp             = inputdlg({'Pigeon#'});
trial.subject   = tmp{1};
trial.date      = clock;
trial.savePath  = '.\Result\';

%% Init toolbox and experiment
start;
openNetworkIO;
initWindow(2);
startExperiment;

% Load images and sound: you can manipulate here depending on which image or sound(or no sound) desired to use.
go  = loadImage('.\Stimuli\white.png');

% Make sure the sound files exist
snd = loadSound('.\Sound\init.wav');
rewsnd = loadSound('.\Sound\error.wav');

% Wat for user to place stimulus window
d = msgbox('Place window');
waitfor(d);
bIO(5,1);
%% Compute buffer to control experiment
% This buffer is needed to use one autoshaping program for either one or
% two keys

% Check user input
if(length(trial.peckKey) > 2)
    closeWindow;
    clc;
    error('Only two pecking keys are allwed !!!')
end

if(length(trial.peckKey) == 1)
    trial.buffer = ones(1,trial.num)*trial.peckKey;
else
    tmp = randomOrder(2,trial.num);
    trial.buffer(tmp==1) = trial.peckKey(1);
    trial.buffer(tmp==2) = trial.peckKey(2);
end

%% Start loop
for i=1:trial.num
    %% Wait during ITI
    out(i).iti = keyBuffer(trial.iti);
    
    %% Show stimulus and play sound
    controlSound(snd);
    if(trial.buffer(i) ~= 4)
        % Show stimulus on screen
        showStimuli(go, trial.buffer(i));
    else
        % Turn on init stimulus
        bIO(trial.iniPin, 1);
    end
    
    %% Check input
    out(i).ans = keyBuffer(trial.stimPres, 'goodKey', trial.buffer(i), 1);
    
    %% Clear screen
    if(trial.buffer(i) ~= 4)
        % Clear screen
        showStimuli;
    else
        % Turn on init stimulus
        bIO(trial.iniPin, 0);
    end
    
    %% Feed anyway
    controlSound(rewsnd)
    myfeeding(trial.feeding,2);
end

%% Save results
save2File(trial, out, 'subject', [trial.subject '_autoshaping'], 'path', trial.savePath);

%% Clean up
closeWindow;
closeNetworkIO;


%% Plot some user info
p = [out.ans];

disp('------------------------------------------------------------------');
disp([' Pigeon           	: ' trial.subject]);
disp([' Number of trials	: ' num2str(trial.num)]);
disp([' Pecks               : ' num2str(sum([p.goodKey])/trial.num*100) '%']);
disp([' Pecks on key (' num2str(trial.peckKey) ')   : ' num2str(sum(reshape([p.goodKey], length(p), size(p(1).goodKey,2)))/trial.num*100) '%']);

