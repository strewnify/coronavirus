% INFECT  Disease spread model
% by Jim Goodall, March 2020

clear
warning('off','map:geodesic:longGeodesic'); 

% Configuration
planet = referenceEllipsoid('earth','m');
num_people = 50000;
marksize = 1;
marksize_infected = 30;
marksize_immune = 1;
stepsperday = 5;

% Initialize map
load coastlines
geoshow(coastlat,coastlon)
hold on

% Generate individuals
minLAT = -55;
maxLAT = 60;
minLONG = -135;
maxLONG = 150;
for n = 1:num_people
    LAT(n) = minLAT + (maxLAT-minLAT)*rand();
    LONG(n) = minLONG + (maxLONG-minLONG)*rand();
    Infected(n) = false;
    Contagious(n) = false;
    Immune(n) = false;
    DaysInfected(n) = 0;
    Health = 1;
end

% Generate infected individual
n = randi([1 num_people]);
Infected(n) = true;
LAT(n) = 30.5928;
LONG(n) = 114.3055;

% Generate immune individual
n = randi([1 num_people]);
Immune(n) = true;

% plot individuals
%healthy = plot(LONG(~Infected&~Immune),LAT(~Infected&~Immune),'k.','markersize',marksize);
infected = plot(LONG(Infected),LAT(Infected),'r.','markersize', marksize_infected);
immune = plot(LONG(Immune),LAT(Immune),'b.','markersize', marksize_immune);
set(gcf,'units','normalized','outerposition',[0 0 1 1])

for t = 1:365
    % Determine daily travel
    Direction = 360 .* rand(1,num_people);
    for n = 1:num_people
        
        % Infection day counter
        if Infected(n)
            DaysInfected(n) = DaysInfected(n) + 1;
        end
        
        % Assign contagious
        if DaysInfected(n) > 2 && DaysInfected(n) < 12
            Contagious(n) = true;
        else
            Contagious(n) = false;
        end
        
        % Recovery
        if DaysInfected(n) > 12
            Infected(n) = false;
            Contagious(n) = true;
            Immune(n) = true;
        end
            
        % Sick people don't move
        if DaysInfected(n) > 5 && DaysInfected(n) < 10
            Mobility(n) = 0;            
        else
            Mobility(n) = lognrnd(8,3);
        end
    end
    Step = Mobility./stepsperday;
    
    % Travel
    for hour = 1:stepsperday
        % Move hourly
        [LAT, LONG] = reckon(LAT, LONG, Step, Direction, planet);

        % Infect nearby individuals
        Idx = rangesearch([LAT' LONG'], [LAT' LONG'], 0.3);
        for n = 1:num_people
            if Contagious(n)
                for nearby = 1:size(Idx{n},2)
                    if ~Immune(Idx{n}(nearby))
                        Infected(Idx{n}(nearby)) = true;
                    end
                end
            end
        end
        clear Idx

        % Update graph
        % plot individuals
        title(['Pandemic - Day ' num2str(t)])
        %healthy.YData = LAT(~Infected & ~Immune);
        %healthy.XData = LONG(~Infected & ~Immune);
        infected.YData = LAT(Infected);
        infected.XData = LONG(Infected);
        immune.YData = LAT(Immune);
        immune.XData = LONG(Immune);
        drawnow
    end
end

warning('on','map:geodesic:longGeodesic'); 
