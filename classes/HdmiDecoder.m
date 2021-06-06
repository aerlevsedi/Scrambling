classdef HdmiDecoder < handle

    properties (Access = private)
        errorFlag
    end

    methods
        function decodedSignal = decode(obj, signal)
            obj.errorFlag = false;

            signalSize = signal.getSize();
            numberOfFrames = floor(signalSize/10);
            decodedSignal = Signal(numberOfFrames*8);
            
            if mod(signalSize, 10) ~= 0
               obj.errorFlag = true; 
            end
            
            k = 1;
            i = 1;
            while i < signalSize
                if signal.getBit(i+9) == 1
                    for j = 0 : 7
                       signal.negBit(i+j);
                    end
                end
                % TODO: check if it should be inverted (stats)
                
                decodedSignal.setBitV(k, signal.getBit(i));
                
                if signal.getBit(i+8) == 1
                    for j = 1 : 7
                        decodedSignal.setBitV(k+j, ~xor(signal.getBit(i+j-1), signal.getBit(i+j)));
                    end
                else
                    for j = 1 : 7
                        decodedSignal.setBitV(k+j, xor(signal.getBit(i+j-1), signal.getBit(i+j)));
                    end
                end
                
                k = k + 8;
                i = i + 10;
            end
        end

        function o = wasGood(obj)
            o = not(obj.errorFlag);
        end
    end
end
