DB = {
    'ENGINE': 'django.db.backends.postgresql_psycopg2',
    'NAME': 'djangostack',
    'USER': 'bitnami',
    'PASSWORD': 'a1690aef01c815f4',
    'HOST': '10.248.141.229',
    'PORT': '6432',
}


BROKER_URL = 'redis://localhost:6379/0'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'


MEDIA_ROOT = '/home/mhc/mhc-backend/media/'

MEDIA_URL = 'https://www.mobilehealthconsumer.com/media/'
#MEDIA_URL = 'http://184.169.162.239/Backend/media/'
#MEDIA_URL = 'http://184.169.212.149/Backend/media/'

STATIC_ROOT = '/home/mhc/mhc-backend/static/'

STATIC_URL = 'https://www.mobilehealthconsumer.com/static/'
#STATIC_URL = 'http://184.169.162.239/Backend/static/'
#STATIC_URL = 'http://184.169.212.149/Backend/static/'

STATICFILES_DIRS = (
    '/home/mhc/mhc-backend/static',
)

TEMPLATE_DIRS = (
    '/home/mhc/mhc-backend/templates',
)

EMAIL_HOST = 'email-smtp.us-east-1.amazonaws.com'

EMAIL_PORT = '587'

EMAIL_HOST_USER = 'AKIAJUM7GRCMRJIS776Q'

EMAIL_HOST_PASSWORD = 'AiAFzZ1BfvKarJAc9NuO+AO+l9e6reoJZYd3GT64BIFt'

EMAIL_USE_TLS = True

APNS_CERTIFICATE_FILE_PATH = '/home/mhc/crypt/MobileHealthProductionAPNS.pem'

DEBUG = False

#MHC_HEALTHEQUITY_CONFIGURATION={'location':'https://www.healthequity.com/Partner/MemberBalanceWebService.asmx','wsdl':'https://www.healthequity.com/Partner/MemberBalanceWebService.asmx?wsdl'}
MHC_HEALTHEQUITY_CONFIGURATION={'location':'https://demo.mobilehealthconsumer.com/Partner/MemberBalanceWebService.asmx','wsdl':'https://demo.mobilehealthconsumer.com/Partner/MemberBalanceWebService.asmx?wsdl'}

#HEADER_BACKGROUND_COLOR = '#60a0ff'
MHC_INSIGNIAHEALTH_CONFIGURATION={'location':'https://services.insigniahealth.com:4433/services/ihapi.svc/',
                                  'clientExtId':'305071908',
                                  'clientPassKey':'bUpreh*TR#6ehet',
                                  'subgroupExtId':'465720679'}

MHC_SSO_WEBMDPGP_CONFIGURATION={'passphrases':
                                    {'AC5FAE9A':'password',
                                    'C7B5AD83':'mjJFHAFOjXKl4gObfrEc'}
}

#MHC_ANTHEM_CAREGAP_CONFIGURATION = {
    #'host': 'uat-ext.api.anthem.com',
    #'port': 18443,
    #'user': 'srcSOAapiMHC',
    #'password': 'Jk0WS38FyD',
    #'apikey': 'vL7gkhJWwauB5J5z5UOmpPLgkFKWk66O',
    #'verify': False,
    #'batchSize': 30
#}

MHC_ANTHEM_CAREGAP_CONFIGURATION = {
    'host': 'api1.anthem.com',
    'port': 443,
    'user': 'srcSOAapiMHC',
    'password': 'D9sM2vQ9-FXtuST%74Fz',
    'apikey': 'zBBVmPgqaAKI80LQcAnjJS7GcOMBYYUm',
    'verify': False,
    'batchSize': 20
}
    #old - updated 7/30/2016: 'password': 'L!2ks8>+DpE3~7',

from mhcsaml2 import BINDING_HTTP_POST
from mhcsaml2.saml import NAME_FORMAT_BASIC

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

MHC_SAMLCONFIGS = [ {
        "accepted_time_diff" : 2000000,
        "entityid" : "https://sp.mobilehealthconsumer.com/",
        "name" : "MHC SAML SP",
        "service": {
            "sp": {
                "allow_unsolicited" : 'true',
                "endpoints" : {
                    "assertion_consumer_service" : [
                            ("https://www.mobilehealthconsumer.com/partners/SAMLEntry/",
                                BINDING_HTTP_POST)],
                },
            }
        },
        "key_file" : "/home/mhc/crypt/spsamlkey.pem",
        "cert_file" : "/home/mhc/crypt/spsamlcert.pem",
        "xmlsec_binary" : "/usr/bin/xmlsec1",
        "metadata": {
            "local": ["/home/mhc/mhc-backend/configs/krogersaml2escidp_federation_kroger_com_metadata.xml"],
        }
    }
]

ALLOWED_HOSTS = ['*']

BASE_URL = 'https://www.mobilehealthconsumer.com'
