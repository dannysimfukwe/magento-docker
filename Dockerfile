FROM ghcr.io/shinsenter/magento:latest

# Override the entrypoint to run our custom script
COPY entrypoint.sh /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
CMD ["php-fpm"]