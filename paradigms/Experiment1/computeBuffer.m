function par = computeBuffer(par)
% This function computes all buffers that are necessary for the experiment

% Tobias Otto
% 1.1
% 25.04.2018


%% Check inputs
if(mod(par.numProbeTrials,12) ~= 0)
    error('The number of probe trials have to be a multiple of 12');
end

if(mod(par.numBinoProbeTrials,6) ~= 0)
    error('The number of bino probe trials have to be a multiple of 6');
end

if(mod(par.numBinoTrials,2) ~= 0)
    error('The number of binocular trials has to be even!');
end

if(mod(par.numMonoTrialsL,2) ~= 0)
    error('The number of monocular left trials has to be even!');
end

if(mod(par.numMonoTrialsR,2) ~= 0)
    error('The number of monocular right trials has to be even!');
end

if(mod(par.numBinoCatchTrials,2) ~= 0)
    error('The number of binocular catch trials left has to be even!');
end

%% Compute buffers
% Define trials
% 1 --> bino trial good
% 2 --> bino trial bad
% 3 --> mono trial left good
% 4 --> mono trial left bad
% 5 --> mono trial right good
% 6 --> mono trial right bad
% 7 --> probe trial left
% 8 --> probe trial right
% 9 --> catch trial good
% 10--> catch trial bad
% 11--> probe bino

% Compute total number of trials
par.num = par.numBinoTrials + par.numMonoTrialsL + par.numMonoTrialsR ...
          + par.numProbeTrials + par.numBinoCatchTrials + par.numBinoProbeTrials;

% maxrepeat effectively deactivated to allow using single trial
% A cleaner workaround would be better...
buf = randomOrder(11, par.num, 'ratio', ...
    [par.numBinoTrials/2, par.numBinoTrials/2, ...
    par.numMonoTrialsL/2, par.numMonoTrialsL/2 ,...
    par.numMonoTrialsR/2, par.numMonoTrialsR/2, ...
    par.numProbeTrials/2 par.numProbeTrials/2, ...
    par.numBinoCatchTrials/2 par.numBinoCatchTrials/2, par.numBinoProbeTrials] / par.num, 'maxrepeat', 100, 'nowarning');

% Compute delays for probe trials
timL = repmat(par.probeDelay, 1, par.numProbeTrials/12);
timL = timL(randperm(length(timL)));
timR = repmat(par.probeDelay, 1, par.numProbeTrials/12);
timR = timR(randperm(length(timR)));
timBino = repmat(par.probeDelay, 1, par.numBinoProbeTrials/6);
timBino = timBino(randperm(length(timBino)));

%% Copy buffers to matrix
% 1 row: trial definitions
% 2 row: delay between go and nogo in probe trials
% 3 row: position of goodKey
%
out               	= zeros(2, length(buf));
out(1, :)        	= buf;
out(2, buf == 7)	= timL;    % Copy only time for mono left
out(2, buf == 8) 	= timR;    % Copy only time for mono right
out(2, buf == 11) 	= timBino;   

% Finally copy to par struct
par.buffer = out;