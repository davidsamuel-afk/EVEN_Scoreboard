-- Query 1: Get the count of fresh leads per owner
SELECT "Owner", COUNT(*) AS lead_count
FROM read_csv_auto('~/Downloads/6403221c-83da-4d38-be1a-b22c72398e2c.csv')
WHERE "Lead Stage" = 'Fresh'
  AND "Phone Number" IS NOT NULL
  AND "Total Phone Call" IS NULL
GROUP BY "Owner"
ORDER BY lead_count DESC;

-- Query 2: Get the detailed list of those fresh leads
SELECT "Owner", "Phone Number", "First Name", "Last Name", "Lead Stage", "Last call on", "Last call update"
FROM read_csv_auto('~/Downloads/6403221c-83da-4d38-be1a-b22c72398e2c.csv')
WHERE "Lead Stage" = 'Fresh'
  AND "Phone Number" IS NOT NULL
  AND "Total Phone Call" IS NULL;

-- Query 2: Get the detailed list of those Follow up leads
SELECT 
    "Owner", 
    "Phone Number", 
    "First Name", 
    "Last Name", 
    "Lead Stage", 
    "Last Call on", 
    "Last call update", 
    "Expected Closure Date",
    "Phone Call Follow Up"  -- Added so reps can see the scheduled time slot
FROM read_csv_auto('~/Downloads/6403221c-83da-4d38-be1a-b22c72398e2c.csv')
WHERE (
    -- Section A: Follow Ups & Good Leads
    ("Lead Stage" IN ('Phone Call Follow-Up', 'Working', 'Good Lead')
     OR "Last call update" IN ('Follow Up', 'Requested a call back', 'Good Lead Interested'))
    OR 
    -- Section B: Expected Closures / Home Visits
    ("Lead Stage" IN ('HV Requested', 'Home Visit Follow-Up', 'HV Completed')
     OR "Last call update" IN ('Home Visit Required', 'HV Arranged', 'HV Completed'))
    OR 
    -- Section C: Follow up Date is today
    (CAST("Phone Call Follow Up" AS DATE) = CURRENT_DATE)
  )
  -- Safety exclusion filter: Keep active pipeline cleanly separated from dead records or paid files
  AND "Lead Stage" NOT IN ('Payment Done', 'Paid', 'Renewed', 'Not Interested', 'DNP Forever')
  
  -- RFNF Rejection Filter: Removes all variants of Reason For No Follow-up
  AND "Last call update" NOT LIKE 'RFNF%'
  AND "Phone Number" IS NOT NULL;