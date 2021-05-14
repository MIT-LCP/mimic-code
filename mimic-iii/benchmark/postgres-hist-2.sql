with histogram as (
	select
		case
			when di.itemid in
			(
				-- HEART RATE
			  211, --"Heart Rate"
			  220045, --"Heart Rate"

			  -- Systolic/diastolic

			  51, --	Arterial BP [Systolic]
			  442, --	Manual BP [Systolic]
			  455, --	NBP [Systolic]
			  6701, --	Arterial BP #2 [Systolic]
			  220179, --	Non Invasive Blood Pressure systolic
			  220050, --	Arterial Blood Pressure systolic

			  8368, --	Arterial BP [Diastolic]
			  8440, --	Manual BP [Diastolic]
			  8441, --	NBP [Diastolic]
			  8555, --	Arterial BP #2 [Diastolic]
			  220180, --	Non Invasive Blood Pressure diastolic
			  220051, --	Arterial Blood Pressure diastolic


			  -- MEAN ARTERIAL PRESSURE
			  456, --"NBP Mean"
			  52, --"Arterial BP Mean"
			  6702, --	Arterial BP Mean #2
			  443, --	Manual BP Mean(calc)
			  220052, --"Arterial Blood Pressure mean"
			  220181, --"Non Invasive Blood Pressure mean"
			  225312, --"ART BP mean"

			  -- RESPIRATORY RATE
			  618,--	Respiratory Rate
			  615,--	Resp Rate (Total)
			  220210,--	Respiratory Rate
			  224690, --	Respiratory Rate (Total)


			  -- SPO2, peripheral
			  646, 220277,

			  -- GLUCOSE, both lab and fingerstick
			  807,--	Fingerstick Glucose
			  811,--	Glucose (70-105)
			  1529,--	Glucose
			  3745,--	BloodGlucose
			  3744,--	Blood Glucose
			  225664,--	Glucose finger stick
			  220621,--	Glucose (serum)
			  226537,--	Glucose (whole blood)

			  -- TEMPERATURE
			  223762, -- "Temperature Celsius"
			  676,	-- "Temperature C"
			  223761, -- "Temperature Fahrenheit"
			  678 --	"Temperature F"
			) then 0

			WHEN ( di.itemid >= 1 AND di.itemid < 161 ) THEN 1
			WHEN ( di.itemid >= 161 AND di.itemid < 428 ) THEN 2
			WHEN ( di.itemid >= 428 AND di.itemid < 615 ) THEN 3
			WHEN ( di.itemid >= 615 AND di.itemid < 742 ) THEN 4
			WHEN ( di.itemid >= 742 AND di.itemid < 3338 ) THEN 5
			WHEN ( di.itemid >= 3338 AND di.itemid < 3723 ) THEN 6
			WHEN ( di.itemid >= 3723 AND di.itemid < 8523 ) THEN 7
			WHEN ( di.itemid >= 8523 AND di.itemid < 220074 ) THEN 8
			WHEN ( di.itemid >= 220074 AND di.itemid < 323769 ) THEN 9
		ELSE 10 end as bucket
	, min(di.itemid) as minitemid
	, max(di.itemid) as maxitemid
	, count(di.itemid) as freq
	from d_items di
	left join datetimeevents de
		on di.itemid = de.itemid
	group by bucket
	order by bucket
)
select bucket, minitemid, maxitemid, freq,
repeat('*', (freq::float / max(freq) over() * 20)::int) as bar
from histogram;
