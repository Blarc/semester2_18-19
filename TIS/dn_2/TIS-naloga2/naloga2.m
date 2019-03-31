function [izhod, R, kodBela, kodCrna] = naloga2(vhod)
  % Izvedemo kodiranje vhodne binarne slike (matrike) vhod
  % po modificiranem standardu ITU-T T.4.
  % Slika vsebuje poljubno stevilo vrstic in 1728 stolpcev.
  %
  % vhod     - matrika, ki predstavlja sliko
  % izhod    - binarni vrsticni vektor
  % R        - kompresijsko razmerje
  % kodBela  - matrika dolzin zaporedij belih slikovnih tock
  %		         in dolzin kodnih zamenjav
  % kodCrna  - matrika dolzin zaporedij crnih slikovnih tock
  %		         in dolzin kodnih zamenjav
  
  white = [];
  black = [];
  rows = [];

  [rowNum, colNum] = size(vhod);

  for i = (1:rowNum)
    row = vhod(i, :);
    
    indRow = find(diff(row));
    indRow = [0, indRow, colNum];
    indRow = nonzeros(indRow(2:end) - indRow(1:end-1))';
    
    if (row(1) == 0)
      indRow = [0, indRow];
    endif
    
    whiteRow = indRow(1:2:end);
    blackRow = indRow(2:2:end);
    
    rows = [rows, indRow];
    white = [white, whiteRow];
    black = [black, blackRow];
    
  endfor
  
function [huff] = huffwoman(huff, n)
  col = find(huff(:, 3) == 0);
  
  [freqSorted, indices] = sort(huff(:, 2)(col));
  
  newRow = [0, freqSorted(1) + freqSorted(2), 0, col(indices(1)), col(indices(2))];
  huff(col(indices(1)), 3) += 1;
  huff(col(indices(2)), 3) += 1;
  huff = [huff; newRow];
  
  increase = nonzeros([huff(col(indices(1)), 4:5),huff(col(indices(2)), 4:5)]);
  if (any(increase))
    while (any(increase > n))
      temp = find(increase > n);
      increase = [increase;huff(increase(temp),4);huff(increase(temp),5)];
      increase(temp) = [];
    endwhile
    huff(increase, 3) += 1;
  endif
  
endfunction
  
  
  function [codes] = encode(lens)
    codes = [];
    maxLen = max(lens(:,2));
    prevLen = lens(2,1);
    val = 0;
    for i = (1:length(lens))
      atmLen = lens(i, 2);
      
      if (atmLen != prevLen)
        val *= 2;
        prevLen = atmLen;
      endif
      
      codes = [codes; dec2bin(val,maxLen) - 48];
      val += 1;
    endfor
  endfunction
  
  
  function [map, codeLen] = huffman(arr)
    uniq = unique(arr);

    hist = histc(arr, uniq);

    quot = sum(hist);

    freq = hist / quot;
    
    huff = [uniq', freq', zeros(length(freq),1,"float"), zeros(length(freq),1,"float"), zeros(length(freq),1,"float")];
    
    while (huff(end, 2) != 1)
      huff = huffwoman(huff, length(uniq));
    endwhile
    
    codeLen = [huff(1:length(uniq), 1), huff(1:length(uniq), 3)];
    codeLen = sortrows(sortrows(codeLen, [1]),[2]);
    codes = [codeLen(:,2),encode(codeLen)];
    
    indices = codeLen(:, 1);
    map = zeros(colNum+1, max(codeLen(:, 2))+1);
    map(indices+1,:) = codes;
    
    
  endfunction
  
  
  [whiteMap, kodBela] = huffman(white);
  [blackMap, kodCrna] = huffman(black);
  
  result = [];
  for i = (1:length(rows))
    if (mod(i,2) == 1)
      tmp = whiteMap(rows(i)+1, :);
      code = tmp(end-tmp(1)+1:end);
    else
      tmp = blackMap(rows(i)+1, :);
      code = tmp(end-tmp(1)+1:end);
    endif
    result = [result, code];
  endfor
  
  R = 1;
  izhod = result;
end