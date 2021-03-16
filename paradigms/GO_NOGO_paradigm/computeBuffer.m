function trial = computeBuffer(trial)
% This function handles the buffers for catch trial position and the
% different catch trial types
%
% Trial type (defined how to start sequence and what to present)
% 3 --> go: left open / right closed   --> nogo: left closed / right open
% 4 --> go: right open / left closed   --> nogo: right closed / left open
% 5 --> nogo: left open / right closed --> go: left closed / right open
% 6 --> nogo: right open / left closed --> go: right closed / left open

%% Compute cat trial positions
% Define go (1), nogo (2) and catch-go (3:6)
% No catch trials in the beginning (10 trials) and in the end (10 trials)

% Compute position for catch trials
catchPos = 1:5;
while(any(diff(catchPos) == 1))
    catchPos = sort(randomOrder(trial.num-2*10, trial.catch, 'maxRepeat', 1, 'nowarning'))+10;
end

% Set buffer
trial.buffer = zeros(1, trial.num);
% Copy catch trials
trial.buffer(catchPos) = mod(randperm(trial.catch),4) + 3;
% Copy go and nogo trials
trial.buffer(trial.buffer==0) = randomOrder(2, trial.num-trial.catch);
