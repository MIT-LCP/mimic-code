-- https://github.com/alistairewj/sepsis3-mimic
-- Johnson AEW, Aboab J, Raffa JD, Pollard TJ, Deliberato RO, Celi LA, Stone DJ. A Comparative Analysis of Sepsis Identification Methods in an Electronic Database. Crit Care Med. 2018 Apr;46(4):494-499. doi: 10.1097/CCM.0000000000002965. PMID: 29303796; PMCID: PMC5851804.

drop table if exists sepsis3; create table sepsis3 as 
-- abx_poe_list
with t1 as (
  select
    drug, drug_name_generic
    , route
    , case
      when lower(drug) like '%' || lower('adoxa') || '%' then 1
      when lower(drug) like '%' || lower('ala-tet') || '%' then 1
      when lower(drug) like '%' || lower('alodox') || '%' then 1
      when lower(drug) like '%' || lower('amikacin') || '%' then 1
      when lower(drug) like '%' || lower('amikin') || '%' then 1
      when lower(drug) like '%' || lower('amoxicillin') || '%' then 1
      when lower(drug) like '%' || lower('amoxicillin%clavulanate') || '%' then 1
      when lower(drug) like '%' || lower('clavulanate') || '%' then 1
      when lower(drug) like '%' || lower('ampicillin') || '%' then 1
      when lower(drug) like '%' || lower('augmentin') || '%' then 1
      when lower(drug) like '%' || lower('avelox') || '%' then 1
      when lower(drug) like '%' || lower('avidoxy') || '%' then 1
      when lower(drug) like '%' || lower('azactam') || '%' then 1
      when lower(drug) like '%' || lower('azithromycin') || '%' then 1
      when lower(drug) like '%' || lower('aztreonam') || '%' then 1
      when lower(drug) like '%' || lower('axetil') || '%' then 1
      when lower(drug) like '%' || lower('bactocill') || '%' then 1
      when lower(drug) like '%' || lower('bactrim') || '%' then 1
      when lower(drug) like '%' || lower('bethkis') || '%' then 1
      when lower(drug) like '%' || lower('biaxin') || '%' then 1
      when lower(drug) like '%' || lower('bicillin l-a') || '%' then 1
      when lower(drug) like '%' || lower('cayston') || '%' then 1
      when lower(drug) like '%' || lower('cefazolin') || '%' then 1
      when lower(drug) like '%' || lower('cedax') || '%' then 1
      when lower(drug) like '%' || lower('cefoxitin') || '%' then 1
      when lower(drug) like '%' || lower('ceftazidime') || '%' then 1
      when lower(drug) like '%' || lower('cefaclor') || '%' then 1
      when lower(drug) like '%' || lower('cefadroxil') || '%' then 1
      when lower(drug) like '%' || lower('cefdinir') || '%' then 1
      when lower(drug) like '%' || lower('cefditoren') || '%' then 1
      when lower(drug) like '%' || lower('cefepime') || '%' then 1
      when lower(drug) like '%' || lower('cefotetan') || '%' then 1
      when lower(drug) like '%' || lower('cefotaxime') || '%' then 1
      when lower(drug) like '%' || lower('cefpodoxime') || '%' then 1
      when lower(drug) like '%' || lower('cefprozil') || '%' then 1
      when lower(drug) like '%' || lower('ceftibuten') || '%' then 1
      when lower(drug) like '%' || lower('ceftin') || '%' then 1
      when lower(drug) like '%' || lower('cefuroxime ') || '%' then 1
      when lower(drug) like '%' || lower('cefuroxime') || '%' then 1
      when lower(drug) like '%' || lower('cephalexin') || '%' then 1
      when lower(drug) like '%' || lower('chloramphenicol') || '%' then 1
      when lower(drug) like '%' || lower('cipro') || '%' then 1
      when lower(drug) like '%' || lower('ciprofloxacin') || '%' then 1
      when lower(drug) like '%' || lower('claforan') || '%' then 1
      when lower(drug) like '%' || lower('clarithromycin') || '%' then 1
      when lower(drug) like '%' || lower('cleocin') || '%' then 1
      when lower(drug) like '%' || lower('clindamycin') || '%' then 1
      when lower(drug) like '%' || lower('cubicin') || '%' then 1
      when lower(drug) like '%' || lower('dicloxacillin') || '%' then 1
      when lower(drug) like '%' || lower('doryx') || '%' then 1
      when lower(drug) like '%' || lower('doxycycline') || '%' then 1
      when lower(drug) like '%' || lower('duricef') || '%' then 1
      when lower(drug) like '%' || lower('dynacin') || '%' then 1
      when lower(drug) like '%' || lower('ery-tab') || '%' then 1
      when lower(drug) like '%' || lower('eryped') || '%' then 1
      when lower(drug) like '%' || lower('eryc') || '%' then 1
      when lower(drug) like '%' || lower('erythrocin') || '%' then 1
      when lower(drug) like '%' || lower('erythromycin') || '%' then 1
      when lower(drug) like '%' || lower('factive') || '%' then 1
      when lower(drug) like '%' || lower('flagyl') || '%' then 1
      when lower(drug) like '%' || lower('fortaz') || '%' then 1
      when lower(drug) like '%' || lower('furadantin') || '%' then 1
      when lower(drug) like '%' || lower('garamycin') || '%' then 1
      when lower(drug) like '%' || lower('gentamicin') || '%' then 1
      when lower(drug) like '%' || lower('kanamycin') || '%' then 1
      when lower(drug) like '%' || lower('keflex') || '%' then 1
      when lower(drug) like '%' || lower('ketek') || '%' then 1
      when lower(drug) like '%' || lower('levaquin') || '%' then 1
      when lower(drug) like '%' || lower('levofloxacin') || '%' then 1
      when lower(drug) like '%' || lower('lincocin') || '%' then 1
      when lower(drug) like '%' || lower('macrobid') || '%' then 1
      when lower(drug) like '%' || lower('macrodantin') || '%' then 1
      when lower(drug) like '%' || lower('maxipime') || '%' then 1
      when lower(drug) like '%' || lower('mefoxin') || '%' then 1
      when lower(drug) like '%' || lower('metronidazole') || '%' then 1
      when lower(drug) like '%' || lower('minocin') || '%' then 1
      when lower(drug) like '%' || lower('minocycline') || '%' then 1
      when lower(drug) like '%' || lower('monodox') || '%' then 1
      when lower(drug) like '%' || lower('monurol') || '%' then 1
      when lower(drug) like '%' || lower('morgidox') || '%' then 1
      when lower(drug) like '%' || lower('moxatag') || '%' then 1
      when lower(drug) like '%' || lower('moxifloxacin') || '%' then 1
      when lower(drug) like '%' || lower('myrac') || '%' then 1
      when lower(drug) like '%' || lower('nafcillin sodium') || '%' then 1
      when lower(drug) like '%' || lower('nicazel doxy 30') || '%' then 1
      when lower(drug) like '%' || lower('nitrofurantoin') || '%' then 1
      when lower(drug) like '%' || lower('noroxin') || '%' then 1
      when lower(drug) like '%' || lower('ocudox') || '%' then 1
      when lower(drug) like '%' || lower('ofloxacin') || '%' then 1
      when lower(drug) like '%' || lower('omnicef') || '%' then 1
      when lower(drug) like '%' || lower('oracea') || '%' then 1
      when lower(drug) like '%' || lower('oraxyl') || '%' then 1
      when lower(drug) like '%' || lower('oxacillin') || '%' then 1
      when lower(drug) like '%' || lower('pc pen vk') || '%' then 1
      when lower(drug) like '%' || lower('pce dispertab') || '%' then 1
      when lower(drug) like '%' || lower('panixine') || '%' then 1
      when lower(drug) like '%' || lower('pediazole') || '%' then 1
      when lower(drug) like '%' || lower('penicillin') || '%' then 1
      when lower(drug) like '%' || lower('periostat') || '%' then 1
      when lower(drug) like '%' || lower('pfizerpen') || '%' then 1
      when lower(drug) like '%' || lower('piperacillin') || '%' then 1
      when lower(drug) like '%' || lower('tazobactam') || '%' then 1
      when lower(drug) like '%' || lower('primsol') || '%' then 1
      when lower(drug) like '%' || lower('proquin') || '%' then 1
      when lower(drug) like '%' || lower('raniclor') || '%' then 1
      when lower(drug) like '%' || lower('rifadin') || '%' then 1
      when lower(drug) like '%' || lower('rifampin') || '%' then 1
      when lower(drug) like '%' || lower('rocephin') || '%' then 1
      when lower(drug) like '%' || lower('smz-tmp') || '%' then 1
      when lower(drug) like '%' || lower('septra') || '%' then 1
      when lower(drug) like '%' || lower('septra ds') || '%' then 1
      when lower(drug) like '%' || lower('septra') || '%' then 1
      when lower(drug) like '%' || lower('solodyn') || '%' then 1
      when lower(drug) like '%' || lower('spectracef') || '%' then 1
      when lower(drug) like '%' || lower('streptomycin sulfate') || '%' then 1
      when lower(drug) like '%' || lower('sulfadiazine') || '%' then 1
      when lower(drug) like '%' || lower('sulfamethoxazole') || '%' then 1
      when lower(drug) like '%' || lower('trimethoprim') || '%' then 1
      when lower(drug) like '%' || lower('sulfatrim') || '%' then 1
      when lower(drug) like '%' || lower('sulfisoxazole') || '%' then 1
      when lower(drug) like '%' || lower('suprax') || '%' then 1
      when lower(drug) like '%' || lower('synercid') || '%' then 1
      when lower(drug) like '%' || lower('tazicef') || '%' then 1
      when lower(drug) like '%' || lower('tetracycline') || '%' then 1
      when lower(drug) like '%' || lower('timentin') || '%' then 1
      when lower(drug) like '%' || lower('tobi') || '%' then 1
      when lower(drug) like '%' || lower('tobramycin') || '%' then 1
      when lower(drug) like '%' || lower('trimethoprim') || '%' then 1
      when lower(drug) like '%' || lower('unasyn') || '%' then 1
      when lower(drug) like '%' || lower('vancocin') || '%' then 1
      when lower(drug) like '%' || lower('vancomycin') || '%' then 1
      when lower(drug) like '%' || lower('vantin') || '%' then 1
      when lower(drug) like '%' || lower('vibativ') || '%' then 1
      when lower(drug) like '%' || lower('vibra-tabs') || '%' then 1
      when lower(drug) like '%' || lower('vibramycin') || '%' then 1
      when lower(drug) like '%' || lower('zinacef') || '%' then 1
      when lower(drug) like '%' || lower('zithromax') || '%' then 1
      when lower(drug) like '%' || lower('zmax') || '%' then 1
      when lower(drug) like '%' || lower('zosyn') || '%' then 1
      when lower(drug) like '%' || lower('zyvox') || '%' then 1
    else 0
    end as antibiotic
  from prescriptions
  where drug_type in ('MAIN','ADDITIVE')
  -- we exclude routes via the eye, ears, or topically
  and route not in ('OU','OS','OD','AU','AS','AD', 'TP')
  and route not ilike '%ear%'
  and route not ilike '%eye%'
  -- we exclude certain types of antibiotics: topical creams, gels, desens, etc
  and drug not ilike '%cream%'
  and drug not ilike '%desensitization%'
  and drug not ilike '%ophth oint%'
  and drug not ilike '%gel%'
  -- other routes not sure about...
  -- for sure keep: ('IV','PO','PO/NG','ORAL', 'IV DRIP', 'IV BOLUS')
  -- ? VT, PB, PR, PL, NS, NG, NEB, NAS, LOCK, J TUBE, IVT
  -- ? IT, IRR, IP, IO, INHALATION, IN, IM
  -- ? IJ, IH, G TUBE, DIALYS
  -- ?? enemas??
)

