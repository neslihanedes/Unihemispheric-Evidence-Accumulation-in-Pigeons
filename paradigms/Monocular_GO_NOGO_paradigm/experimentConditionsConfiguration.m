% Trial numbers
par.numBinoTrials       = 60;   % Define how many binocular trials you give
par.numBinoCatchTrials  = 0;    % Change here if you want to give catch trials
par.numProbeTrials      = 0;   % Number of probe trials, better to use Experiment1 and Experiment2 for probe trial extension
par.numMonoTrialsL      = 30;   % Number of monocular trials LEFT
par.numMonoTrialsR      = 30;   % Number of monocular trials RIGHT

% Time settings and number of pecks, position
par.timeITI         = 10;       % ITI time in seconds
par.timeInit        = 5;       % Time in seconds to peck on init key
par.peckInit        = 1;        % Number of peck on init key
par.timeDelay       = 0;        % Time in seconds between init key and stimuli
par.timeStimulus    = 5;        % Time in seconds to peck on stimulus
par.peckStimulus    = 1;        % Number of pecks on stimulus
par.timeReward      = 0.05;        % Time in s for reward
par.timePunish      = 2;        % Time in s for punishment
par.posStimuli      = 2;       % The position of the key

% Helmet settings
par.shutterLeft     = 2;        % Number of IO box for left shutter
par.shutterRight    = 4;        % Number of IO box for left shutter
par.shutterOn       = 0;        % Logical to turn shutter on
par.shutterOff      = 1;        % Logical to turn shutter off

% Probe trial settings
par.probeDelay      = (1:6)/10;  % Delay units between go and nogo, however we use Experiment 1 and 2 for the probe trials

% Technical infos
par.info            = getBasicInformation;
par.savePath        = '.\Result\';
par.stimuli         = '.\Stimuli\';
par.expID           = 2018001;
tmp                 = inputdlg('Pigeon # ');
par.subject         = tmp{1};