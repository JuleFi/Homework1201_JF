try
    % graues Fenster erstellen 
    Screen('Preference', 'SkipSyncTests', 0);  
   
    myScreen = 0;
    [myWindow, rect] = Screen('OpenWindow', myScreen, [128 128 128], [0 0 940 680]); 
    
    white = WhiteIndex(myWindow);
    black = BlackIndex(myWindow);
    gray  = (white+black)/2;
    
    % herunterlgeladene Bilder definieren
    knownFiles ={ ...
        'stimuli/known_1.png','stimuli/known_2.png','stimuli/known_3.png', ...
        'stimuli/known_4.png','stimuli/known_5.png','stimuli/known_6.png'};

    unknownFiles ={ ...
        'stimuli/unknown_1.png','stimuli/unknown_2.png','stimuli/unknown_3.png','stimuli/unknown_4.png'};

    allFiles = [knownFiles unknownFiles];
    
 
    % Bildgröße & Position 
    w = 300; % hier hab ich ausprobiert, sodass die Bilder möglichst unverzerrt sind 
    h = 300;
    xCenter = rect(3)/2;
    yCenter = rect(4)/2;
    dstRect = [xCenter - w/2, yCenter - h/2, xCenter + w/2, yCenter + h/2];

    % Tasten bestimmen 
    keyKnown = KbName('c');
    keyUnknown = KbName ('b');
    keyAbort = KbName('Return'); % jederzeit ist ein Abbrechen möglich 
    
    
    % Willkommen/ Erklärung 
    Screen('TextSize', myWindow, 26);
    DrawFormattedText(myWindow, ...
        ['Willkommen!\n\n' ...
         'In diesem Experiment sehen Sie Gesichter.\n\n' ...
         'Drücken Sie eine beliebige Taste, um fortzufahren.'], ...
        'center', 'center', white);
    Screen('Flip', myWindow);
KbWait;
KbReleaseWait;    
    
    % Tasten erklären 
    DrawFormattedText(myWindow, ...
        ['Bitte entscheiden Sie, ob Sie die Person kennen.\n\n' ...
         'Taste C = bekannte Person\n' ...
         'Taste B = unbekannte Person\n\n' ...
         'Antworten Sie möglichst schnell und genau.\n\n' ...
         'Beliebige Taste = Start'], ...
        'center', 'center', white);
    Screen('Flip', myWindow);
   
KbWait;
KbReleaseWait;
WaitSecs(0.2);

    
    % Experiment starten 
    
    nTrials = 50;
    RTs = NaN(1,nTrials); % Vektor für Reaktionzeit erstellen 
   
for t = 1:nTrials 

    % zufällige Bilder 
    if rand < 0.5 % em ende ingesamt 50:50 Chance für bekannte vs unbekanntes Gesicht
        file = knownFiles {randi(length(knownFiles))}; % aus allen known Datein auswählen
        trueLabel = 1; 
    else
        file = unknownFiles{randi(length(unknownFiles))}; 
        trueLabel = 0; 
    end 
   
 
    % Fixationskreuz 
        Screen('FillRect', myWindow, gray); % grauer Hintergund 
        Screen('TextSize', myWindow, 80); % Größe vom Keuz 
        DrawFormattedText(myWindow, '+', 'center', 'center', black); % + in die Mitte 
        Screen('Flip', myWindow); % sichtbar machen 
        WaitSecs(0.9); % Kreuz bleibt 900ms sichtbar 
        
        
    % Maske erstellen, um Verarbeitung des Gesichtes einzugrenzen 
        noiseSize = 250;
        noiseImg  = rand(noiseSize, noiseSize) * 255;
        maskTex   = Screen('MakeTexture', myWindow, noiseImg);

        Screen('FillRect', myWindow, gray);
        maskRect = [xCenter-noiseSize/2 yCenter-noiseSize/2 xCenter+noiseSize/2 yCenter+noiseSize/2];
        Screen('DrawTexture', myWindow, maskTex, [], maskRect);
        Screen('Flip', myWindow);

        WaitSecs(0.3); % Maske ist 300ms sichtbar 
        
    % Gesicht soll kurz erscheinen (500ms)
        imgdata   = imread(file);
        myTexture = Screen('MakeTexture', myWindow, imgdata);

        Screen('FillRect', myWindow, gray);
        Screen('DrawTexture', myWindow, myTexture, [], dstRect);
        
        vbl = Screen('Flip', myWindow); % vbl = Stimulus Onset Zeitpunkt mit hoher Präzision 
        tStart = vbl; % ab diesem Moment soll die Reaktion gezählt werden
         
        WaitSecs(0.5); 

  
     % nach dem Gesicht soll das Fenster wieder grau werden    
        Screen('FillRect', myWindow, gray);
        Screen('Flip', myWindow);

        
     % C drücken bei bekannt, B drücken bei unbekannt 
        resp = NaN;  % Antwort 1 bekannt, 0 unbekannt 
        rt = NaN; % Reaktionszeit in Sekunden 
        
        while 1
            [keyIsDown, tPress, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(keyAbort)
                    Screen('CloseAll');
                    return;
                    
                elseif keyCode(keyKnown)
                    resp = 1; % bekannt
                    rt = tPress - tStart; % Reaktionszeit 
                    break;
                elseif keyCode(keyUnknown)
                    resp = 0; % unbekannt
                    rt = tPress - tStart; % Reaktionszeit 
                    break;
                end
            end
        end
    
    RTs(t) = rt; % die Reaktionszeit soll in den Vektor geschrieben werden (dann kann ich die später im CommandWindow abfragen)
        
    Screen('Close',myTexture); 
    Screen ('Close', maskTex);
    
    KbReleaseWait;
    WaitSecs(0.2);
end 


meanRT = mean(RTs);
disp(meanRT)

 
% Endfolie 
Screen('TextSize', myWindow, 26); % Textgröße wieder klein machen, da sie vom Fixationskreuz größer definiert wurde
DrawFormattedText(myWindow, ...
        'Vielen Dank!\n\nExperiment beendet.\n\nBeliebige Taste zum Beenden.', ...
        'center', 'center', white);
    Screen('Flip', myWindow);
    KbWait;

    Screen('CloseAll');

    
catch ME
    Screen('CloseAll');
    disp(ME.message);
end
   
% mean(RT) erscheint automatisch im Command Window
% RTs kann ich pro Bild angezeigt bekommen bei Befehl  
      