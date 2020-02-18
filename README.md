# Bitbucket Pipelines Lighthouse and PHP 7.2 image

### Packages installed

- `php7.2-zip`, `php7.2-xml`, `php7.2-mbstring`, `php7.2-curl`, `php7.2-json`, `php7.2-imap`, `php7.2-mysql`, `php7.2-tokenizer`, `php7.2-xdebug`, `php7.2-intl`, `php7.2-soap`, `php7.2-pdo`, `php7.2-cli`, `php7.2-gd` and `php7.2-gmp`
- `wget`, `curl`, `unzip`
- `composer`
- MySQL 5.7
- NPM
- Lighthouse

### Sample `bitbucket-pipelines.yml`

```YAML
image: jeroenpeters1986/lighthouse-php
pipelines:
  default:
    - step:
        script:
          - service mysql start
          - mysql -h localhost -u root -proot -e "CREATE DATABASE test;"
          - composer install --no-interaction --no-progress --prefer-dist
          - ./vendor/phpunit/phpunit/phpunit -v --coverage-text --colors=never --stderr
```
