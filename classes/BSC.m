classdef BSC < handle

    properties
        signal
        probability % crossover probability
    end

    methods
        function obj = BSC()
            obj.signal = [];
            obj.probability = 0;
        end

        function setProb(obj, prob)
            obj.probability = prob;
        end

        function send(obj, signal)
            obj.signal = signal.copy;
        end

        function o = receive(obj)
            if isempty(obj.signal)
                o = Signal(0);
            else
                o = obj.signal;

                for i = 1 : o.getSize()
                    if rand < obj.probability
                        o.negBit(i);
                    end
                end

                obj.signal = [];
            end
        end
    end
end
