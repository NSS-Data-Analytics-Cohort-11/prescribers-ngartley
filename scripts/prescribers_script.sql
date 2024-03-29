-- Question 1
	-- a: Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
	
SELECT prescription.npi, SUM(prescription.total_claim_count) AS total_claims
FROM prescription
GROUP BY prescription.npi
ORDER BY total_claims DESC

	-- b: Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
	
SELECT prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claims 
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description, prescription.npi
ORDER BY total_claims DESC
LIMIT 1;

-- Question 2
	-- a: Which specialty had the most total number of claims (totaled over all drugs)?
	
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claims  
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE prescription.total_claim_Count IS NOT NULL
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC

	-- b: Which specialty had the most total number of claims for opioids?

SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_opioid_claims
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
LEFT JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY total_opioid_claims DESC

	-- Challenge c: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
	
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.specialty_description
HAVING SUM(prescription.total_claim_count) IS NULL

--	Answer: 15 have no prescriptions. 

-- Question 3
	-- a: Which drug (generic_name) had the highest total drug cost?
	
SELECT drug.generic_name, SUM(prescription.total_drug_cost) AS sum_total_drug_cost
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY sum_total_drug_cost DESC

	-- Insulin Glargine
	
	-- b: Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. 

SELECT drug.generic_name, ROUND(SUM(prescription.total_drug_cost),2)/SUM(total_day_supply) AS sum_total_drug_cost
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug.generic_name
ORDER BY sum_total_drug_cost DESC

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
INNER JOIN fips_county
ON cbsa.fipscounty = fips_county.fipscounty
INNER JOIN population
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
	
-- Question 6
	-- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
	
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= '3000'

	-- b.  For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
	
SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag
FROM prescription
LEFT JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE total_claim_count >= '3000'

	-- c. Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.
	
SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag, CONCAT(prescriber.nppes_provider_first_name, ' ', prescriber.nppes_provider_last_org_name) AS prescriber_name
FROM drug
LEFT JOIN prescription
ON drug.drug_name = prescription.drug_name
LEFT JOIN prescriber
ON prescription.npi = prescriber.npi
WHERE total_claim_count >= '3000'

-- Question 7
	-- a.  First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
	
SELECT prescriber.npi, drug.drug_name
FROM drug
CROSS JOIN prescriber
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y'

	-- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT
	prescriber.npi,
	drug.drug_name,
	(SELECT
	 	SUM(prescription.total_claim_count)
	 FROM prescription
	 WHERE prescriber.npi = prescription.npi
	 AND prescription.drug_name = drug.drug_name) as total_claims
FROM prescriber
CROSS JOIN drug
INNER JOIN prescription
using (npi)
WHERE 
	prescriber.specialty_description = 'Pain Management' AND
	prescriber.nppes_provider_city = 'NASHVILLE' AND
	drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name
ORDER BY prescriber.npi DESC;

--
(SELECT p.npi, d.drug_name, pres.total_claim_count
FROM prescriber AS p
	CROSS JOIN
		(SELECT drug_name
		FROM drug
		WHERE opioid_drug_flag = 'Y') AS d
 	LEFT JOIN prescription AS pres
		ON (p.npi, d.drug_name) = (pres.npi, pres.drug_name)
WHERE (p.specialty_description, p.nppes_provider_city) = ('Pain Management', 'NASHVILLE'));

	-- c.  Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT prescriber.npi, drug.drug_name,
	COALESCE(prescription.total_claim_count,0)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING(npi, drug_name)
WHERE prescriber.specialty_description = 'Pain Management' AND
	prescriber.nppes_provider_city = 'NASHVILLE' AND
	drug.opioid_drug_flag = 'Y';
	