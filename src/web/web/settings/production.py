from web.settings.base import *

DEBUG = False

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': [
            ':::11211',
            ':::11212',
        ]
    }
}
