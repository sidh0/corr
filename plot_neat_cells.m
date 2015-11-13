function plot_neat_cells()
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
    myFig = figure(); hold on;
    
    setappdata(myFig,'plotCes',plotCes);
    setappdata(myFig,'colors',rand([3,100]));
    
    populate_plot(Cells,myFig);
              
end


function populate_plot(Cells,myFig,varargin)
    neat_cells = [6,7,9,11,25,29];
       
    if nargin > 2;
        currentCell = varargin{1};
    else
        currentCell = 1;
    end
    
    getappdata(myFig,'plotCes');
    cols = getappdata(myFig,'colors');
    
    
    nCells = length(Cells);
    set(myFig,'color','white');
   
    
    figData.Rs = []; figData.Ms = []; 
    figData.Ces = []; figData.IDs = [];

    lemCount = 0; jbeCount = 0;

    for j = 1:length(neat_cells)
        this =Cells(neat_cells(j));
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
        
        
        x = linspace(-1,1,101);
        P = polyfit(ces',ms,3);
        y = P(1)*x.^3 + P(2)*x.^2 + P(3) *x + P(4);
        plot(x,y,'-','color',cols(:,j),'linewidth',2);

        plot(ces,ms,'o','markersize',6,'markerfacecolor',cols(:,j),'color','k');
       
                
 
    end
    

    xlabel('Binocular correlation')
    ylabel('Normalised response')
    plot([-1,1],[-1,1],'k -','linewidth',2);
    plot([-1,1],[0,0],'k -','linewidth',2);
    
end