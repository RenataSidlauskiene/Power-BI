use Project3;

/*
1.Trys Daugiausiai įtakos turinčios patikimumo rodikliui linijos ir jų parametrai: 
Atsijungimų skaičius; klientų skaičius; linijos ilgis; linijos ilgis miške; 
transformatorinių skaičius.
*/

-- Sukuriami papildomi stulpeliai, sujungiama data ir laikas atjungimo ir įjungimo.
Alter table DATA1_atjungimai
add Atjungimo_data_laikas DATETIME, Ijungimo_data_laikas DATETIME;

/*
Data ir laikas konvertuojami į tekstinį formatą (varchar), tada sujungiami į vieną stulpelį 
ir po to galutinė reikšmė konvertuojama į Datetime formatą. 
114 – tai yra laiko formato kodas (konvertuojama į HH:MI:SS:MMM). 
120 – tai yra datos ir laiko formato kodas (konvertuojama į yyyy-mm-dd HH:MI:SS).
*/

UPDATE DATA1_atjungimai
set Atjungimo_data_laikas = CONVERT(DATETIME, CONVERT(varchar(10), Atjungimo_data_new, 120) + ' ' + 
            CONVERT(varchar(8), Atjungimo_laikas_new, 114), 120),
    Ijungimo_data_laikas = CONVERT(DATETIME, CONVERT(varchar(10), Ijungimo_data_new, 120) + ' ' + 
            CONVERT(varchar(8), Ijungimo_laikas_new, 114), 120);



select 
  COUNT(distinct Atjungimo_numeris) as Atjungimu_skaicius,
  SUM(Atjungtu_vartotoju_skaicius) as Atjungtu_vartotoju_skaicius,
  AVG(datediff(minute, Atjungimo_data_laikas, Ijungimo_data_laikas)) As Vidutine_atjungimo_trukme_min,
  SUM(datediff(minute, Atjungimo_data_laikas, Ijungimo_data_laikas)) AS Bendra_atjungimo_trukme_min
From DATA1_atjungimai
WHERE 
  Atjungimo_data_laikas IS NOT NULL AND Ijungimo_data_laikas IS NOT NULL;


  
/*
Rezultatas:

Atjungimu_skaicius	Atjungtu_vartotoju_skaicius	 Vidutine_atjungimo_trukme_min	Bendra_atjungimo_trukme_min
1402	             879841	                      165	                         232167
*/

-- Kabelinės ir Magistralinės Linijų ilgis

Select 
  'Bendras kabelinių linijų ilgis' AS Pavadinimas,
  SUM(Segmentų_Ilgis) AS Linijos_Ilgis
FROM DATA4_KL
UNION
SELECT 
  'Bendras magistraliniu liniju ilgis' AS Pavadinimas,
  SUM(Segmento_ilgis) AS Linijos_Ilgis
FROM DATA4_OL
UNION
SELECT 
  'Bendras kabeliniu ir magistraliniu liniju ilgis' AS Pavadinimas,
  (SELECT SUM(Segmentų_Ilgis) FROM DATA4_KL) + 
  (SELECT SUM(Segmento_ilgis) FROM DATA4_OL) AS Linijos_Ilgis;

/*
Rezultatas:

Pavadinimas	                                        Linijos_Ilgis
Bendras kabeliniu liniju ilgis	                    1044122.00
Bendras magistraliniu liniju ilgis	                1512254.00
Bendras kabeliniu ir magistraliniu liniju ilgis  	2556376.00
*/

-- Linijos ilgis miške (Iš lentelės DATA4 skaičiuoju sumą reikšmių stulpelyje 'ILGIS_miske_m')

SELECT SUM([ILGIS_miske_m]) AS [ Linijos ilgis miske, m]
FROM DATA3_10kV_OL_miskuose;

/*
Rezultatas:

Linijos ilgis miske, m
373824.66
*/

-- Transformatorinių skaičius (skaičiuoju unikalius "Transformatorinės_ID" iš lentelės DATA4_Transformatoriai)

SELECT COUNT(DISTINCT "Transformatorinės_ID") AS Transformatoriniu_Skacius
FROM DATA4_Transformatoriai;

/*
Rezultatas:

Transformatoriniu_Skacius
3009
*/

----------------------------------------------------------------------------

/*
2.	Top trys priežastys įtakojančios patikimumo rodiklius.

Duomenys iš Data1 lentelės, paėmiau nutraukimo priežastis ir vidutines reikšmes patikimumo 
rodiklių SAIFI, SAIDI, CAIDI.
Top 3 išfiltravau pagal SAIFI.
*/

