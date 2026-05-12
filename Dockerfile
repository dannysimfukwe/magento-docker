FROM magento/magento2:latest

# Enable Apache mod_rewrite for pretty URLs
RUN a2enmod rewrite rewrite

EXPOSE 80