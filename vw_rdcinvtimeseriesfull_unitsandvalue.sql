EXPLAIN WITH df0 AS (
    SELECT inv.id,
        inv.scenarioname,
        inv.replicationnumber,
        inv.facilityname,
        inv.productname,
        inv.inventoryonhandquantity,
        inv."time"
    FROM simulationinventoryonhandreport inv
    WHERE inv.scenarioname = 'RDC HW'
), df1 AS (
    SELECT df0.scenarioname,
        df0.facilityname,
        df0.productname,
        df0.inventoryonhandquantity,
        df0."time",
        df0."time"::date AS simdate
    FROM df0
    ORDER BY df0.scenarioname, df0.facilityname, df0.productname, df0."time"::date, df0."time" DESC
), df2 AS (
    SELECT DISTINCT ON (df1.scenarioname, df1.facilityname, df1.productname, df1.simdate) 
        df1.scenarioname,
        df1.facilityname,
        df1.productname,
        df1.simdate,
        df1.inventoryonhandquantity
    FROM df1
), df3_1 AS (
    SELECT lower(inventorypolicies.facilityname) AS facilityname,
        lower(inventorypolicies.productname) AS productname,
        inventorypolicies.flowpath
    FROM inventorypolicies
), df3 AS (
        SELECT replace(replace(df3_1.facilityname, 'w12901x'::text, 'w12901'::text), 'w12901'::text, 'w12901x'::text) AS facilityname,
            df3_1.productname,
            df3_1.flowpath
    FROM df3_1
), df4 AS (
    SELECT df2.facilityname,
        df2.productname,
        df2.scenarioname,
        df2.simdate,
        df2.inventoryonhandquantity,
        df3.flowpath
    FROM df2
    LEFT JOIN df3 USING (facilityname, productname)
    ORDER BY df2.scenarioname, df2.facilityname, df2.productname, df2.simdate
), df5_1 AS (
    SELECT df4.scenarioname,
        df4.facilityname,
        df4.productname,
        df4.inventoryonhandquantity AS eodinventory,
        df4.simdate,
        df4.flowpath
    FROM df4
), df5_2 AS (
    SELECT lower(products.productname) AS productname,
        products.unitvalue::numeric AS unitvalue
    FROM products
), df5 AS (
    SELECT df5_1.productname,
        df5_1.scenarioname,
        df5_1.facilityname,
        df5_1.eodinventory,
        df5_1.simdate,
        df5_1.flowpath,
        df5_2.unitvalue,
        df5_2.unitvalue * df5_1.eodinventory AS valueonhand
    FROM df5_1
    LEFT JOIN df5_2 USING (productname)
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