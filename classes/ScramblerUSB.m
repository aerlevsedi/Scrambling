classdef ScramblerUSB < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        seed
        LFSR
    end
    
    methods
        function obj = ScramblerUSB(seed)
            if(nargin == 0)
                obj.seed  = [0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1];%randi([0 1],1,59);
                obj.LFSR = obj.seed;
            else
                obj.seed = seed;
                obj.LFSR = seed;
            end
        end
        
        function o = scramble(obj, signalToScramble)
            for i = 1:signalToScramble.getSize()
                x = xor(obj.LFSR(1,1), xor(obj.LFSR(1,4), xor(obj.LFSR(1,5), xor(obj.LFSR(1,6), obj.LFSR(1,17)))));
                x = xor(signalToScramble.getBit(i), x);
                signalToScramble.setBitV(i, x);

                obj.LFSR = [signalToScramble.getBit(i), obj.LFSR(1:end-1)];
                
                o = signalToScramble;
            end
        end
        
        function disp(obj)
            disp("Scrambler USB LFSR: ");
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