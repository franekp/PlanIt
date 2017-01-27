from web.settings.base import *

DEBUG = True

# no CACHES so it uses default local cache

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}
