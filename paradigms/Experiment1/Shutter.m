classdef Shutter
    properties
        leftPin = 2
        rightPin = 4
        open = 1
        close = 0
    end
    methods
        function obj = Shutter()
            obj.openAndClose(obj.open, obj.open)
        end
        
        function openAndClose(obj, leftState, rightState)
            bIO(obj.leftPin, leftState);
            bIO(obj.rightPin, rightState);
        end
    end
end