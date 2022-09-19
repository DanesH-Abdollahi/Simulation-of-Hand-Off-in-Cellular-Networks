%%
clc ; clear ; close all ;

%% Declare the various variables used for distances
R = 250 ;
L = 2 * R ;
Speed = 1 ; % m/sec
Sample_Time = 0.1 ; % Sampling Freq. = 10 Hz
Step_Distance = Speed * Sample_Time ;
g = 150 ;
Min_distance = sqrt(g) ;
Max_distance = L - sqrt(g) ;
d1 = Min_distance : Step_Distance : Max_distance ;
d2 = L - d1 ;
d3 = abs(R - d1) ;
d4 = abs(R - d1) ;
Step_Number = length(d1) ;
Threshold = -68 ; % dbm
H = 5 ; % Hysteresis [dbm]

%% Calculating Each Base Station RSS In All Points of MH Movement
Pt = 20 ; % Base station transmit power in dbm
Po = 38 ; % First mete r lossr in db
a = 2 ;
b = 2 ;
alpha = exp(-1/85) ;
sigma1 = sqrt(8) ;
sigma2 = sqrt(sigma1^2 * (1 - alpha^2)) ;

RSS01 = Pt - Po - ( 10 * a * log10(d1) + 10 * b * log10(d1/g) ) ;
RSS02 = Pt - Po - ( 10 * a * log10(d2) + 10 * b * log10(d2/g) ) ;
RSS_corner = Pt - Po - ( 10 * a * log10(R) + 10 * b * log10(R/g) ) ;
RSS03 = RSS_corner - ( 10 * a * log10(d3) + 10 * b * log10(d3/g) ) ;
RSS04 = RSS_corner - ( 10 * a * log10(d4) + 10 * b * log10(d4/g) ) ;

for i = 1 : Step_Number
    if d3(i) < Min_distance
        RSS03(i) = RSS_corner ;
    end
    if d4(i) < Min_distance
        RSS04(i) = RSS_corner ;
    end
end
% Definig Pramaters To Store Each Loop RSS's
Mean_RSS01 = zeros(100 , Step_Number) ;
Mean_RSS02 = zeros(100 , Step_Number) ;
Mean_RSS03 = zeros(100 , Step_Number) ;
Mean_RSS04 = zeros(100 , Step_Number) ;
%% HandOff Decision Making
% Simulate The Procces 100 Times
Handoff_Counter = zeros(1 , 100) ;
Handoff_Location = [] ;

Handoff_Counter1 = zeros(1 , 100) ;
Handoff_Location1 = [] ;

Handoff_Counter2 = zeros(1 , 100) ;
Handoff_Location2 = [] ;

Handoff_Counter3 = zeros(1 , 100) ;
Handoff_Location3 = [] ;

