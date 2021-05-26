classdef EthernetDecoder < handle
    
    properties (Access = private)
        errorFlag,
    end
    
    methods
        function decodedSignal = decode(obj, signal)
            obj.errorFlag = false;
            
            signalSize = signal.getSize();
            numberOfFrames = floor(signalSize/66);
            decodedSignal = Signal(numberOfFrames*64);
            
            k = 1; % decodedSignal iterator
            i = 1;
            while i < signalSize
                if signal.getBit(i) ~= 0 || signal.getBit(i+1) ~= 1
                    obj.errorFlag = true;
               
                    % resync
                else
                    i = i + 2;
                end
                    
                limit = i + 64;
                while  i <= signalSize && i < limit
                    decodedSignal.setBitV(k, signal.getBit(i));
                    k = k + 1;
                    i = i + 1;
                end
            end
        end
        
        function o = wasGood(obj)
            o = not(obj.errorFlag);
        end
        
    end
    
end