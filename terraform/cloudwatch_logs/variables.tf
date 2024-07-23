variable "loggroup_default_list" {
  default = ["/var/ossec/logs/ossec.log", "/var/log/syslog", "/var/ossec/logs/alerts/alerts.log", "/var/ossec/logs/firewall/firewall.log", "/var/log/auth.log", "/var/log/apt/history.log", "/var/log/apt/term.log"]
}

variable "loggroup_web_list" {
  default = ["/home/mhc/logs/celerybg.log", "/home/mhc/logs/celerybglowbandwidth.log", "/home/mhc/logs/celeryd.log", "/home/mhc/logs/celeryhr.log", "/home/mhc/logs/mhc_uwsgi.log"]
}

variable "loggroup_db_list" {
  default = ["/var/log/postgresql/postgresql-9.6-main.log", "/var/log/mongodb/mongodb.log"]
}