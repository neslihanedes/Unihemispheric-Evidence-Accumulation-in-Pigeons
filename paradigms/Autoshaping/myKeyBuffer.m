function total = myKeyBuffer(duration,varargin)

% MODIFIED BY NILS TO REFER TO myTouchBuffer instead of touchBuffer
%
% function total = keyBuffer(duration, ...)
% 
% This buffer stores behavioral responses over a period of time specified in duration.
% In addition, it terminates if a specified number of responses on "good keys" or "bad
% keys" is reached. To use this feature specify at least the position of
% the good or bad keys and the number of responses. This function can be used
% either with a touchscreen or wih input-keys. Internally it will call the 
% switchBuffer or the touchBuffer respectively. 
%
% For auditory feedback use the 'sound' option. It plays a previously
% loaded sound file for every response.
%
% 
% INPUTS            
%   * duration      : The time to wait unless defined number of responses has been reached before
% 
% INPUTS-OPTIONAL   
%  * 'goodKey'      : vector of pin numbers and scalar of response amount
%                   
%  * 'badKey'       : vector of pin numbers and scalar of response amount 
%
%  * 'sound'        : a wav file handle, loaded with loadSound.
%
%  * 'confirm'      : vector containing the keys for which sound is played
%  
%
% OUTPUTS           
%  * total          :  A struct containing all possible information 
%    .raw           -> A matrix containing time and position of responses
%    .goodKey       -> A vector containing the sumary of all responses on good keys
%    .badKey        -> A vector containing the sumary of all responses on bad keys
%    .start         -> Start time of the function
%    .stop          -> Stop time of the function
% 
% EXAMPLES 
% 1.
%   result = keyBuffer(10,'goodKey',[1 2],3);
%           % keyBuffer terminates after 10 seconds OR after three 
%           % responses on keys at position 1 or 2. All other responses are  
%           % buffered, but don't terminate the keyBuffer
% 2.
% 	result = keyBuffer(10,'badKey',[3 4],8,'goodKey',[1 2],3);
%           % keyBuffer terminates after 10 seconds OR after three 
%           % responses on keys at position  1 or 2 OR after eight 
%           % responses on keys at position  3 or 4
%
% 3.
% 	result = keyBuffer(4,'badKey',3,3,'goodKey',[1 2],3, 'sound', soundH);
%           % keyBuffer terminates after 4 seconds OR after three 
%           % responses on keys at position  1 or 2 OR after three 
%           % responses on keys at position  3. In addition every answer is
%           % rewarded with a sound that was loaded with loadSound and
%           % saved into the variable soundH.
% 
%       
% 
% Copyright 2007-2008 
% CC-GNU GPL by attribution 
% Please cite the BioPsychology Toolbox where this function is used. 
%       http://sourceforge.net/projects/biopsytoolbox/
% 
% See also: touchBuffer, bIO, keyBufferConcVI

% VERSION HISTORY:
% Author:         Tobias Otto, Jonas Rose
% Version:        0.4.2
% Last Change:    24.09.2008
%
% 22.04.2008: tobias: first draft
% 22.04.2008: jonas : documentation, function header
% xx.05.2008: Tobias: added touchscreen support
% 16.05.2008: Tobias: Renamed struct output
% 04.06.2008: jonas : minor addition to the documentation
% 12.06.2008: Tobias: changed help from pinnr to switch position (keybuffer
%                     now awaits key positions as input)
%                     NOW INCOMPATIBLE TO OLDER VERSIONS !!!!
% 25.08.2009, Tobias: Added sound option and documentation
% 24.09.2009, Tobias: Added keyBufferConcVI to See also in user help.

%% BUGS/ TODO
% * Update documentation for touchscreen, including the mySetup.m part
%   where the number of the input switch and the number of the "picture"
%   have to be the same!

%% Get access to global struct
global SETUP

%% Go
% keyBuffer is a wrapper function that simply calls switchBuffer for direct
% hardware calls or touchbuffer for touchscreens
if(SETUP.touchScreen.on == 0)
    total = switchBuffer(duration,varargin{:});
else
    total = myTouchBuffer(duration,varargin{:});
end
    

