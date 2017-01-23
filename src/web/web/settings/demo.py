from web.settings.base import *

DEBUG = False

ALLOWED_HOSTS = ['localhost']

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': [
            'memcached1:11211',
            'memcached2:11211',
        ]
    }
}
