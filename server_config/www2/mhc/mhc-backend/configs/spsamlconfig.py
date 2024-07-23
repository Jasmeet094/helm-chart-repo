from mhcsaml2 import BINDING_HTTP_POST

CONFIG = {
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
        "local": ["/home/mhc/mhc-backend/preceptsaml.xml"],
    },
}
