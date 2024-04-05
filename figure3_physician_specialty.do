***************INCORPORATING PA SPENDING WITH MEDICAL SPECIALTIES**********

clear
set more off

global path ""
cd "$path"

use Medicare_physician_specialty, clear

tab specialty

*Drop institutions or non-clinicians or pediatrics
gen flag=.
replace flag=1 if specialty=="All Other Suppliers"
replace flag=1 if specialty=="Ambulance Service Provider"
replace flag=1 if specialty=="Ambulatory Surgical Center"
replace flag=1 if specialty=="Audiologist"
replace flag=1 if specialty=="Centralized Flu"
replace flag=1 if specialty=="Certified Clinical Nurse Specialist"
replace flag=1 if specialty=="Chiropractic"
replace flag=1 if specialty=="Dentist"
replace flag=1 if specialty=="Clinic or Group Practice"
replace flag=1 if specialty=="Clinical Laboratory" 
replace flag=1 if specialty=="Licensed Clinical Social Worker"
replace flag=1 if specialty=="Mammography Center"
replace flag=1 if specialty=="Mass Immunizer Roster Biller"
replace flag=1 if specialty=="Medicare Diabetes Preventive Program"
replace flag=1 if specialty=="Certified Nurse Midwife"
replace flag=1 if specialty=="Hematopoietic Cell Transplantation and Cellular Therapy"
replace flag=1 if specialty=="Independent Diagnostic Testing Facility (IDTF)"
replace flag=1 if specialty=="Nurse Practitioner"
replace flag=1 if specialty=="Occupational Therapist in Private Practice"
replace flag=1 if specialty=="Opioid Treatment Program"
replace flag=1 if specialty=="Oral Surgery (Dentist only)"
replace flag=1 if specialty=="Osteopathic Manipulative Medicine"
replace flag=1 if specialty=="Peripheral Vascular Disease"
replace flag=1 if specialty=="Pharmacy"
replace flag=1 if specialty=="Physical Therapist in Private Practice"
replace flag=1 if specialty=="Physician Assistant"
replace flag=1 if specialty=="Portable X-Ray Supplier"
replace flag=1 if specialty=="Public Health or Welfare Agency"
replace flag=1 if specialty=="Radiation Therapy Center"
replace flag=1 if specialty=="Registered Dietitian or Nutrition Professional"
replace flag=1 if specialty=="Slide Preparation Facility"
replace flag=1 if specialty=="Speech Language Pathologist"
replace flag=1 if specialty=="Undefined Physician type"
replace flag=1 if specialty=="Undersea and Hyperbaric Medicine"
replace flag=1 if specialty=="Unknown Supplier/Provider Specialty"
replace flag=1 if specialty=="Pediatric Medicine"

drop if flag==1
drop flag

*Combining specialties
tab specialty

replace specialty="Cardiology" if specialty=="Advanced Heart Failure and Transplant Cardiology" | specialty=="Clinical Cardiac Electrophysiology" | specialty=="Interventional Cardiology" |  specialty=="Adult Congenital Heart Disease" | specialty=="Intensive Cardiac Rehabilitation"
replace specialty="Allergy or immunology" if specialty=="Allergy/ Immunology"
replace specialty="Other" if specialty=="Hospice and Palliative Care" | specialty=="Medical Genetics and Genomics" | specialty=="Medical Toxicology" | specialty=="Sleep Medicine" | specialty=="Sports Medicine" | specialty=="Podiatry"
replace specialty="General Practice" if specialty=="Preventive Medicine"
replace specialty="Anesthesiology" if specialty=="Anesthesiology Assistant" | specialty=="Certified Registered Nurse Anesthetist (CRNA)"
replace specialty="Obstetrics & Gynecology" if specialty=="Gynecological Oncology"
replace specialty="Pulmonary Disease" if specialty=="Critical Care (Intensivists)"
replace specialty="General Practice" if specialty=="Geriatric Medicine"
replace specialty="Orthopedic Surgery" if specialty=="Hand Surgery"
replace specialty="Hematology or oncology" if specialty=="Hematology" | specialty=="Hematology-Oncology" | specialty=="Medical Oncology"
replace specialty="Pain Management" if specialty=="Interventional Pain Management"
replace specialty="Diagnostic Radiology" if specialty=="Nuclear Medicine"
replace specialty="Psychiatry" if specialty=="Addiction Medicine" | specialty=="Geriatric Psychiatry" | specialty=="Neuropsychiatry" | specialty=="Psychologist, Clinical"
replace specialty="Dermatology" if specialty=="Micrographic Dermatologic Surgery"
replace specialty="Ophthalmology" if specialty=="Optometry"
replace specialty="Other Surgery" if specialty=="Vascular Surgery" | specialty=="Plastic and Reconstructive Surgery" | specialty=="Neurosurgery" | specialty=="Thoracic Surgery" | specialty=="Cardiac Surgery" | specialty=="Maxillofacial Surgery" | specialty=="Surgical Oncology" | specialty=="Colorectal Surgery (Proctology)"

