for i = 1 : 10
    randomGenerator = RandomGenerator();
    encoder = EthernetCoder();
    decoder = EthernetDecoder();
    seed = randi([0 1],1,59);
    scrambler = ScramblerEthernet(seed);
    descrambler = DescramblerEthernet(seed);
    channel = DesyncChannel();

    testIterations = 1000;
    randomSignalSize = 640 * i;
    randomGenerator.duplProb = 0;
    channel.desyncBreakpoint = 12;
    channel.desyncType = 2;

    BERClean = 0;
    BERResync = 0;
    BERResyncScrambling = 0;

    disp("Ethernet Desync for " + randomSignalSize + " size");

    for j = 1 : testIterations
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

    disp("Clean: " + BERClean);
    disp("Resync: " + BERResync);
    disp("Resync, scrambling: " + BERResyncScrambling);

end




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
