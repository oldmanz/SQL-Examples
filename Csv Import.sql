--Create Temp Table.  Cols must line up with csv.
CREATE TABLE muni.temp( manhole_name TEXT, group_id INTEGER, latitude DECIMAL(9,6), longitude DECIMAL(9,6) );

--Copy CSV to Temp Table.  The csv needs to be on the server machine.
---For Docker, you can copy the file over with a command not unlike this
----sudo docker cp mh.csv postgis:/mh.csv
COPY muni.temp FROM '/mh.csv' WITH (FORMAT csv, HEADER);

--Now we will add geom to the temp table, populate it, and set srid.
ALTER TABLE muni.temp ADD COLUMN geom Geometry;
UPDATE muni.temp SET geom = 'POINT ('||longitude||' '||latitude||')';
SELECT UpdateGeometrySRID('muni', 'temp','geom',4326);

--Copy data over to real table
INSERT INTO muni.manholes(manhole_name, group_id, geom)
SELECT manhole_name, group_id, geom FROM muni.temp;

--Finally, drop temp table
drop table muni.temp;