classdef Shutter < handle
    properties
        leftPin = 2
        rightPin = 4
        open = 1
        close = 0

        leftState = 1
        rightState = 1
    end
    methods
        function obj = Shutter()
            obj.openAndClose(obj.open, obj.open)
        end
        
        function openAndClose(obj, leftState, rightState)
            obj.leftState = leftState;
            obj.rightState = rightState;

            obj.applyStateToIO();
        end

        function toggleLeftRight(obj)
            tmp = obj.leftState
            obj.leftState = obj.rightState
            obj.rightState = tmp

            obj.applyStateToIO();
        end

        function applyStateToIO(obj)
            bIO(obj.leftPin, obj.leftState);
            bIO(obj.rightPin, obj.rightState);
        end
    end
end