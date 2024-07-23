from mhcsaml2 import BINDING_HTTP_POST

SAMLCONFIG = {
    "accepted_time_diff" : 2000000,
    "entityid" : "https://precept.mobilehealthconsumer.com/",
    "name" : "MHC Precept SP",
    "service": {
        "sp": {
            "allow_unsolicited" : 'true',
            "endpoints" : {
                "assertion_consumer_service" : [
                        ("https://precept.mobilehealthconsumer.com/partners/SAMLEntry",
                            BINDING_HTTP_POST)],
            },
        }
    },
    "key_file" : "/home/mhc/crypt/samlkey.pem",
    "cert_file" : "/home/mhc/crypt/samlcert.pem",
    "xmlsec_binary" : "/usr/bin/xmlsec1",
    "metadata": {
        "local": ["/home/mhc/mhc-backend/configs/preceptsaml.xml"],
    },
}
