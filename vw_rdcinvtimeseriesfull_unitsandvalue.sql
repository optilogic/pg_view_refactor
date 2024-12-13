EXPLAIN WITH eodInventoryOnHand AS (
    SELECT  DISTINCT ON (inv.facilityname, inv.productname, inv."time"::date) 
        inv.facilityname,
        inv.productname,
        inv.inventoryonhandquantity,
        inv."time"::date AS simdate
    FROM simulationinventoryonhandreport inv
    WHERE inv.scenarioname = 'RDC HW'
    ORDER BY inv.facilityname, inv.productname, inv."time"::date, inv."time" DESC
), eodInventoryValues AS (
    SELECT eod.facilityname,
        eod.productname,
        eod.simdate,
        eod.inventoryonhandquantity AS eodinventory,
        ip.flowpath,
        p.unitvalue::numeric * eod.inventoryonhandquantity AS valueonhand
    FROM eodInventoryOnHand eod
    LEFT JOIN inventorypolicies ip on eod.facilityname = replace(replace(lower(ip.facilityname), 'w12901x', 'w12901'), 'w12901', 'w12901x')
        and eod.productname = lower(ip.productname)
    LEFT JOIN products p ON eod.productname = lower(p.productname)
)
SELECT 'RDC HW' AS scenarioname,
    flowpath,
    sum(eodinventory) AS unitsonhand,
    sum(valueonhand) AS valueonhand,
    simdate
FROM eodInventoryValues
GROUP BY flowpath, simdate
