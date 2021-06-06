classdef EthernetCoder < handle
    
    methods  
        %signalToCode argument's size is 64 bit aligned 
        function encodedSignal = encode(~, signalToEncode)
            
            i = 0;
            while i+1 <= signalToEncode.getSize()
                signalToEncode.insertBit(i, 0);
                signalToEncode.insertBit(i+1, 1);
                
                i = i + 66;
            end
            
            encodedSignal = signalToEncode;
        end 
    end
end