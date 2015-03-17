function CurateCorrelationCells()

    inDir = '/sid/Ephys/Correlation/';
    outFile = 'CorrelationCells.mat';
    
    allFiles = what(inDir);
    allMatFiles = allFiles.mat;
    
    if any(strcmp(outFile,allMatFiles));
        load([inDir,outFile]);
    else
        Cells = struct();
    end
    
    % Want this as an argument 
    sessions = {'M006','M007','M008'};
    
    
    for s_i = 1:length(sessions);
        session = sessions{s_i};
        fname = ['/b/data/jbe/',session,'/jbe',session,'.rds.XAC.Cells.mat'];

        load(fname);

        dxs = cat(1,AllExpt.Expt.Trials.dx);
        ces = cat(1,AllExpt.Expt.Trials.ce);

        cells = cat(1,AllExpt.Header.cellnumber);
        cells = cells(cells > 0);
        nCells = length(cells);

        undxs = unique(dxs);
        unces = unique(ces);

        meanMatrix = zeros(nCells,length(undxs),length(unces));
        semMatrix = zeros(nCells,length(undxs),length(unces));

        allTrialNums = cat(1,AllExpt.Expt.Trials.Trial);

        for k = 1:nCells;
            this.trialNum = cat(1,AllExpt.Spikes{k}.Trial);
            this.trials = zeros(1,length(this.trialNum));
            
            cellnumber = AllExpt.Header(k).cellnumber;
            
            for j = 1:length(this.trialNum);
                this.trials(j) = find(this.trialNum(j) == allTrialNums);
            end

            this.dxs = cat(1,AllExpt.Expt.Trials(this.trials).dx);
            this.ces = cat(1,AllExpt.Expt.Trials(this.trials).ce);
            this.excluded = cat(1,AllExpt.Expt.Trials(this.trials).excluded);
            nTrials = 0;
            
            this.means = [];
            this.undxs = [];
            for d = 1:length(undxs);
                currentDx = undxs(d);
                for c = 1:length(unces);
                    currentCe = unces(c);
                    % Current disparity, curren correlation and not excluded
                    this.excluded = zeros(size(this.dxs));
                    isCurrent = (this.dxs == currentDx) .* (this.ces == currentCe) .* ~this.excluded;
                    if currentDx == 0;
                        a = 0;
                    end
                    currentTrials = this.trials(logical(isCurrent));

                    nTrials = nTrials + sum(isCurrent);
                    allSpikes = cat(1,AllExpt.Spikes{k}.Spikes(currentTrials));
                    spikeCounts = zeros(1,length(allSpikes));
                    for spike = 1:length(allSpikes);
                        spikeCounts(spike) = length(allSpikes{spike});
                    end

                    if (currentCe == 0) && (currentDx == 0);
                        meanMatrix(k,:,c) = mean(spikeCounts);
                        semMatrix(k,:,c) = std(spikeCounts)/sqrt(length(spikeCounts));
                    elseif (currentCe ~= 0)
                        meanMatrix(k,d,c) = mean(spikeCounts);
                        semMatrix(k,d,c) = std(spikeCounts)/sqrt(length(spikeCounts));
                    end
                    
                    if currentCe == 1;
                        this.means = [this.means,spikeCounts];
                        this.undxs = [this.undxs,zeros(1,length(spikeCounts))+undxs(d)];
                    end
                end
            end
            
            % Now we do a crap filter
            P = anova1(this.means,this.undxs,'off');
            
            % Last correlation; should be 100% correlated
            maxRate = max(meanMatrix(k,:,c));
            
            if P < 0.01 && maxRate > 4;
                if isempty(fields(Cells))
                    newCell = 1;
                else
                    newCell = length(Cells)+1;
                end

                Cells(newCell).meanMatrix = squeeze(meanMatrix(k,:,:));
                Cells(newCell).semMatrix = squeeze(semMatrix(k,:,:));
                Cells(newCell).ces = unces;
                Cells(newCell).filename = fname;
                Cells(newCell).cellnumber = cellnumber;
                Cells(newCell).dxs = undxs;
            end
        end
        
        %%% So now we have all the data for the current file in a
        %%% convenient matrix
        
        
        
        a=3;
    end
    save('CorrelationCells.mat','Cells');
end