% Simulating All 4 Algorithm for 100 Times
for ii = 1 : 100
    % Part 2: Adding the random variable for shadow fading
    s1 = zeros(1 , Step_Number) ;
    s2 = zeros(1 , Step_Number) ;
    s3 = zeros(1 , Step_Number) ;
    s4 = zeros(1 , Step_Number) ;

    s1(1) = sigma1 * randn(1) ;
    s2(1) = sigma1 * randn(1) ;
    s3(1) = sigma1 * randn(1) ;
    s4(1) = sigma1 * randn(1) ;

    for i = 2 : Step_Number
        s1(i) = alpha * s1(i-1) + sigma2 * randn(1) ;
        s2(i) = alpha * s2(i-1) + sigma2 * randn(1) ;
        s3(i) = alpha * s3(i-1) + sigma2 * randn(1) ;
        s4(i) = alpha * s4(i-1) + sigma2 * randn(1) ;
    end
    % Adding the shadow fading term to RSS
    RSS1 = RSS01 + s1 ;
    RSS2 = RSS02 + s2 ;
    RSS3 = RSS03 + s3 ;
    RSS4 = RSS04 + s4 ;

    % Handoff Procces Using RSS algorithm ( algorithm 1 )
    BS = ["BS1" , "BS2" , "BS3" , "BS4"] ;
    Current = BS(1) ;
    Counter = 0 ;
    for j = 1 : Step_Number
        RSS = [RSS1(j) , RSS2(j) , RSS3(j) , RSS4(j)] ;
        Max = max( RSS ) ;
        BS_Max = BS(  RSS == Max  ) ;

        if BS_Max == Current
            continue ;
        end

        % Handoff Action
        Current = BS_Max ;
        Counter = Counter + 1 ;
        Location(Counter) = d1(j) ; %#ok

    end
    Handoff_Counter(ii) = Counter ;
    Handoff_Location = [Handoff_Location , Location] ; %#ok
    clear Location ;

    % Handoff Procces Using RSS With Threshold algorithm ( algorithm 2 )
    BS = ["BS1" , "BS2" , "BS3" , "BS4"] ;
    Current = BS(1) ;
    Counter = 0 ;
    for j = 1 : Step_Number
        RSS = [RSS1(j) , RSS2(j) , RSS3(j) , RSS4(j)] ;
        if RSS( BS == Current ) > Threshold
            continue ;
        end

        Max = max( RSS ) ;
        BS_Max = BS(  RSS == Max  ) ;

        if BS_Max == Current
            continue ;
        end

        % Handoff Action
        Current = BS_Max ;
        Counter = Counter + 1 ;
        Location1(Counter) = d1(j) ; %#ok

    end
    Handoff_Counter1(ii) = Counter ;
    Handoff_Location1 = [Handoff_Location1 , Location1] ; %#ok
    clear Location1 ;

    % Handoff Procces Using RSS With Hysteresis In RSS algorithm ( algorithm 3 )
    BS = ["BS1" , "BS2" , "BS3" , "BS4"] ;
    Current = BS(1) ;
    Counter = 0 ;
    for j = 1 : Step_Number
        RSS = [RSS1(j) , RSS2(j) , RSS3(j) , RSS4(j)] ;
        Max = max( RSS )  ;
        BS_Max = BS(  RSS == Max ) ;

        if BS_Max == Current
            continue ;
        end

        if Max < RSS( BS == Current ) + H
            continue ;
        end

        % Handoff Action
        Current = BS_Max ;
        Counter = Counter + 1 ;
        Location2(Counter) = d1(j) ; %#ok

    end
    Handoff_Counter2(ii) = Counter ;
    Handoff_Location2 = [Handoff_Location2 , Location2] ; %#ok
    clear Location2 ;

    % Handoff Procces Using RSS With Hysteresis In RSS and Threshold algorithm ( algorithm 4 )
    BS = ["BS1" , "BS2" , "BS3" , "BS4"] ;
    Current = BS(1) ;
    Counter = 0 ;
    for j = 1 : Step_Number
        RSS = [RSS1(j) , RSS2(j) , RSS3(j) , RSS4(j)] ;
        if RSS( BS == Current ) > Threshold
            continue ;
        end

        Max = max( RSS )  ;
        BS_Max = BS(  RSS == Max ) ;

        if BS_Max == Current
            continue ;
        end

        if Max < RSS( BS == Current ) + H
            continue ;
        end

        % Handoff Action
        Current = BS_Max ;
        Counter = Counter + 1 ;
        Location3(Counter) = d1(j) ; %#ok

    end
    Handoff_Counter3(ii) = Counter ;
    Handoff_Location3 = [Handoff_Location3 , Location3] ; %#ok
    clear Location3 ;

    Mean_RSS01(ii,:) = RSS01 ;
    Mean_RSS02(ii,:) = RSS02 ;
    Mean_RSS03(ii,:) = RSS03 ;
    Mean_RSS04(ii,:) = RSS04 ;
end

% Calculating PDF's
Unique_Handoff_Counter = unique(Handoff_Counter) ;
PDF_Of_Count = zeros(1 , length(Unique_Handoff_Counter)) ;
for k = 1 : length(Unique_Handoff_Counter)
    PDF_Of_Count(k) = length( find( Handoff_Counter == Unique_Handoff_Counter(k) ) ) ;
end
PDF_Of_Count = PDF_Of_Count / length(Handoff_Counter) ;

Unique_Handoff_Location = unique(Handoff_Location) ;
PDF_Of_Loc = zeros(1 , length(Unique_Handoff_Location)) ;
for l = 1 : length(Unique_Handoff_Location)
    PDF_Of_Loc(l) = length( find( Handoff_Location == Unique_Handoff_Location(l) ) ) ;
end
PDF_Of_Loc = PDF_Of_Loc / length(Handoff_Location) ;

% Calculating and Plotting PDF's
Unique_Handoff_Counter1 = unique(Handoff_Counter1) ;
PDF_Of_Count1 = zeros(1 , length(Unique_Handoff_Counter1)) ;
for k = 1 : length(Unique_Handoff_Counter1)
    PDF_Of_Count1(k) = length( find( Handoff_Counter1 == Unique_Handoff_Counter1(k) ) ) ;
