# Use the official PHP image with Apache
FROM php:8.1-apache

# Copy the current directory contents into the container at /var/www/html
COPY src/ /var/www/html/

# Enable Apache mod_rewrite and AllowOverride
RUN a2enmod rewrite && \
    sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Ensure the necessary permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80

# Run Apache in the foreground
CMD ["apache2-foreground"]
