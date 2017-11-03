DNA Project Base Testing Setup
===========================

Enables DNA Project Base projects to re-use a codeception installation without having to have codeception deps inside each component's vendor directory. 

To upgrade Codeception, bump the version in this directory's composer.json and run (in this directory):

```
php /app/composer.phar update --prefer-source --optimize-autoloader --ignore-platform-reqs
```
