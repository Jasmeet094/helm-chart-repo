#Added cookie settings to remediate app pen test results, Taylor Lewick, 10/8/2019
CSRF_COOKIE_SECURE = 'TRUE'
CSRF_COOKIE_HTTPONLY = 'TRUE'
SESSION_COOKIE_SECURE = 'TRUE'
SESSION_COOKIE_HTTPONLY = 'TRUE'

DB = {
    'ENGINE': 'django.db.backends.postgresql_psycopg2',
    'NAME': 'djangostack',
    'USER': 'bitnami',
    'PASSWORD': '{{postgres_password}}',
    'HOST': '{{env}}{{shard}}db1pvt.mobilehealthconsumer.com',
    'PORT': '6432',
}

MONGOENGINE= {
    'db': 'mhc',
    'host': '127.0.0.1',
    'port': 27017
}


CELERY_ACCEPT_CONTENT = ['pickle', 'json']
CELERY_TASK_SERIALIZER= 'pickle'
CELERY_RESULT_SERIALIZER='pickle'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'
BROKER_URL = 'amqp://'

CELERY_TASK_RESULT_EXPIRES = '3600'

BASE_URL = 'https://{{baseurl}}.mobilehealthconsumer.com'

MEDIA_ROOT = '/home/mhc/mhc-backend/media/'
MEDIA_URL='https://{{env}}{{shard}}.mobilehealthconsumer.com/media/'
STATIC_ROOT = '/home/mhc/mhc-backend/static/'
STATIC_URL='https://{{env}}{{shard}}.mobilehealthconsumer.com/static/'
SHARD_INDEPENDENT_DOMAIN = 'https://{{weburl}}.mobilehealthconsumer.com'

# STATICFILES_DIRS = (
#     '/home/mhc/mhc-backend/static',
# )

TEMPLATE_DIRS = (
    '/home/mhc/mhc-backend/templates',
)

EMAIL_HOST = 'email-smtp.{{email_ses_region}}.amazonaws.com'
EMAIL_PORT = '587'
EMAIL_HOST_USER = '{{email_aws_user}}'
EMAIL_HOST_PASSWORD = '{{email_aws_password}}'
EMAIL_USE_TLS = True

MHC_HEALTHEQUITY_CONFIGURATION={
    'location':'https://PartnerTest.healthequity.com/Partner/MemberBalanceWebService.asmx',
    'wsdl':'https://PartnerTest.healthequity.com/Partner/MemberBalanceWebService.asmx?wsdl'
}

MHC_INSIGNIAHEALTH_CONFIGURATION={'location':'https://servicesUAT.insigniahealth.com/Services/IHAPI.svc/',
                                  'clientExtId':'305071908',
                                  'clientPassKey':'{{client_pass_key}}',
                                  'subgroupExtId':'465720679'}

MHC_SHARD_NAME='{% if shard == 'log' %}s01{% else %}{{db_shard_name}}{% endif %}'
LOGIN_SERVER = '{% if shard == 'log' %}{% else %}https://{{env}}logw1.mobilehealthconsumer.com{% endif %}' # ToDo: Test to ensure this works in the ansible

LOGIN_SERVER_SECRET='{{login_server_secret}}'
BLACKHAWK_CERT_FILE = "/home/mhc/crypt/blackhawk/Reward-Fenton-MobileHealthConsumers-API-Integration.pem"

ALLOWED_HOSTS = ['*']
API_ROOT = '/partners'
VERIFY_SSL = 'True'

from saml2 import BINDING_HTTP_POST
from saml2.saml import NAME_FORMAT_BASIC

MHC_SSO_SAMLIDPCONFIG = {
    "accepted_time_diff" : 100000,
    "entityid" : "https://idp.mobilehealthconsumer.com",
    "name" : "MHC IDP",
    "service": {
        "idp": {
            "endpoints" : {
                "single_sign_on_service" : [
                        ("https://idp.mobilehealthconsumer.com",
                            BINDING_HTTP_POST)],
            },
            "policy" : {
                "default" : {
                    "name_form" : NAME_FORMAT_BASIC
                }
            },
        }
    },
    "key_file" : "/home/mhc/crypt/samldir/samlkey.pem",
    "cert_file" : "/home/mhc/crypt/samldir/samlcert.pem",
    "xmlsec_binary" : "/usr/bin/xmlsec1",
    "attribute_map_dir" : "/home/mhc/mhc-backend/samldir/attrmaps",
}

MHC_SAMLCONFIGS = [{
        "accepted_time_diff" : 2000000,
        "entityid" : "https://mobilehealthconsumer.com/",
        "name" : "MHC SAML TEST SP",
        "service": {
            "sp": {
                "allow_unsolicited" : 'true',
                "endpoints" : {
                    "assertion_consumer_service" : [
                            ("https://{{weburl}}.mobilehealthconsumer.com/partners/SAMLEntry/",
                                BINDING_HTTP_POST)],
                },
            }
        },
        "key_file" : "/home/mhc/crypt/spsamlkey.pem",
        "cert_file" : "/home/mhc/crypt/samlcert.pem",
        "xmlsec_binary" : "/usr/bin/xmlsec1",
        "metadata": {
            "local": ["/home/mhc/mhc-backend/configs/testmetadata.xml"],
        }
    }
]

OAUTH_KEYS_OVERRIDE = {'Garmin':{'clientKey':'c3d830a6-15a6-4e11-8ad5-016b4e291916','clientSecret':'4vPd6Jw7UKb4kkHUGcCDkMU0jghJFUjW48w'}}

DEBUG = {% if env == "p" %}False{% else %}True{% endif %}

APNS_CERTIFICATES = {
    'MHCU' : '/home/mhc/crypt/apns/MHCUniversalProductionAPNS.pem',
    'MHC' : '/home/mhc/crypt/apns/MobileHealthProductionAPNS.pem',
    'SH' : '/home/mhc/crypt/apns/StudentHealthProductionAPNS.pem',
    'CP' : '/home/mhc/crypt/apns/CarePlusProductionAPNS.pem',
    'AW' : '/home/mhc/crypt/apns/AlightWellbeingProductionAPNS.pem',
    'EP' : '/home/mhc/crypt/apns/EngagementPointProductionAPNS.pem'
}
APNS_CERTIFICATE_FILE_PATH = '/home/mhc/crypt/MobileHealthProductionAPNS.pem'