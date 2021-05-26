classdef UsbCoder < handle
    
    methods  
        function encodedSignal8b = encode(~, signalToEncode)
            
            i = 0;
            while i+1 <= signalToEncode.getSize()
                signalToEncode.insertBit(i, 0);
                signalToEncode.insertBit(i+1, 1);
                
                i = i + 10;
            end
            
            encodedSignal8b = signalToEncode;
        end 
    end
end