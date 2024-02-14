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
	
SELECT drug.generic_name, prescription.total_drug_cost
FROM drug
LEFT JOIN prescription
ON drug.drug_name = prescription.drug_name
WHERE total_drug_cost IS NOT NULL
GROUP BY drug.generic_name, prescription.total_drug_cost
ORDER BY prescription.total_drug_cost DESC

	-- Pirfenidone
	
	-- b: Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. 

SELECT drug.generic_name, ROUND(prescription.total_drug_cost/30,2) AS cost_per_day
FROM drug
LEFT JOIN prescription
ON drug.drug_name = prescription.drug_name
WHERE total_drug_cost IS NOT NULL
GROUP BY drug.generic_name, prescription.total_drug_cost
ORDER BY cost_per_day DESC