SELECT TOP 3
  Nutraukimo_priezastis, 
  COUNT(*) AS Atjungimu_kartai,  
  AVG(SAIFI) AS Vidutinis_SAIFI, -- Kaip dažnai įvyksta atjungimai.
  AVG(SAIDI) AS Vidutinis_SAIDI, -- Vidutinė atjungimo trukmė.
  AVG(CAIDI) AS Vidutinis_CAIDI  -- Vidutinė atjungimo trukmė vienam vartotojui.     
FROM Data1_atjungimai
GROUP BY Nutraukimo_priezastis
ORDER BY Vidutinis_SAIFI DESC;


/*
Rezultatas:

Nutraukimo_priezastis	  Atjungimu_kartai	Vidutinis_SAIFI	 Vidutinis_SAIDI	Vidutinis_CAIDI
Nenustatytos priežastys 	612	            0.0003610032	 0.0035884068	    18.1166454248
Išorinio poveikio	        182	            0.0003538571	 0.0364227582	    153.3119505494
Operatoriaus atsakomybė	    480	            0.0003148708	 0.0186696187	    95.4820208333
*/

---------------------------------------------------------------------------
-- 3. Top trys daugiausiai klientu turinčios linijos. Pateikti linijos pavadinimus ir klientų skaičių.


/*
Duomenis paėmiau iš lentelės Data1. Iš stulpelio "Gedimo_linija" paėmiau linijų pavadinimus ir 
susumavau atjungtų vartotojų skaičių. 
*/

SELECT TOP 3
  Gedimo_linija as Linijos_pavadinimas, 
  SUM(Atjungtu_vartotoju_skaicius) AS Klientu_Skacius
FROM DATA1_atjungimai
GROUP BY Gedimo_linija
ORDER BY Klientu_Skacius DESC;


/*
Rezultatas:
Linijos_pavadinimas   	Klientu_Skacius
L-300	                118789
L-MTĄž-802	            96907
L-100               	75858
*/

---------------------------------------------------------------------------------

-- 4. Top trys ilgiausios linijos einančios per miškus. Pateikti linijos pavadinimus ir klientų skaičių.

--Paėmiau linijos pavadinimus iš 'OL_PAVADIN' bei ilgį miške,m iš lentelės Data1.

SELECT TOP 3
  OL_PAVADIN AS Linijos_pavadinimas, 
  SUM(ILGIS_miske_m) AS Ilgis_miske_m
FROM  Data3_10kV_OL_miskuose
GROUP BY OL_PAVADIN
ORDER BY Ilgis_miske_m DESC;

/*
Rezultatas:
Linijos_pavadinimas	                Ilgis_miske_m
L-700 iš SP-310 iš Nemenčinės TP	6360.25
L-200 iš Nemenčinė TP	            6354.41
L-400 iš Lavoriškės TP          	4415.43
*/


-- Top 3 ilgiausių linijų miške klientų skaičius

SELECT 
   Gedimo_linija, TP_SP_TR, SUM(COALESCE(Atjungtu_vartotoju_skaicius, 0)) AS Klientu_skaicius
FROM DATA1_atjungimai
WHERE TRIM(Gedimo_linija) = 'L-700'
  AND TP_SP_TR LIKE '%Nem%'
GROUP BY Gedimo_linija, TP_SP_TR
HAVING SUM(COALESCE(Atjungtu_vartotoju_skaicius, 0)) <> 325

UNION

SELECT  
   Gedimo_linija, TP_SP_TR, SUM(COALESCE(Atjungtu_vartotoju_skaicius, 0)) AS Klientu_skaicius
FROM DATA1_atjungimai
WHERE TRIM(Gedimo_linija) = 'L-200'
  AND TP_SP_TR LIKE '%Nem%'
GROUP BY Gedimo_linija, TP_SP_TR

UNION

SELECT  
   Gedimo_linija, TP_SP_TR, SUM(COALESCE(Atjungtu_vartotoju_skaicius, 0)) AS Klientu_skaicius
FROM DATA1_atjungimai
WHERE TRIM(Gedimo_linija) = 'L-400'
  AND TP_SP_TR LIKE '%Lavo%'
GROUP BY Gedimo_linija, TP_SP_TR

ORDER BY TP_SP_TR DESC;

/*
Rezultatas:

Gedimo_linija	TP_SP_TR	      Klientu_skaicius
L-700	        NemenčinėSP-310	  162
L-200	        Nemenčinė	      18833
L-400	        Lavoriškės	      1010
*/
