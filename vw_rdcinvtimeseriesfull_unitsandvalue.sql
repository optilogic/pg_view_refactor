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
), df5_1 AS (
    SELECT df2.facilityname,
        df2.productname,
        df2.scenarioname,
        df2.simdate,
        df2.inventoryonhandquantity AS eodinventory,
        ip.flowpath
    FROM df2
    LEFT JOIN inventorypolicies ip on df2.facilityname = replace(replace(lower(ip.facilityname), 'w12901x', 'w12901'), 'w12901', 'w12901x')
        and df2.productname = lower(ip.productname)
), df5 AS (
    SELECT df5_1.productname,
        df5_1.scenarioname,
        df5_1.facilityname,
        df5_1.eodinventory,
        df5_1.simdate,
        df5_1.flowpath,
        p.unitvalue::numeric as unitvalue,
        p.unitvalue::numeric * df5_1.eodinventory AS valueonhand
    FROM df5_1
    LEFT JOIN products p ON df5_1.productname = lower(p.productname)
), df6 AS (
    SELECT df5.scenarioname,
        df5.flowpath,
        sum(df5.eodinventory) AS unitsonhand,
        sum(df5.valueonhand) AS valueonhand,
        df5.simdate
    FROM df5
    GROUP BY df5.scenarioname, df5.flowpath, df5.simdate
)
SELECT df6.scenarioname,
    df6.flowpath,
    df6.unitsonhand,
    df6.valueonhand,
    df6.simdate
FROM df6;