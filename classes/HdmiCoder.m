classdef HdmiCoder < handle
    
    methods  
        function encodedSignal8b = encode(~, signalToEncode)
            
            i = 1;
            signalToEncode = Helper.appendToAlign8(signalToEncode);
            while i+1 <= signalToEncode.getSize()
                frameXor = zeros(8, 1);
                frameXnor = zeros(8, 1);
                for j = 0 : 7
                    if i+j <= signalToEncode.getSize()
                        frameXor(j+1) = signalToEncode.getBit(i+j);
                        frameXnor(j+1) = signalToEncode.getBit(i+j);
                    end
                end

                for j = 2 : 8
                    frameXor(j) = xor(frameXor(j-1), frameXor(j));
                    frameXnor(j) = ~xor(frameXnor(j-1), frameXnor(j));
                end
                    
                xorChanges = 0;
                xnorChanges = 0;
                
                for j = 0 : 7
                    if signalToEncode.getBit(i+j) ~= frameXor(j+1)
                        xorChanges = xorChanges + 1;
                    end
                    
                    if signalToEncode.getBit(i+j) ~= frameXnor(j+1)
                        xnorChanges = xnorChanges + 1;
                    end
                end
                
                if xorChanges < xnorChanges                   
                    zerosXor = 0;
                    
                    for j = 1 : 8
                       if frameXor(j) == 0
                           zerosXor = zerosXor + 1;
                       end
                    end
                    
                    currStats = (zerosXor+1) / 9;
                    newStats = (8 - zerosXor + 1) / 9;
                    
                    if abs(0.5 - currStats) > abs(0.5 - newStats)
                        signalToEncode.insertBit(i+7, 1);
                        for j = 1 : 8
                            if frameXor(j) == 0
                                frameXor(j) = 1;
                            else
                                frameXor(j) = 0;
                            end
                        end
                    else
                        signalToEncode.insertBit(i+7, 0);
                    end
                    
                    for j = 0 : 7
                        signalToEncode.setBitV(i+j, frameXor(j+1));
                    end
                    signalToEncode.insertBit(i+7, 0);
                    
                else
                    zerosXnor = 0;
                    
                    for j = 1 : 8
                       if frameXnor(j) == 0
                           zerosXnor = zerosXnor + 1;
                       end
                    end
                    
                    currStats = zerosXnor / 9;
                    newStats = (8 - zerosXnor) / 9;
                    
                    if abs(0.5 - currStats) > abs(0.5 - newStats)
                        signalToEncode.insertBit(i+7, 1);
                        for j = 1 : 8
                            if frameXnor(j) == 0
                                frameXnor(j) = 1;
                            else
                                frameXnor(j) = 0;
                            end
                        end
                    else
                        signalToEncode.insertBit(i+7, 0);
                    end
                    
                    for j = 0 : 7
                        signalToEncode.setBitV(i+j, frameXnor(j+1));
                    end
                    signalToEncode.insertBit(i+7, 1);
                end               
                i = i + 10;
            end
            
            encodedSignal8b = signalToEncode;
        end 
    end
end