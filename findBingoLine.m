function [rowWin, colWin, diagFlag] = findBingoLine(digitizedArray)

% Initialize
rowWin = [];
colWin = [];
diagFlag = 0;

% Check each row for bingo (sum == 5)
for r = 1:size(digitizedArray,1)
    if sum(digitizedArray(r,:)) == 5
        rowWin = r;
        return; % stop once we find a bingo
    end
end

% Check each column for bingo (sum == 5)
for c = 1:size(digitizedArray,2)
    if sum(digitizedArray(:,c)) == 5
        colWin = c;
        return;
    end
end

% Check main diagonal
if sum(diag(digitizedArray)) == 5
    diagFlag = 1;
    return;
end

% Check anti-diagonal
if sum(diag(flipud(digitizedArray))) == 5
    diagFlag = 2;
    return;
end

end