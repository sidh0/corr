function [r,m,b] =  regression2(y,x)
    % Uage: [r,m,b] = regression2(y,x);
    % r is the r statistic
    % m is the slope
    % b is the offset
    % Fits a line : y = b + m*x, using least squares
    
    % Just try to sort the inputs out that so you get column vectors
    if size(y,2) > size(y,1);
        x = x';
        y = y';
    end
    
    if ~all(size(x)==size(y));
        x = x';
    end
    
    % If this for whatever reason hasn't been sorted out, throw an error
    assert(all(size(x) == size(y)),'Size of inputs are wrong');
    
    P = polyfit(x,y,1);
    m = P(1); b = P(2);
    R = corrcoef(x,y);
    r = R(1,2);
    
end