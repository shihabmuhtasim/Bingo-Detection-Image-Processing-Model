function bingoFlag = checkBingo(digitizedArray)
% CHECKBINGO Checks rows, columns, and diagonals for bingo
bingoFlag = false;

% Rows
if any(sum(digitizedArray,2) == 5)
    bingoFlag = true;
    return;
end

% Columns
if any(sum(digitizedArray,1) == 5)
    bingoFlag = true;
    return;
end

% Diagonals
if sum(diag(digitizedArray)) == 5 || sum(diag(flipud(digitizedArray))) == 5
    bingoFlag = true;
    return;
end
end