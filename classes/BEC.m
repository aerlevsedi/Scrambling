classdef BEC < handle

    properties
        signal
        probability % erasure probability
    end

    methods
        function obj = BEC()
            obj.signal = [];
            obj.probability = 0;
        end

        function send(obj, signal)
            obj.signal = signal.copy;
        end

        function o = receive(obj)
            if isempty(obj.signal)
                o = Signal(0);
            else
                o = obj.signal;

                i = 1;
                size = o.getSize();

                while i < size
                    if rand < obj.probability
                        o.removeBit(i);
                        size = o.getSize();
                    end
                    i = i + 1;
                end

                obj.signal = [];
            end
        end
    end
end
