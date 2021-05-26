classdef RandomGenerator
    %RANDOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        duplProb; % duplicate probability
    end
    
    methods
        function o = generate(obj, signalSize)
            o = Signal(signalSize);
            
            % custom rand
            % first bit - normal random
            currentBit = round(rand());
            o.setBitV(1, currentBit);

            % other bits
            for i = 2 : signalSize 
                if rand() < obj.duplProb
                    o.setBitV(i, currentBit);
                else
                    currentBit = ~currentBit;
                    o.setBitV(i, currentBit);
                end
            end
        end
    end
end