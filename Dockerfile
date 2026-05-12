FROM shinsenter/magento:latest

# Create custom entrypoint directory
RUN mkdir -p /usr/local/bin/custom

# Copy custom entrypoint script
COPY entrypoint.sh /usr/local/bin/custom/entrypoint.sh
RUN chmod +x /usr/local/bin/custom/entrypoint.sh

# Override the entrypoint to run our custom script first
# The custom script will then call the original docker-php-entrypoint
ENTRYPOINT ["/usr/local/bin/custom/entrypoint.sh"]

# Default command - run PHP-FPM
CMD ["php-fpm"]