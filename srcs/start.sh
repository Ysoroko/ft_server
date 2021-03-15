service nginx start;
service mysql start;
service php7.3-fpm start;

# Configure a wordpress database

# 1. Create a database named wordpress
echo "CREATE DATABASE wordpress;"| mysql -u root --skip-password;

# 2. Create a root account which can access to all tables in wordpress
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;"| mysql -u root --skip-password;

# 3. Apply the previous changes (otherwise it waits until we restart the server)
echo "FLUSH PRIVILEGES;"| mysql -u root --skip-password;

# 4. Disregards the password, check the UNIX socker instead
# Since we setup no password, it wouldn't let us connect to phpMyAdmin otherwise
echo "update mysql.user set plugin='' where user='root';"| mysql -u root --skip-password;

echo "EXIT " | mysql -u root --skip-password;

service nginx restart;
service php7.3-fpm restart;


bash