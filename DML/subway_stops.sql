/* 
   Every subway stop in the imported dataset is differentiated in terms of its id
   in nord and sud, but the relative coordinates are always equals. 
   These duplicates are eliminated 
*/
DELETE 
FROM subway_stops 
WHERE id LIKE '%N' OR id LIKE '%S';