, abx_poe_list as (
	select
		drug --, drug_name_generic
		, count(*) as numobs
	from t1
	where antibiotic = 1
	group by drug --, drug_name_generic
	order by numobs desc
)



-- abx_micro_poe
-- defines suspicion of infection using prescriptions + microbiologyevents
, abx as (
  select pr.hadm_id
  , pr.drug as antibiotic_name
  , pr.startdate as antibiotic_time
  , pr.enddate as antibiotic_endtime
  from prescriptions pr
  -- inner join to subselect to only antibiotic prescriptions
  inner join abx_poe_list ab
      on pr.drug = ab.drug
)
-- get cultures for each icustay
-- note this duplicates prescriptions
-- each ICU stay in the same hospitalization will get a copy of all prescriptions for that hospitalization
, ab_tbl as (
  select
        ie.subject_id, ie.hadm_id, ie.icustay_id
      , ie.intime, ie.outtime
      , abx.antibiotic_name
      , abx.antibiotic_time
      , abx.antibiotic_endtime
  from icustays ie
  left join abx
      on ie.hadm_id = abx.hadm_id
)
, me as (
  select hadm_id
    , chartdate, charttime
    , spec_type_desc
    , max(case when org_name is not null and org_name != '' then 1 else 0 end) as PositiveCulture
  from microbiologyevents
  group by hadm_id, chartdate, charttime, spec_type_desc
)
, ab_fnl as (
  select
      ab_tbl.icustay_id, ab_tbl.intime, ab_tbl.outtime
    , ab_tbl.antibiotic_name
    , ab_tbl.antibiotic_time
    , coalesce(me72.charttime,me72.chartdate) as last72_charttime
    , coalesce(me24.charttime,me24.chartdate) as next24_charttime

    , me72.positiveculture as last72_positiveculture
    , me72.spec_type_desc as last72_specimen
    , me24.positiveculture as next24_positiveculture
    , me24.spec_type_desc as next24_specimen
  from ab_tbl
  -- blood culture in last 72 hours
  left join me me72
    on ab_tbl.hadm_id = me72.hadm_id
    and ab_tbl.antibiotic_time is not null
    and
    (
      -- if charttime is available, use it
      (
          ab_tbl.antibiotic_time > me72.charttime
      and ab_tbl.antibiotic_time <= me72.charttime + interval '72' hour
      )
      or
      (
      -- if charttime is not available, use chartdate
          me72.charttime is null
      and ab_tbl.antibiotic_time > me72.chartdate
      and ab_tbl.antibiotic_time < me72.chartdate + interval '96' hour -- could equally do this with a date_trunc, but that's less portable
      )
    )
  -- blood culture in subsequent 24 hours
  left join me me24
    on ab_tbl.hadm_id = me24.hadm_id
    and ab_tbl.antibiotic_time is not null
    and me24.charttime is not null
    and
    (
      -- if charttime is available, use it
      (
          ab_tbl.antibiotic_time > me24.charttime - interval '24' hour
      and ab_tbl.antibiotic_time <= me24.charttime
      )
      or
      (
      -- if charttime is not available, use chartdate
          me24.charttime is null
      and ab_tbl.antibiotic_time > me24.chartdate
      and ab_tbl.antibiotic_time <= me24.chartdate + interval '24' hour
      )
    )
)
, ab_laststg as (
select
  icustay_id
  , antibiotic_name
  , antibiotic_time
  , last72_charttime
  , next24_charttime

  -- time of suspected infection: either the culture time (if before antibiotic), or the antibiotic time
  , case
      when coalesce(last72_charttime,antibiotic_time) is null
        then 0
      else 1 end as suspected_infection

  , coalesce(last72_charttime,antibiotic_time) as suspected_infection_time

  -- the specimen that was cultured
  , case
      when last72_charttime is not null
        then last72_specimen
      when next24_charttime is not null
        then next24_specimen
    else null
  end as specimen

  -- whether the cultured specimen ended up being positive or not
  , case
      when last72_charttime is not null
        then last72_positiveculture
      when next24_charttime is not null
        then next24_positiveculture
    else null
  end as positiveculture
from ab_fnl
)

