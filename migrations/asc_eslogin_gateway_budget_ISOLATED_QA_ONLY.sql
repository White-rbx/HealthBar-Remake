-- Apply only to the isolated ESLogin QA database.
CREATE TABLE IF NOT EXISTS asc_qa_pair_gateway_budget (
 op TEXT PRIMARY KEY CHECK(op IN ('pair/start','pair/poll','session','heartbeat','logout')),
 minute_bucket INTEGER NOT NULL, minute_count INTEGER NOT NULL CHECK(minute_count>0),
 day_bucket INTEGER NOT NULL, day_count INTEGER NOT NULL CHECK(day_count>0)
);