end
PDF_Of_Count1 = PDF_Of_Count1 / length(Handoff_Counter1) ;

Unique_Handoff_Location1 = unique(Handoff_Location1) ;
PDF_Of_Loc1 = zeros(1 , length(Unique_Handoff_Location1)) ;
for l = 1 : length(Unique_Handoff_Location1)
    PDF_Of_Loc1(l) = length( find( Handoff_Location1 == Unique_Handoff_Location1(l) ) ) ;
end
PDF_Of_Loc1 = PDF_Of_Loc1 / length(Handoff_Location1) ;

% Calculating and Plotting PDF's
Unique_Handoff_Counter2 = unique(Handoff_Counter2) ;
PDF_Of_Count2 = zeros(1 , length(Unique_Handoff_Counter2)) ;
for k = 1 : length(Unique_Handoff_Counter2)
    PDF_Of_Count2(k) = length( find( Handoff_Counter2 == Unique_Handoff_Counter2(k) ) ) ;
end
PDF_Of_Count2 = PDF_Of_Count2 / length(Handoff_Counter2) ;

Unique_Handoff_Location2 = unique(Handoff_Location2) ;
PDF_Of_Loc2 = zeros(1 , length(Unique_Handoff_Location2)) ;
for l = 1 : length(Unique_Handoff_Location2)
    PDF_Of_Loc2(l) = length( find( Handoff_Location2 == Unique_Handoff_Location2(l) ) ) ;
end
PDF_Of_Loc2 = PDF_Of_Loc2 / length(Handoff_Location2) ;

% Calculating and Plotting PDF's
Unique_Handoff_Counter3 = unique(Handoff_Counter3) ;
PDF_Of_Count3 = zeros(1 , length(Unique_Handoff_Counter3)) ;
for k = 1 : length(Unique_Handoff_Counter3)
    PDF_Of_Count3(k) = length( find( Handoff_Counter3 == Unique_Handoff_Counter3(k) ) ) ;
end
PDF_Of_Count3 = PDF_Of_Count3 / length(Handoff_Counter3) ;

Unique_Handoff_Location3 = unique(Handoff_Location3) ;
PDF_Of_Loc3 = zeros(1 , length(Unique_Handoff_Location3)) ;
for l = 1 : length(Unique_Handoff_Location3)
    PDF_Of_Loc3(l) = length( find( Handoff_Location3 == Unique_Handoff_Location3(l) ) ) ;
end
PDF_Of_Loc3 = PDF_Of_Loc3 / length(Handoff_Location3) ;


%% Calculatin Mean Of All Random Variables ( Number & Location Of Handoff )
% Calculatuing The Mean Of Number of Handoffs PMF ( PDF )
Num_Mean  = sum(PDF_Of_Count .* Unique_Handoff_Counter) ;
Num_Mean1 = sum(PDF_Of_Count1 .* Unique_Handoff_Counter1) ;
Num_Mean2 = sum(PDF_Of_Count2 .* Unique_Handoff_Counter2) ;
Num_Mean3 = sum(PDF_Of_Count3 .* Unique_Handoff_Counter3) ;
% Calculatuing The Mean Of Location of Handoffs PMF ( PDF )
Loc_Mean = sum(PDF_Of_Loc .* Unique_Handoff_Location) ;
Loc_Mean1 = sum(PDF_Of_Loc1 .* Unique_Handoff_Location1) ;
Loc_Mean2 = sum(PDF_Of_Loc2 .* Unique_Handoff_Location2) ;
Loc_Mean3 = sum(PDF_Of_Loc3 .* Unique_Handoff_Location3) ;

%% Plotting PDF'S For All Algorithm
figure() ;
subplot(2,2,1) ;
stem( Unique_Handoff_Counter , PDF_Of_Count , "LineWidth", 1) ;
xlabel("Number Of Handoff") ;
ylabel("PMF (PDF)") ;
title("RSS ( algorithm 1 )") ;
grid on ;
xline(Num_Mean , "-" ,"Mean = "+ Num_Mean , "LabelOrientation","horizontal", "LineWidth", 1) ;

subplot(2,2,2) ;
stem( Unique_Handoff_Counter1 , PDF_Of_Count1 , "LineWidth", 1 ) ;
xlabel("Number Of Handoff") ;
ylabel("PMF (PDF)") ;
title("RSS With Threshold ( algorithm 2 )") ;
grid on ;
xline(Num_Mean1 , "-" ,"Mean = "+ Num_Mean1 , "LabelOrientation","horizontal", "LineWidth", 1) ;

