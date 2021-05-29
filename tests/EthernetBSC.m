randomGenerator = RandomGenerator();
encoder = EthernetCoder();
decoder = EthernetDecoder();
scrambler = Scrambler();
descrambler = Descrambler();
channel = BSC();

testIterations = 1000;
randomSignalSize = 500;
randomGenerator.duplProb = 0.7;
channel.probability = 0.01;

BERClean = 0;
BERResync = 0;
BERResyncScrambling = 0;


for i = 1 : testIterations
    signalOrg = randomGenerator.generate(randomSignalSize);
    % no resync, no scrambling
    signal = signalOrg.copy();

    channel.send(signal);
    signal = channel.receive();

    BERClean = BERClean + Helper.calculateBER(signalOrg, signal);

    % resync, no scrambling
    signal = signalOrg.copy();

    signal = encoder.encode(signal);
    channel.send(signal);
    signal = channel.receive();
    signal = decoder.decode(signal);

    BERResync = BERResync + Helper.calculateBER(signalOrg, signal);

    % resync, scrambling
    signal = signalOrg.copy();
    scrambler.resetLFSR();
    descrambler.resetLFSR();

    signal = scrambler.scramble(signal);
    signal = encoder.encode(signal);
    channel.send(signal);
    signal = channel.receive();
    signal = decoder.decode(signal);
    signal = descrambler.descramble(signal);

    BERResyncScrambling = BERResyncScrambling + Helper.calculateBER(signalOrg, signal);

end

BERClean = BERClean / testIterations;
BERResync = BERResync / testIterations;
BERResyncScrambling = BERResyncScrambling / testIterations;

disp("Clean : " + BERClean);
disp("Resync: " + BERResync);
disp("Resync, scrambling: " + BERResyncScrambling);
