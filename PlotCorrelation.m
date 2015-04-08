function PlotCorrelation()
    load('CorrelationCells.mat');
    plotCes = [-1,-0.5,0,0.25,0.5,0.75,1];
    
    % Update matrix to onnly include the ces we 
    % want to plot
    for j = 1:length(Cells);
        this = Cells(j);
        [ces,idx] = intersect(this.ces,plotCes);
        
        Cells(j).meanMatrix = this.meanMatrix(:,idx);
        Cells(j).semMatrix = this.semMatrix(:,idx);
        Cells(j).ces = ces;
    end
    
    % Need to define which ones you actually want; there are some garbage
    % ones because binoc is slightly buggy
    myFig = figure();
    
    setappdata(myFig,'plotCes',plotCes);
    setappdata(myFig,'colors',rand([3,100]));
    
    populate_plot(Cells,myFig);
    
    setappdata(myFig,'currentCell',1)
    
    set(gcf,'Color','White','WindowKeyPressFcn',@correlation_callback)
end

function correlation_callback(myFig,evt)

    appdata = getappdata(myFig);
    
    Cells = appdata.Cells;
    
    %figData = appdata.figData; 
    
    nCells = length(Cells);
    
    buttondown = strcmp(evt.Key,'downarrow');
    buttonup = strcmp(evt.Key,'uparrow');
    
    
    currentCell = appdata.currentCell;
    if buttondown
        % Wrap around
        if currentCell == 1;
            currentCell = nCells;
        else
            currentCell = currentCell-1;
        end
    elseif buttonup
        if currentCell == nCells
            currentCell = 1;
        else
            currentCell = currentCell+1;
        end
    end
    setappdata(myFig,'currentCell',currentCell);

    % Change the main plot to update its line widths
    % bringing the current thingy into focus
    populate_plot(Cells,myFig,currentCell);
    
    if ~isfield(appdata,'tcFig');
        tcFig = figure();
        setappdata(myFig,'tcFig',tcFig);
    else
        if ishandle(appdata.tcFig);
            tcFig = appdata.tcFig;
        else
            tcFig = figure();
            setappdata(myFig,'tcFig',tcFig);
        end
        
    end
    
    set(tcFig,'color','white');
    figure(tcFig); cla; hold on;
    this = Cells(currentCell);
    nces = length(this.ces); clin = linspace(0.1,1,nces);
    cols = [clin;clin*0 + 0.1;clin(end:-1:1)];
    cols = [clin(end:-1:1);0*clin;0*clin];
    for c = 1:length(this.ces);
        current = this.meanMatrix(:,c);
        sem = this.semMatrix(:,c);
        E=errorbar(this.dxs,current,1.96*sem);
        set(E,'linestyle','--','marker', 'o','linewidth',3,'markersize',6, ...
            'color',cols(:,c),'markerfacecolor',cols(:,c));
    end
    % Want to set title etc here as well
    cellName = [this.filename(18:24),'-cell',num2str(this.cellnumber)];
    title(cellName,'fontsize',22);
    
    xlabel('Disparity (deg)','fontsize',18);
    ylabel('Mean spikes per trial','fontsize',18);
    
    figure(myFig)

end

function populate_plot(Cells,myFig,varargin)

    if nargin > 2;
        currentCell = varargin{1};
    else
        currentCell = 1;
    end
    
    getappdata(myFig,'plotCes');
    cols = getappdata(myFig,'colors');
    
    
    nCells = length(Cells);
    set(myFig,'color','white');
    
    % Blank out the plot
    subplot(1,2,1); cla;
    subplot(1,2,2); cla;
    
    figData.Rs = []; figData.Ms = []; 
    figData.Ces = []; figData.IDs = [];

    lemCount = 0; jbeCount = 0;
    
    for j = 1:nCells;
        this =Cells(j);
        ces = this.ces;
        
        meanMatrix = this.meanMatrix;
        correlated = meanMatrix(:,end);
        
        rs = zeros(1,length(ces));
        ms = zeros(1,length(ces));
        
        for c = 1:length(ces);
            current = meanMatrix(:,c);
            [r,m,b] = regression2(current,correlated);
            rs(c) = r;
            ms(c) = m;
        end
        
        % Add slope, regression, etc. with the cell id
        figData.Rs = [figData.Rs,rs];
        figData.Ms = [figData.Ms,ms];
        figData.Ces = [figData.Ces,ces'];
        figData.IDs = [figData.IDs,zeros(1,length(rs))+j];
        
        lw = (j == currentCell)*3 + 2;
        
        if j~=currentCell
            subplot(1,2,1); hold on;
            plot(ces,rs, '-- o', 'linewidth',lw,'markersize',lw*2, 'color',cols(:,j));

            subplot(1,2,2); hold on;
            plot(ces,ms,'-- o','linewidth',lw,'markersize',lw*2,'color',cols(:,j));
        else
            main_ces = ces; main_rs = rs; main_ms = ms; main_col = cols(:,j);
        end

        lemCount = lemCount+strcmp(Cells(j).filename(9:11),'lem');
        jbeCount = jbeCount+strcmp(Cells(j).filename(9:11),'jbe');
    end

    % Finally plot the last line so that we get it on top
    subplot(1,2,1);
    plot(main_ces,main_rs, '-- o', 'linewidth',5,'markersize',10, 'color',main_col);

    subplot(1,2,2);
    plot(main_ces,main_ms,'-- o','linewidth',5,'markersize',10,'color',main_col);

    
    subplot(1,2,1);
    set(gca,'fontsize',20);
    xlabel('Binocular correlation','fontsize',24);
    ylabel('Correlation coefficient','fontsize',24);
    plot([-1,1],[-1,1],'k -','linewidth',2);
    plot([-1,1],[0,0],'k -','linewidth',2);
    
    subplot(1,2,2);
    set(gca,'fontsize',20);
    xlabel('Binocular correlation','fontsize',24);
    ylabel('Regression slope','fontsize',24);
    plot([-1,1],[-1,1],'k -','linewidth',2);
    plot([-1,1],[0,0],'k -','linewidth',2);


    text(0.5,-0.5,sprintf('lem: %i cells',lemCount));
    text(0.5,-0.6,sprintf('jbe: %i cells',jbeCount));
    
    setappdata(gcf,'figData',figData);
    setappdata(gcf,'Cells',Cells);
end