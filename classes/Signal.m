classdef Signal < handle
    %SYGNAL klasa reprezentujaca n-bitowy sygnal
    %   bity indeksowane sa od 1 do n
    
    properties (Access = private) 
        bits, size;
    end
    
    methods
        function obj = Signal(arg)
            if nargin ~= 0
                if isnumeric(arg)
                    
                    obj.size = arg;
                    obj.bits = logical.empty;
                    for k = 1 : arg
                        obj.bits(k) = false;
                    end
                    
                elseif strcmp(arg, 'voice')
                    
                    FileName = 'mbi04czap.wav';
                    fid  = fopen(FileName, 'r');
                    data2 = fread(fid, [1, Inf], 'uint8');
                    fclose(fid);
                    bity = uint8(rem(floor((1 ./ [128, 64, 32, 16, 8, 4, 2, 1].') * data2), 2));
                    bity = bity(:);
                    obj.size = length(bity);
                    obj.bits = bity;
                        
                elseif strcmp(arg, 'sinus') 
                                            
                    FileName = 'mbi04czap.wav';
                    fid  = fopen(FileName, 'r');
                    data2 = fread(fid, [1, Inf], 'uint8');
                    fclose(fid);
                    bit = uint8(rem(floor((1 ./ [128, 64, 32, 16, 8, 4, 2, 1].') * data2), 2));
                    bit = bit(:);
                    obj.size = length(bit);
                    obj.bits = bit;
                    
                    %file = importdata(arg);
                    %obj.size = file(1);
                    %obj.bits = logical.empty;
                    %for k = 2 : obj.size+1
                    %    if file(k)==0
                    %        obj.bits(k-1) = false;
                    %    else
                    %        obj.bits(k-1) = true;
                    %    end
                    %end
                    
                end
            else
                obj.size = 0;
            end
        end
        
        function o = copy(obj)
            o = Signal(obj.size);
            for k = 1 : o.size
            	o.bits(k) = obj.bits(k);
            end
        end
        
        function o = getSize(obj)
        	o = obj.size;
        end
        
        function o = getBit(obj, i)
        	if i >= 1 && i<=obj.size
                if obj.bits(i)
                    o = 1;
            	else
                    o = 0;
                end
            else
                disp("Error: Signal is " + obj.size + "-bit! (getBit)");
                o = [];
        	end
        end
        
        function setBit(obj, i)
        	if i >= 1 && i<=obj.size
                obj.bits(i) = true;
            else
                % disp("Error: Signal is " + obj.size + "-bit! (setBit)");
        	end
        end
        
        function clearBit(obj, i)
        	if i >= 1 && i<=obj.size
                obj.bits(i) = false;
            else
                % disp("Error: Signal is " + obj.size + "-bit! (clearBit)");
        	end
        end
        
        % negacja i-tego bitu sygnalu
        function negBit(obj, i)
        	if i >= 1 && i<=obj.size
                if obj.bits(i)
                    obj.bits(i) = false;
            	else
                    obj.bits(i) = true;
                end
            else
                % disp("Error: Signal is " + obj.size + "-bit!");
        	end
        end
         
        function setBitV(obj, i, v)
        	if v == 0
                obj.clearBit(i);
        	else
                obj.setBit(i);
        	end
        end
        
        function insertBit(obj, afterBit, v)
            firstPart = obj.bits(1:afterBit);
            secondPart = obj.bits(afterBit + 1:obj.size);
            
            obj.bits = [firstPart false secondPart];
            obj.size = obj.size + 1;
            
            obj.setBitV(afterBit+1,v);
        end
        
        function removeBit(obj, bit)
            firstPart = obj.bits(1:bit-1);
            secondPart = obj.bits(bit+1:obj.size);
            
            obj.bits = [firstPart secondPart];
            obj.size = obj.size - 1;
        end
        
        function o = decValue(obj)
            o = 0;
        	for i = 1 : obj.size
                o = o + (2^(i-1))*(obj.getBit(i));
        	end
        end
        
        function disp(obj)
            fprintf("[");
            for i = 1 : obj.size
               fprintf("%d ", obj.bits(i));
            end
            fprintf("\b]\n");
        end
        
        function o = toString(obj)
            o = string();
            for i = 1 : obj.size
                if obj.bits(i) == true
                    o = strcat(o,'1');
                else
                    o = strcat(o,'0');
                end
            end
        end
    end
end