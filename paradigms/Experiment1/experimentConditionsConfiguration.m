% Trial numbers
par.numBinoTrials       = 40;   % Define how many binocular trials you give
par.numBinoCatchTrials  = 0;    % Change here if you want to give catch trials
par.numProbeTrials      = 48;   % Number of mono probe trials (has to be a multiple of 12), change here depending on how many probe trials you want to give
par.numMonoTrialsL      = 0;   % Number of monocular trials LEFT
par.numMonoTrialsR      = 0;   % Number of monocular trials RIGHT
par.numBinoProbeTrials  = 24; % Number of bino probe trials, change here depending on how many bino probe trials you want to give


% Time settings and number of pecks, position
par.timeITI         = 10;       % Iti in seconds
par.timeInit        = 5;       % Presentation time of the init key in seconds
par.peckInit        = 1;        % Number of required pecks on the init stimulus
par.timeDelay       = 0;        % Delay between init peck and the following stimulus
par.timeStimulus    = 5;        % Time in s to peck on stimulus
par.peckStimulus    = 1;        % Number of pecks on stimulus
par.timeReward      = 0.05;        % Time in s for reward
par.timePunish      = 2;        % Time in s for punishment
par.posStimuli      = 2;

% Helmet settings
par.shutterLeft     = 2;        % Number of IO box for left shutter
par.shutterRight    = 4;        % Number of IO box for left shutter
par.shutterClosed   = 0;        % Logical to turn shutter on
par.shutterOpen      = 1;        % Logical to turn shutter off

% Probe trial settings
par.probeDelay1      = [0.125, 0.175, 0.225, 0.275, 0.325, 0.375]; % Delay units between go and nogo
par.probeDelay2      = (1:6)/10;% experiment alternates between probeDelay1 and probeDelay2
% Technical infos
par.info            = getBasicInformation;
par.savePath        = '.\Result\';
par.stimuli         = '.\Stimuli\';
par.expID           = 2018001;
tmp                 = inputdlg('Pigeon # ');
par.subject         = tmp{1};