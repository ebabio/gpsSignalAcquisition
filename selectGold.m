function gold = selectGold(prn)

switch prn
    case 0
        gold = [0 0];
    case 1
        gold = [2 6];
    case 2
        gold = [3 7];
    case 3
        gold = [4 8];
    case 4
        gold = [5 9];
    case 5
        gold = [1 9];
    case 6
        gold = [2 10];
    case 7
        gold = [1 8];
    case 8
        gold = [2 9];
    case 9
        gold = [3 10];
    case 10
        gold = [2 3];
    case 11
        gold = [3 4];
    case 12
        gold = [5 6];
    case 13
        gold = [6 7];
    case 14
        gold = [7 8];
    case 15
        gold = [8 9];
    case 16
        gold = [9 10];
    case 17
        gold = [1 4];
    case 18
        gold = [2 5];
    case 19
        gold = [3 6];
    case 20
        gold = [4 7];
    case 21
        gold = [5 8];
    case 22
        gold = [6 9];
    case 23
        gold = [1 3];
    case 24
        gold = [4 6];
    case 25
        gold = [5 7];
    case 26
        gold = [6 8];
    case 27
        gold = [7 9];
    case 28
        gold = [8 10];
    case 29
        gold = [1 6];
    case 30
        gold = [2 7];
    case 31
        gold = [3 8];
    case 32
        gold = [4 9];
    otherwise
        warning('unrecognized prn number: skipping')
end