, abx_micro_poe as (
	select
		icustay_id
		, antibiotic_name
		, antibiotic_time
		, last72_charttime
		, next24_charttime
		, suspected_infection_time
		-- -- the below two fields are used to extract data - modifying them facilitates sensitivity analyses
		-- , suspected_infection_time - interval '48' hour as si_starttime
		-- , suspected_infection_time + interval '24' hour as si_endtime
		, specimen, positiveculture
	from ab_laststg
	order by icustay_id, antibiotic_time
)

-- suspinfect_poe
, susp_abx as
(
  select icustay_id
    , suspected_infection_time
    , specimen, positiveculture
    , antibiotic_name
    , antibiotic_time
    , row_number() over (partition by icustay_id order by suspected_infection_time) as rn
  from abx_micro_poe
)

, suspinfect_poe as (
	select
		ie.icustay_id
		, ie.intime
		, antibiotic_name
		, antibiotic_time
		, suspected_infection_time as suspected_infection_time_poe
		, extract(EPOCH from ie.intime - suspected_infection_time) / 60.0 / 60.0 / 24.0 as suspected_infection_time_poe_days
		, specimen
		, positiveculture
	from icustays ie
	left join susp_abx sa
	  on ie.icustay_id = sa.icustay_id
	  and sa.rn = 1
	order by ie.icustay_id
)

, sepsis3_info as (
	select 
		sp.icustay_id,
		sofa,
		case 
			when suspected_infection_time_poe_days is not null then 1
			else 0
		end as suspicion_poe
	from 
		suspinfect_poe sp
	left join sofa so
		using(icustay_id)
)

select 
	icustay_id,
	case 
		when sofa >= 2 and suspicion_poe = 1 then 1
		else 0
	end as sepsis3
from 
	sepsis3_info
order by
	icustay_id;
