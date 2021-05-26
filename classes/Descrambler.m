classdef Descrambler < handle
    
    properties (Access = private)
        seed
        LFSR
    end
    
    methods
        function obj = Descrambler(seed)
            if(nargin == 0)
                obj.seed  = [0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1];%randi([0 1],1,59);
                obj.LFSR = obj.seed;
            else
                obj.seed = seed;
                obj.LFSR = seed;
            end
        end
        
        function o = descramble(obj, signalToDescramble)
            for i = 1:signalToDescramble.getSize()
                insertBit = signalToDescramble.getBit(i);
                x = xor(obj.LFSR(1,1), xor(obj.LFSR(1,40), obj.LFSR(1,59)));
                x = xor(insertBit, x);
                signalToDescramble.setBitV(i, x);

                obj.LFSR = [insertBit, obj.LFSR(1:end-1)];
                
                o = signalToDescramble;
            end
        end
        
        function disp(obj)
            disp("Descrambler LFSR");
            fprintf("[");
            for i = 1 : size(obj.LFSR,2)
               fprintf("%d ", obj.LFSR(i));
            end
            fprintf("\b]\n");
        end
        
        function resetLFSR(obj)
            obj.LFSR = obj.seed;
        end
        
    end
    
end