EXPLAIN WITH df2 AS (
    SELECT  DISTINCT ON (inv.scenarioname, inv.facilityname, inv.productname, inv."time"::date) 
        inv.scenarioname,
        inv.facilityname,
        inv.productname,
        inv.inventoryonhandquantity,
        inv."time"::date AS simdate
    FROM simulationinventoryonhandreport inv
    WHERE inv.scenarioname = 'RDC HW'
    ORDER BY inv.scenarioname, inv.facilityname, inv.productname, inv."time"::date, inv."time" DESC
), df5 AS (
    SELECT df2.facilityname,
        df2.productname,
        df2.scenarioname,
        df2.simdate,
        df2.inventoryonhandquantity AS eodinventory,
        ip.flowpath,
        p.unitvalue::numeric * df2.inventoryonhandquantity AS valueonhand
    FROM df2
    LEFT JOIN inventorypolicies ip on df2.facilityname = replace(replace(lower(ip.facilityname), 'w12901x', 'w12901'), 'w12901', 'w12901x')
        and df2.productname = lower(ip.productname)
    LEFT JOIN products p ON df2.productname = lower(p.productname)
)
SELECT df5.scenarioname,
    df5.flowpath,
    sum(df5.eodinventory) AS unitsonhand,
    sum(df5.valueonhand) AS valueonhand,
    df5.simdate
FROM df5
GROUP BY df5.scenarioname, df5.flowpath, df5.simdate
