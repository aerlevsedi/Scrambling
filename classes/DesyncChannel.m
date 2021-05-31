classdef DesyncChannel < handle

    properties
        signal
        periodicBits, periodicStart, periodicInterval
        singleBits,
        desyncType, desyncBreakpoint
    end

    methods
        function obj = DesyncChannel()
            obj.signal = [];
            obj.periodicBits = 0;
            obj.periodicStart = 0;
            obj.periodicInterval = 0;
            obj.singleBits = [];
            obj.desyncType = 0;
            obj.desyncBreakpoint = 0;
        end

        function send(obj, signal)
            obj.signal = signal.copy;
        end

        function o = receive(obj)
            if isempty(obj.signal)
                o = Signal(0);
            else
                o = obj.signal;

                obj.periodicErrors(o);
                obj.singleErrors(o);
                obj.desyncErrors(o);

                obj.signal = [];
            end
        end
    end

    methods (Access = private)
        function periodicErrors(obj, signal)
            if obj.periodicBits == 0
                return;
            end

            interval = false;
            buf = 0;

            for i = 1 : signal.getSize()
                if i >= obj.periodicStart
                    if interval
                        buf = buf + 1;
                        if buf == obj.periodicInterval
                            interval = false;
                            buf = 0;
                        else
                            if buf > obj.periodicInterval
                                signal.negBit(i);
                                interval = false;
                                buf = 0;
                            end
                        end
                    else
                        if tmp ~= obj.periodicBits
                            signal.negBit(i);
                            buf = 0;
                        end
                    end
                end
            end
        end

        function singleErrors(obj, signal)
            for i = 1 : size(obj.single)
                if obj.singleBits(i) <= -1 && obj.singleBits(i) >= -(signal.getSize())
                    signal.negBit(signal.getSize() + obj.singleBits(i) + 1);
                else
                    if obj.singleBits(i) >= 1 && obj.singleBits(i) <= signal.getSize()
                        signal.negBit(obj.singleBits(i));
                    end
                end
            end
        end

        function desyncErrors(obj, signal)
            if obj.desyncType == 0 || obj.desyncBreakpoint == 0
                return;
            end

            repeat = -1;
            counter = 0;

            i = 1;
            while i <= signal.getSize()
                if signal.getBit(i) == repeat
                    counter = counter + 1;
                else
                    counter = 0;
                end

                if counter == obj.desyncBreakpoint
                    if obj.desyncType == 1
                        signal.insertBit(i, repeat);
                        i = i + 1;
                    else
                        if obj.desyncType == -1
                            signal.removeBit(i);
                            i = i - 1;
                        else
                            if obj.desyncType == 2
                                if round(rand())
                                    signal.insertBit(i, repeat);
                                    i = i + 1;
                                else
                                    signal.removeBit(i);
                                    i = i - 1;
                                end
                            end
                        end
                        counter = 0;
                    end
                    i = i + 1;
                end
            end
        end
    end
end