tab specialty
tab specialty, sort
codebook specialty

duplicates report hcpcs specialty
duplicates tag hcpcs specialty, gen(tag)
sort specialty hcpcs

bysort specialty hcp: egen total_spending2=total(total_spending) if tag>0
replace total_spending2=total_spending if tag==0
duplicates drop specialty hcp, force

drop total_spending
ren total_spending2 total_spending

bysort specialty: egen temp=total(total_spending)
gen prop_tot_spendingspecialty2=total_spending/temp

drop prop_tot_spendingspecialty temp tag
ren prop_tot_spendingspecialty2 prop_tot_spendingspecialty

sort hc sp
count
codebook specialty
save physician_specialty_for_analysis, replace

clear

insheet using figure3_PA_data.xlsx, clear

sort hcpcscode
keep hcpcscode description humana2020 aetnabinary wellcarebinary united cigna cptcategory atleastonerequirepriorauth numinsurersthatrequirepr allrequirepriorauth

sort hcpcscode
rename hcpcscode hcpcs

save hcpcs_services.dta, replace

use physician_specialty_for_analysis, clear
merge hcpcs using hcpcs_services

tab _

drop if _==1 /*_==1 codes seem to be deleted when I check online*/
drop if _==2 /*we're only concerned with _=3 codes anyway because we have the total spending by specialty*/

bysort specialty: egen prop_PA_specialty_atleastone=total(prop_tot_spendingspecialty) if atleastone=="TRUE"
bysort specialty: egen sum_PA_specialty_atleastone=total(total_spending) if atleastone=="TRUE"

bysort specialty: egen prop_PA_specialty_humana=total(prop_tot_spendingspecialty) if humana2020=="TRUE"
bysort specialty: egen sum_PA_specialty_humana=total(total_spending) if humana2020=="TRUE"

bysort specialty: egen prop_PA_specialty_aetna=total(prop_tot_spendingspecialty) if aetnabinary=="TRUE"
bysort specialty: egen sum_PA_specialty_aetna=total(total_spending) if aetnabinary=="TRUE"

bysort specialty: egen prop_PA_specialty_wellcare=total(prop_tot_spendingspecialty) if wellcarebinary=="TRUE"
bysort specialty: egen sum_PA_specialty_wellcare=total(total_spending) if wellcarebinary=="TRUE"

bysort specialty: egen prop_PA_specialty_united=total(prop_tot_spendingspecialty) if united=="TRUE"
bysort specialty: egen sum_PA_specialty_united=total(total_spending) if united=="TRUE"

bysort specialty: egen prop_PA_specialty_cigna=total(prop_tot_spendingspecialty) if cigna=="TRUE"
bysort specialty: egen sum_PA_specialty_cigna=total(total_spending) if cigna=="TRUE"

bysort specialty: egen prop_PA_specialty_all=total(prop_tot_spendingspecialty) if allrequirepriorauth=="TRUE"
bysort specialty: egen sum_PA_specialty_all=total(total_spending) if allrequirepriorauth=="TRUE"

save specialty_PA.dta, replace

foreach var of varlist prop_PA_specialty_atleastone sum_PA_specialty_atleastone prop_PA_specialty_humana sum_PA_specialty_humana prop_PA_specialty_aetna sum_PA_specialty_aetna prop_PA_specialty_wellcare sum_PA_specialty_wellcare prop_PA_specialty_united sum_PA_specialty_united prop_PA_specialty_cigna sum_PA_specialty_cigna prop_PA_specialty_all sum_PA_specialty_all {
	bysort specialty: egen `var'2=min(`var')
}

bysort specialty: egen total_spending2=total(total_spending)

duplicates drop specialty, force

count

keep specialty total_spending2 prop_PA_specialty_atleastone2 sum_PA_specialty_atleastone2 prop_PA_specialty_humana2 sum_PA_specialty_humana2 prop_PA_specialty_aetna2 sum_PA_specialty_aetna2 prop_PA_specialty_wellcare2 sum_PA_specialty_wellcare2 prop_PA_specialty_united2 sum_PA_specialty_united2 prop_PA_specialty_cigna2 sum_PA_specialty_cigna2 prop_PA_specialty_all2 sum_PA_specialty_all2

order specialty total_spending2 prop_PA_specialty_atleastone2 sum_PA_specialty_atleastone2 prop_PA_specialty_humana2 sum_PA_specialty_humana2 prop_PA_specialty_aetna2 sum_PA_specialty_aetna2 prop_PA_specialty_wellcare2 sum_PA_specialty_wellcare2 prop_PA_specialty_united2 sum_PA_specialty_united2 prop_PA_specialty_cigna2 sum_PA_specialty_cigna2 prop_PA_specialty_all2 sum_PA_specialty_all2

outsheet using specialty_proportion_spending.csv, comma replace

