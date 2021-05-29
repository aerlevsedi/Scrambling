classdef EthernetDecoder < handle

    properties (Access = private)
        errorFlag,
        numberOfPreambles = 2,
        rangeOfPreambles = 2
    end

    methods
        function decodedSignal = decode(obj, signal)
            obj.errorFlag = false;

            signalSize = signal.getSize();
            numberOfFrames = floor(signalSize/66);
            decodedSignal = Signal(numberOfFrames*64);

            k = 1; % decodedSignal iterator
            i = 1;
            while i < signalSize
                if signal.getBit(i) ~= 0 || signal.getBit(i+1) ~= 1
                    obj.errorFlag = true;
                    i = obj.resync(signal, i);
                else
                    i = i + 2;
                end

                limit = i + 64;
                while  i <= signalSize && i < limit
                    decodedSignal.setBitV(k, signal.getBit(i));
                    k = k + 1;
                    i = i + 1;
                end
            end
        end

        function o = wasGood(obj)
            o = not(obj.errorFlag);
        end

        function preambleIndex = resync(obj, signal, errorIndex)
            preamblesIndexes = zeros(2 * obj.numberOfPreambles);
            preamblesScores = zeros(2 * obj.numberOfPreambles);

            for i = 1 : 2 * obj.numberOfPreambles
                preamblesScores(i) = -1;
            end

            % check left side
            index = errorIndex - 1;
            foundPreamblesLeft = 0;

            while index >= 1 && foundPreamblesLeft < obj.numberOfPreambles
                while index >= 1
                    if signal.getBit(index) == 0 && signal.getBit(index + 1) == 1
                        break
                    end
                    index = index - 1;
                end

                if index >= 1
                    foundPreamblesLeft = foundPreamblesLeft + 1;
                    preamblesIndexes(foundPreamblesLeft) = index;

                    score = 0;
                    checkedIndex = index - 66;
                    while checkedIndex >= 1
                        score = score + obj.checkPreambles(signal, checkedIndex);
                        checkedIndex = checkedIndex - 66;
                    end
                    while checkedIndex < signal.getSize()
                        score = score + obj.checkPreambles(signal, checkedIndex);
                        checkedIndex = checkedIndex + 66;
                    end

                    preamblesScores(foundPreamblesLeft) = score;
                    index = index - 1;
                end
            end

            % check right side
            index = errorIndex + 1;
            foundPreamblesRight = 0;

            while index < signal.getSize() && foundPreamblesRight < obj.numberOfPreambles
                while index < signal.getSize()
                    if signal.getBit(index) == 0 && signal.getBit(index + 1) == 1
                        break
                    end
                    index = index + 1;
                end
                if index < signal.getSize()
                    foundPreamblesRight = foundPreamblesRight + 1;
                    preamblesIndexes(foundPreamblesLeft + foundPreamblesRight) = index;

                    score = 0;
                    checkedIndex = index - 66;
                    while checkedIndex >= 1
                        score = score + obj.checkPreambles(signal, checkedIndex);
                        checkedIndex = checkedIndex - 66;
                    end
                    while checkedIndex < signal.getSize()
                        score = score + obj.checkPreambles(signal, checkedIndex);
                        checkedIndex = checkedIndex + 66;
                    end

                    preamblesScores(foundPreamblesLeft + foundPreamblesRight) = score;
                    index = index + 1;
                end
            end

            % find best preamble
            mostPreambles = -1;
            bestIndex = -1;
            for i = 1 : 2 * obj.numberOfPreambles
                if preamblesScores(i) > mostPreambles
                    mostPreambles = preamblesScores(i);
                    bestIndex = i;
                end
            end

            preambleIndex = preamblesIndexes(bestIndex);
        end

        function bestPreambleScore = checkPreambles(obj, signal, i)
            bestPreambleScore = -1;

            left = i - obj.rangeOfPreambles;
            right = 2 * obj.rangeOfPreambles + left;

            if left < 1
                left = 1;
            end

            while left < signal.getSize() && left <= right
                if signal.getBit(left) == 0 && signal.getBit(left + 1) == 1
                    preambleScore = obj.rangeOfPreambles - abs(i - left);
                    if preambleScore > bestPreambleScore
                        bestPreambleScore = preambleScore;
                    end
                end
                left = left + 1;
            end
        end
    end
end
