insert into owners (ownerid, service, service_id, username) values (1, 'github', '1234', 'test');
insert into repos (ownerid, repoid, service_id) values (1, 1, '7890');
insert into commits (repoid, commitid, chunks, timestamp, state) values (1, 'abc', '{test,test,test}'::text[], now(), 'complete');
