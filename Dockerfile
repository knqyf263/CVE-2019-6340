FROM drupal:8.6.9-apache
LABEL maintainer "knqyf263 <knqyf263@gmail.com>"

# Install packages
RUN apt-get update && apt-get install -y zip unzip curl git sqlite3 vim

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install drush
RUN composer global require drush/drush
ENV PATH $PATH:/root/.composer/vendor/bin

# Install site
RUN drush site-install --db-url="sqlite://sites/default/files/.ht.sqlite" --site-name="Drupal CVE-2019-6340" --account-pass=password

# Install REST UI module
RUN composer require drupal/restui

# Configure REST
RUN cp core/modules/rest/config/optional/rest.resource.entity.node.yml core/modules/rest/config/install/
RUN sed -i 's/basic_auth/cookie/g' ./core/modules/rest/config/install/rest.resource.entity.node.yml
RUN sed -i -e '5d' ./core/modules/rest/config/install/rest.resource.entity.node.yml

# Enable modules
RUN drush en rest hal

# Create node
ADD create_node.php .
RUN drush scr create_node.php

# Fix permission
RUN chown -R www-data:www-data sites

