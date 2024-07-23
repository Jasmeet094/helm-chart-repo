use mhc;
db.m_audit_event.createIndex({"instanceID" : 1},{"background" : true})
db.m_audit_event.createIndex({"timestamp":1},{"background":true })
db.m_audit_event.createIndex({"model":1},{"background":true })
db.m_audit_event.save()

db.m_audit_initiation_event.createIndex({"user" : 1},{"background" : true})
db.m_audit_initiation_event.createIndex({"timestamp":1},{"background":true })
db.m_audit_initiation_event.save()

db.m_event.createIndex({"name":1},{"background" : true})
db.m_event.createIndex({"user":1},{"background":true })
db.m_event.createIndex({"date":1},{"background":true })
db.m_event.save()

db.createCollection("m_event_delivery");