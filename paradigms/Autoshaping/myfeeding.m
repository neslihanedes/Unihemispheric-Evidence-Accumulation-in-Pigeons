function result = myfeeding(time,light,varargin)

% modification of feeding; in addition to feeding, it automatically
% activates feederlight
%
% This is a helper function that is useful as a reward after a task was
% successfully finished. This function uses the feeder specified in mySetup
% to feed the animal and clears the screen automatically. More than one
% feeder is supported, but than the feeder has to be specified. During 
% feeding the behavioral responses of the animal are recorded and available 
% in the output variable.
% 
% OUTPUTS           
%  * time       : duration of feeding
% 
% INPUTS-OPTIONAL
%   * feeder    : Defines a specific feeder to use for feeding. Usefull
%                 if more than one feeder is available. The number that is
%                 used as argument is the index that points to the pin
%                 number, given in section 3 of mySetup.
%
%   * dontclear : Keeps the content on the screen. 
%
% OUTPUTS           
%  * result         : struct containing responses recurded during feeding
%
% EXAMPLES 
% 1. 
% result = feeding(time,varargin)
% 
% 2. 
%   result = feeding(5); 
%   Feeds the animal for 5 seconds
% 3. 
%   result = feeding(1.2,'dontclear'); 
%   Feeds the animal for 1.2 seconds and keeps the screen content
%
% 4. 
%   result = feeding(2,'feeder',1); 
%   Feeds for 2 seconds on feeder 1, where feeder 1 ist the first
%   listed feeder in mySetup.m
%
% 5.
%   result = feeding(6,'feeder',2);
%   Feeds for 5 seconds on feeder 2, where feeder 2 ist the second
%   listed feeder in mySetup.m
%
% Copyright 2007-2008 
% CC-GNU GPL by attribution 
% Please cite the BioPsychology Toolbox where this function is used. 
%       http://biopsytoolbox.sourceforge.net/
% 
% See also:  punishment, bIO

% Tobias Otto, Jonas Rose
% Version 0.3.1
% 06.11.08

% 17.04.08, Tobias: Release version
% 18.04.08, Tobias: Changed call of optional argument feeder
% 04.06.08, jonas : Update of documentation
% 06.11.08, Tobias: Tobias: Checks, if a monitor is used

% TODO: Decide if more than one feeder should be allowed -> problem during
%       initialiation 


%% We need access to the skinner box
global SETUP;    
global WINDOW;

%% Init variables
feeder = 1;
clearScreen = 1;

%% Get variable input arguments to change the default values
if nargin > 1
    i=1;
    while(i<=length(varargin))
        switch lower(varargin{i})
            case 'feeder'
                feeder      = varargin{i+1};
                i           = i+2;
                if(length(feeder) > length(SETUP.io.feeder))
                    disp(' ================================================');
                    disp(' You are trying to use a feeder that doesn not ');
                    disp(' exist. Please correct this in  mySetup.m');
                    disp(' in section 3.');
                    disp(' ================================================');
                    error('Please solve problem and try again');
                end
            case 'dontclear'
                clearScreen = 0;
                i           = i+1;
            otherwise
                disp(['Unknown argument: ' varargin(i)]);
                i = i+1;
        end
    end
end


%% Write info to control box
set(WINDOW.control.text(4).handle,'string','Starting feeding');

% Clear screen
if(clearScreen && ~isempty(WINDOW.stimulus.handle))
    showStimuli;
end

% Start feeding
bIO([SETUP.io.feeder SETUP.io.feederLight],[1 1]);
% bIO([SETUP.io.feeder(feeder) SETUP.io.feederLight],[1 1]);

% Call buffer function
result = myKeyBuffer(time);

% Stop feeding and/or lighting
if light > time
bIO([SETUP.io.feeder SETUP.io.feederLight],[0 1]);
myKeyBuffer(light-time);
bIO([SETUP.io.feeder SETUP.io.feederLight],[0 0]);
else
bIO([SETUP.io.feeder SETUP.io.feederLight],[0 0]);    
end

% Write info to control box
set(WINDOW.control.text(4).handle,'string','Stop feeding');