subplot(2,2,3) ;
stem( Unique_Handoff_Counter2 , PDF_Of_Count2 , "LineWidth", 1 ) ;
xlabel("Number Of Handoff") ;
ylabel("PMF (PDF)") ;
title("RSS With Hysteresis in RSS ( algorithm 3 )") ;
grid on ;
xline(Num_Mean2 , "-" ,"Mean = "+ Num_Mean2 , "LabelOrientation","horizontal", "LineWidth", 1) ;

subplot(2,2,4) ;
stem( Unique_Handoff_Counter3 , PDF_Of_Count3 , "LineWidth", 1 ) ;
xlabel("Number Of Handoff") ;
ylabel("PMF (PDF)") ;
title("RSS With Hysteresis in RSS & Threshold ( algorithm 4 )") ;
grid on ;
xline(Num_Mean3 , "-" ,"Mean = "+ Num_Mean3 , "LabelOrientation","horizontal", "LineWidth", 1) ;

figure() ;
subplot(2,2,1) ;
stem( Unique_Handoff_Location , PDF_Of_Loc ) ;
xlabel("Location Of Handoff") ;
ylabel("PMF (PDF)") ;
title("RSS ( algorithm 1 )") ;
grid on ;
xline(Loc_Mean , "-" ,"Mean = "+ Loc_Mean , "LabelOrientation","horizontal", "LineWidth", 1) ;

subplot(2,2,2) ;
stem( Unique_Handoff_Location1 , PDF_Of_Loc1 ) ;
xlabel("Location Of Handoff") ;
ylabel("PMF (PDF)") ;
title("RSS With Threshold ( algorithm 2 )") ;
grid on ;
xline(Loc_Mean1 , "-" ,"Mean = "+ Loc_Mean1 , "LabelOrientation","horizontal", "LineWidth", 1) ;

subplot(2,2,3) ;
stem( Unique_Handoff_Location2 , PDF_Of_Loc2 ) ;
xlabel("Location Of Handoff") ;
ylabel("PMF (PDF)") ;
title("RSSS With Hysteresis in RSS ( algorithm 3 )") ;
grid on ;
xline(Loc_Mean2 , "-" ,"Mean = "+ Loc_Mean2 , "LabelOrientation","horizontal", "LineWidth", 1) ;

subplot(2,2,4) ;
stem( Unique_Handoff_Location3 , PDF_Of_Loc3 ) ;
xlabel("Location Of Handoff") ;
ylabel("PMF (PDF)") ;
title("RSSS With Hysteresis in RSS & Threshold ( algorithm 4 )") ;
grid on ;
xline(Loc_Mean3 , "-" ,"Mean = "+ Loc_Mean3 , "LabelOrientation","horizontal" , "LineWidth", 1) ;

%% Plotting the RSS values obtained
figure() ;
plot(d1, RSS1,'r') ;
hold on ;
plot(d1, RSS2,'b') ;
hold on ;
plot(d1, RSS3,'g') ;
hold on ;
plot(d1, RSS4,'c') ;
grid minor ;
title('RSS versus distance along route')
xlabel('distance from BS1 in meters');
ylabel('dBm');
xline(Min_distance , "-" ,"Min Distance = 12.2474 m") ;
xline(Max_distance , "-" , "Max distance = 487.7526 m") ;
legend("BS1" , "BS2" , "BS3" , "BS4" , "Location","best") ;

Mean_RSS01 = sum(Mean_RSS01 ,1) / 100 ;
Mean_RSS02 = sum(Mean_RSS02 ,1) / 100 ;
Mean_RSS03 = sum(Mean_RSS03 ,1) / 100 ;
Mean_RSS04 = sum(Mean_RSS04 ,1) / 100 ;

figure() ;
plot(d1, Mean_RSS01,'r') ;
hold on ;
plot(d1, Mean_RSS02,'b') ;
hold on ;
plot(d1, Mean_RSS03,'g') ;
hold on ;
plot(d1, Mean_RSS04,'c') ;
grid minor ;
title('Mean RSS versus distance along route')
xlabel('distance from BS1 in meters');
ylabel('dBm');
xline(Min_distance , "-" ,"Min Distance = 12.2474 m") ;
xline(Max_distance , "-" , "Max distance = 487.7526 m") ;
legend("BS1" , "BS2" , "BS3" , "BS4" , "Location","best") ;
