-- Question 1
	-- a: Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
	
SELECT prescription.npi, COUNT(prescription.npi) AS total_claims
FROM prescription
GROUP BY prescription.npi
ORDER BY total_claims DESC

	-- b: Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
	
SELECT prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description, COUNT(prescription.npi) AS total_claims 
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description, prescription.npi
ORDER BY total_claims DESC

-- Question 2
	-- a: Which specialty had the most total number of claims (totaled over all drugs)?
	
SELECT prescriber.specialty_description, COUNT(prescription.npi) AS total_claims  
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC

	-- b: Which specialty had the most total number of claims for opioids?

SELECT prescriber.specialty_description, COUNT(drug.opioid_drug_flag) AS total_opioid_claims
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
LEFT JOIN drug
ON prescription.drug_name = drug.drug_name
GROUP BY prescriber.specialty_description
ORDER BY total_opioid_claims DESC

	-- Challenge c: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
	
SELECT prescriber.specialty_description, COUNT(prescription.npi) AS total_claims
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claims

--	Answer: Yes, there are 15 specialties that have no prescriptions associated.

-- Question 3
	-- a: Which drug (generic_name) had the highest total drug cost?
	
SELECT drug.generic_name, SUM(prescription.total_drug_cost) AS total_drug_cost
FROM drug
LEFT JOIN prescription
ON drug.drug_name = prescription.drug_name
WHERE total_drug_cost IS NOT NULL
GROUP BY drug.generic_name, prescription.total_drug_cost
ORDER BY prescription.total_drug_cost DESC

	-- Pirfenidone
	
	-- b: Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. 

SELECT drug.generic_name, ROUND (prescription.total_drug_cost/30,2) AS cost_per_day
FROM drug
LEFT JOIN prescription
ON drug.drug_name = prescription.drug_name
WHERE total_drug_cost IS NOT NULL
GROUP BY drug.generic_name, prescription.total_drug_cost
ORDER BY cost_per_day DESC

-- Question 4
	-- a: For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. 

SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antiobiotic'
		ELSE 'Neither' END AS drug_type
FROM drug

	-- b: Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
	
SELECT SUM(prescription.total_drug_cost) AS Money,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'Antiobiotic'
		ELSE 'Neither' END AS drug_type
FROM drug
LEFT JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug_type
ORDER BY money DESC

-- Question 5 
	-- a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
	
SELECT COUNT(cbsa)
FROM cbsa
LEFT JOIN fips_county
ON cbsa.fipscounty = fips_county.fipscounty
WHERE fips_county.state = 'TN'

	-- b.  Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
	
SELECT cbsa.cbsaname, SUM(population.population) AS total_population
FROM cbsa
LEFT JOIN fips_county
ON cbsa.fipscounty = fips_county.fipscounty
LEFT JOIN population
ON fips_county.fipscounty = population.fipscounty
WHERE fips_county.state = 'TN'
GROUP BY cbsa.cbsaname
ORDER BY total_population DESC

	-- Answer: Nashville Davidson- Murfreesboro- Franklin is the largest. Smalled is Morristown, TN

	-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
	
SELECT cbsa.cbsaname, fips_county.county, SUM(population.population) AS total_population
FROM cbsa
FULL JOIN fips_county
ON cbsa.fipscounty = fips_county.fipscounty
FULL JOIN population
ON fips_county.fipscounty = population.fipscounty
WHERE fips_county.state = 'TN'
	AND cbsa.cbsaname IS NULL
GROUP BY cbsa.cbsaname, fips_county.county
ORDER BY total_population DESC

	-- Answer: Sevier county has the highest population without being included in a CBSA. Population is 95,523.
