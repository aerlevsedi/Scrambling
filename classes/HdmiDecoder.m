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
               a1 = signal.getBit(signalSize-1);
               a2 = signal.getBit(signalSize);
               
               signal = Helper.appendToAlign10(signal);
               
               signal.setBitV(signalSize-1, 0);
               signal.setBitV(signalSize, 0);
               
               signal.setBitV(signal.getSize() - 1, a1);
               signal.setBitV(signal.getSize(), a2);
               signalSize = signal.getSize();
            end
            
            k = 1;
            i = 1;
            while i < signalSize
                if signal.getBit(i+9) == 1
                    for j = 0 : 7
                       signal.negBit(i+j);
                    end
                end
                
                frame = zeros(8, 1);
                for j = 0 : 7
                    if i+j <= signal.getSize()
                        frame(j+1) = signal.getBit(i+j);
                    end
                end
                
                zerosCount = 0;
                    
                for j = 1 : 8
                    if frame(j) == 0
                        zerosCount = zerosCount + 1;
                    end
                end
                
                if signal.getBit(i+9) == 0
                    current = (zerosCount+1) / 9;
                    inverted = (8 - zerosCount + 1) / 9;
                else
                    current = (zeros) / 9;
                    inverted = (8 - zerosCount) / 9;
                end
                
                    
                if abs(0.5 - current) > abs(0.5 - inverted)
                    if signal.getBit(i+9) == 1
                        obj.errorFlag = true;
                    end
                else
                    if signal.getBit(i+9) == 0
                        obj.errorFlag = true;
                    end
                end
                
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
